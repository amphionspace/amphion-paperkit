# GRPO with Verifiable Rewards for Hotword-Aware ASR（用于论文 Method 章节）

> 写作约束：只描述算法原理与奖励设计动机，不涉及 vLLM 部署、KL 调度、显存优化、checkpoint 管理等工程细节。仅覆盖 ASR Accuracy 与 Hotword Match Accuracy 两条奖励；格式兜底奖励见 integrations_tasks_and_prompts.md 第 6.2.3 节。
> 算法实现挂载点（reward 注册、external_plugins、超参表）见 integrations_tasks_and_prompts.md 第 6 节；本文档专注 RL 目标与奖励函数的第一性原理推导。

## 1. 问题动机：SFT 极限与 RL 的必要性

SFT 在 ASR 上是 teacher-forced 训练：每一步条件分布都基于真实前缀 token，模型从未见过自己采样路径下的状态分布。这一不匹配在解码时表现为三类典型失败：

| 失败类别 | 物理来源 | 典型现象 |
| --- | --- | --- |
| Exposure bias | 训练分布 \(P(y_t \mid y_{<t}^{\star}, x)\) 与解码分布 \(P(y_t \mid \hat{y}_{<t}, x)\) 不一致 | 单字错误后续字符成片崩坏（"诸葛紫岐" → "朱圣祎若琪紫各庄村"） |
| 边界判别样本 | 二值决策（说/不说某热词、静音/非静音）在交叉熵 loss 上权重等同于普通字符 | 静音样本上的幻觉、热词的过激输出或漏出 |
| 度量-训练 gap | SFT 的字符级 cross-entropy 与下游 CER 不等价（CER 是字符级编辑距离，包括插入删除） | 训练 loss 已经收敛但 CER 仍有可压缩空间 |

注：exposure bias 在大规模预训练 LLM 上的严重程度较短上下文 seq2seq 模型已明显缓解（强语言先验对前缀错误有部分自恢复能力），故本工作不把它作为单独动机；上表第二、三行——边界判别样本与度量-训练 gap——才是 GRPO 在本任务上提供的不可替代价值。

强化学习直接在采样分布上优化下游可验证指标，是修复这三类失败的对症工具。RL 的核心约束：必须有低噪声、低成本、可批量计算的标量奖励信号。对 ASR 而言，CER 和热词命中是天然可验证的（无需人类偏好或 reward model），构成 RL 落地的充分条件。

第一性论证：为什么不直接用 SFT 多轮训练修复？

- 边界判别样本在 SFT loss 中权重过小（占字符总数的少数比例），需要显式 sequence-level reward 信号才能驱动判别；
- 度量-训练 gap 在 cross-entropy 的 token-level 性质下不可调和，必须将 reward 信号下沉到 sequence-level；
- 在 SFT 收敛点附近，cross-entropy 已无显著下降空间（loss 平坦），继续 SFT 容易过拟合训练集而损害泛化。

## 2. GRPO 算法回顾

Group Relative Policy Optimization（GRPO）是 PPO 的"去 critic"变种。原始 PPO 用一个独立的 critic 网络估计每个 token 的 value baseline；GRPO 取消 critic，对同一 prompt 采样 \(G\) 条 completion 形成 group，用组内统计量构造 baseline 与归一化。

设 prompt \(q\)，对每条 prompt 采样 \(\{o_1, \dots, o_G\}\)，对应 reward \(\{r_1, \dots, r_G\}\)，则第 \(i\) 条 completion 的优势为

\[
A_i = \frac{r_i - \mathrm{mean}(\{r_j\}_{j=1}^G)}{\mathrm{std}(\{r_j\}_{j=1}^G) + \epsilon}.
\]

GRPO 的代理目标沿用 PPO 的 clipped surrogate 加 KL 正则：

\[
\mathcal{J}_{\mathrm{GRPO}}(\theta) = \mathbb{E}_{q, \{o_i\}}\!\left[\frac{1}{G}\sum_{i=1}^{G}\frac{1}{|o_i|}\sum_{t=1}^{|o_i|}\min\!\left(\rho_{i,t} A_i,\ \mathrm{clip}(\rho_{i,t}, 1-\varepsilon, 1+\varepsilon)\, A_i\right) - \beta\, D_{\mathrm{KL}}\!\left(\pi_\theta \,\|\, \pi_{\mathrm{ref}}\right)\right],
\]

其中 \(\rho_{i,t} = \pi_\theta(o_{i,t} \mid q, o_{i,<t}) / \pi_{\mathrm{old}}(o_{i,t} \mid q, o_{i,<t})\)，\(\pi_{\mathrm{ref}}\) 取自 SFT 收敛点。

GRPO 与 PPO 的本质差异：

| 维度 | PPO | GRPO |
| --- | --- | --- |
| Value baseline | 独立 critic 网络估计 | 组内 mean 直接计算 |
| Advantage 归一化 | GAE（generalized advantage estimation） | 组内 \(z\)-score |
| 模型数量 | actor + critic + ref + reward 共 4 个 | actor + ref + reward 共 3 个 |
| Critic 训练数据 | 需要 critic 监督信号 | 不需要 |

ASR 任务选 GRPO 的核心理由：

1. ASR 的 reward 在 sequence-level 给定（\(1-\mathrm{CER}\) 与候选词二值一致率均无 token-level decomposition），critic 网络对 token-level value 的回归本身有大方差；GRPO 直接用 group 内相对排序绕开这一问题。
2. ASR 样本在足够采样温度（默认 0.6）下，单 prompt 的 \(G=16\) 条 completion 自然形成有效方差（CER 通常分布在 \([0, 0.3]\) 区间），组内 baseline 估计稳定。
3. 省去 critic 训练：梯度反传只更新 actor 与可选的 reward model（本工作 reward 为规则函数，不需训练），相对 PPO 减少一个等量参数的网络。注意 GRPO 的推理成本（每 prompt 采样 \(G=16\) 条）显著高于 PPO（每 prompt 1 条），整体训练时间不一定减少，但显存占用与可训练参数量减少。

## 3. 可验证奖励范式

传统 RLHF 中 reward 由 reward model 给出，存在三类已知问题：

| 问题 | 机制 |
| --- | --- |
| Reward hacking | 策略发现 reward model 的盲区（如重复高频词），获得高 reward 但语义崩坏 |
| Distribution shift | 策略偏离 reward model 训练分布后，reward 输出不可靠 |
| 标注成本 | reward model 需要大量人类偏好对训练，且需周期性重训 |

ASR 任务允许跳过这一切：转写 \(\hat{y}\) 与参考 \(y\) 在文本层面直接可比，候选热词集合 \(C\) 在 prompt 中可直接解析。reward 完全由 \((\hat{y}, y, C)\) 三元组的规则函数计算，无需任何参数化模型。这种"verifiable reward"具备三个性质：

1. 无 hacking 空间：reward 函数是 ground-truth 的确定性函数，策略无法学到"骗过"它的捷径——任何高 reward 都对应真实下游指标提升。
2. 训练-评测形式一致：reward 函数与下游评测的 metric 在数学形式上同构（详见 §7），消除 reward-eval gap。
3. 零额外标注：所有信号来自已有的转写标注 \(y\) 与 prompt 中的候选 \(C\)。

代价：reward 形式被限制在"可由规则计算"的范畴内，不能直接表达"流畅性"、"自然度"等主观指标。这一限制在 ASR 任务上恰好不构成问题——ASR 的下游目标本就是规则化指标（CER、热词命中），不需要主观维度。

## 4. 奖励一：ASR Accuracy（\(1 - \mathrm{CER}\)）

### 4.1 形式定义

字符错误率（Character Error Rate, CER）定义为

\[
\mathrm{CER}(\hat{y}, y) = \frac{d_{\mathrm{edit}}(\hat{y}, y)}{\lvert y \rvert},
\]

其中 \(d_{\mathrm{edit}}\) 是 Levenshtein 编辑距离（替换、插入、删除均计 1），\(\lvert y \rvert\) 是参考文本字符数。

ASR Accuracy reward 定义为

\[
R_{\mathrm{asr}}(\hat{y}, y) = \max\!\left(0,\ 1 - \mathrm{CER}(\hat{y}, y)\right).
\]

### 4.2 边界规则

| 场景 | 规则 | 动机 |
| --- | --- | --- |
| \(y = \emptyset\) 且 \(\hat{y} = \emptyset\) | \(R = 1.0\) | 静音样本正确响应沉默 |
| \(y = \emptyset\) 且 \(\hat{y} \ne \emptyset\) | \(R = 0.0\) | 静音样本产生幻觉直接归零 |
| \(y \ne \emptyset\) 且 \(\mathrm{CER} > 1\)（如严重过量插入） | \(R = 0\) 而非负值 | 防止极端坏样本的极大负 advantage 主导组内 \(z\)-score |

为什么选 \(1 - \mathrm{CER}\) 而非 \(1 - \mathrm{WER}\)？

| 选项 | 优点 | 缺点 |
| --- | --- | --- |
| \(1 - \mathrm{WER}\) | 与英文 ASR 学界主指标一致 | 对中文（无 word boundary）退化为单字 = 单词，与 CER 等价；中英混合时定义不一致 |
| \(1 - \mathrm{CER}\) | 跨语种统一定义，与下游评测使用的字符级编辑距离严格相同 | 英文场景下与学界惯用 WER 差一个常数（同序数） |

跨语种一致性是决定性约束：本工作的训练集 / 评测集均为中英混合多语种，CER 是唯一在所有样本上语义一致的字符级 metric。

### 4.3 为什么用 \(\max(0,\,1-\mathrm{CER})\) 而非 \(1-\mathrm{CER}\)

CER 的上界没有限制（插入冗余字符可使 CER 任意大），\(1-\mathrm{CER}\) 可以取很大的负值。\(\max(0,\cdot)\) 只对负侧裁剪——\(1-\mathrm{CER}\) 的上界本就是 1（在 \(\hat{y}=y\) 时取等），不需要上界裁剪。

负侧裁剪的必要性：若 \(G\) 条 completion 里恰有 1 条 \(\mathrm{CER}=5\)（严重崩坏），未裁剪时该条 reward \(=-4\)，与其他 \(\approx 0.7\) 的样本一起进 GRPO 的组内 \(z\)-score。极端负值会把 \(\mathrm{mean}\) 拉低、\(\mathrm{std}\) 拉高，导致其他"正常但有差异"的样本之间的 advantage 几乎被压平，整个 group 的学习信号被单条噪声主导。裁剪到 \(\ge 0\) 等价于把"严重错误"统一映射到 0，让组内 reward 落在 \([0, 1]\) 这一有限支撑集上，advantage 数值稳定。

裁剪不会丢失"避免崩坏"的梯度信号：\(R = 0\) 与组内非零样本的差异仍存在，advantage 仍非零；只是失去了"崩坏程度更深的样本"与"崩坏程度稍轻的样本"之间的相对排序。后者在 ASR 任务上几乎没有信息——CER \(>1\) 的样本统一都是结构性失败，区分其内部"哪个更糟"对学习无帮助。

## 5. 奖励二：Hotword Match Accuracy

### 5.1 候选解析与匹配

每条样本的候选热词集合 \(C\) 按以下优先级解析：

1. dataset 的 `candidate_hotwords` 列（结构化字段，直接可信）；
2. 退化路径：从 user prompt 的 `Hotwords:` 行用正则解析。

两路径冗余设计：训练数据流水线可能在不同阶段写入不同字段，冗余保证 reward 不因数据格式漂移而沉默崩溃。

候选解析后，从 prediction \(\hat{y}\) 与 reference \(y\) 中各自抽取被实际"说出"的热词子集：

\[
\mathrm{Pred}(\hat{y}; C) = \mathrm{LongestFirst\_Mask}(C, \hat{y}),\quad
\mathrm{Ref}(y; C) = \mathrm{LongestFirst\_Mask}(C, y).
\]

\(\mathrm{LongestFirst\_Mask}\) 按候选长度降序贪心匹配并屏蔽已命中区域。这一步必要性：

- 若直接用"子串包含"判定，"北京"在文本"北京烤鸭"中会被独立命中一次，"北京烤鸭"也会再次命中，单一热词出现导致两次 hit；
- 长串优先 + masked 保证每一段文本至多被一个最长候选覆盖，匹配结果与人类直觉一致；
- 同时避免热词嵌套时的双重计数（"诸葛紫岐" 命中 "诸葛"、"紫岐" 等子串）。

### 5.2 奖励形式

\[
R_{\mathrm{hw}}(\hat{y}, y; C) = \frac{1}{\lvert C \rvert}\sum_{c \in C}\mathbf{1}\!\left\{\mathbf{1}[c \in \mathrm{Pred}(\hat{y}; C)] = \mathbf{1}[c \in \mathrm{Ref}(y; C)]\right\}.
\]

含义：对每个候选 \(c\)，预测与参考必须在"该候选是否被说出"这一二值判断上完全一致才计 1 分，否则 0 分。

### 5.3 为何选 match_accuracy 而非 F1

记 \(P = \mathrm{Pred}\)、\(R = \mathrm{Ref}\)、\(C\) 为候选集，分类四类候选：

| 类别 | 含义 | F1 | match_accuracy |
| --- | --- | --- | --- |
| TP（\(c \in P \cap R\)） | 正确命中 | 计入 precision/recall | 计 1 |
| FP（\(c \in P \setminus R\)） | 误报 | 拉低 precision | 计 0 |
| FN（\(c \in R \setminus P\)） | 漏报 | 拉低 recall | 计 0 |
| TN（\(c \notin P \cup R\)） | 正确拒绝 | 完全忽略 | 计 1 |

差异点：F1 不奖励 TN，即"候选 \(c\) 既不在参考也不在预测"这一正确判别在 F1 中不计分；match_accuracy 把它计为 1。

这一差异在 ASR hotword 任务上有决定性意义：

1. anti-spray 激励：F1 下，模型把所有候选词都强行说出可拿到 100% recall（推 precision 上限），损失只在 precision；而 match_accuracy 直接为每个误报 \(-1/\lvert C \rvert\)，从根本上抑制"凡候选必输出"的退化策略。
2. 与 retrieve 阶段的"宁缺毋滥"一致：retrieve 阶段已经做了高精度过滤（§3 of hotword_retrieval_method.md 中的阈值 + 全局判别性检查），剩余候选中仍可能有不在音频中出现的"近邻 distractor"。模型必须学会"正确拒绝"这些 distractor，match_accuracy 直接以 TN 为正激励驱动这一行为。
3. 候选集大小归一化：F1 对小候选集（\(\lvert C \rvert \le 3\)）极度敏感（一次漏报 recall 直接跌 33%），match_accuracy 在 \(\lvert C \rvert\) 上线性平均，方差更稳。

reward hacking 的形式化论证：设策略 \(\pi\) 试图通过"凡候选必输出"获得高 reward，则在候选集中真热词比例为 \(\alpha\) 的样本上：

- F1 下 \(\pi\) 的 reward：recall \(= 1\)、precision \(= \alpha\)、\(F_1 = 2\alpha/(1+\alpha)\)。当 \(\alpha\) 较小（如候选 16 个中真热词 2 个，\(\alpha = 0.125\)），\(F_1 \approx 0.22\) 远高于零，策略仍有正激励；
- match_accuracy 下 \(\pi\) 的 reward：\(\alpha\) 个候选正确（TP）、\((1-\alpha)\) 个候选误报（FP 错算为 0），总 reward \(= \alpha\)。"凡候选必输出"的最佳 reward 上界即 \(\alpha\)，远低于"正确判别"的 \(1.0\)，hacking 路径不再有竞争力。

### 5.4 无候选样本的中性 \(1.0\)

当样本的 prompt 无 `Hotwords:` 行（普通 ASR 任务）时，候选集 \(C\) 不存在，reward 返回中性 \(1.0\) 而非 \(0\) 或缺省。

第一性论证：

- GRPO 的组内 \(z\)-score 由当前 batch 的 \(G\) 条 completion 计算，无候选样本若返回 \(0\)，会把整组 reward 整体下拉，但因为同一 prompt 的所有 completion 都返回 \(0\)，组内方差仍合理（mean 偏低、std 偏小），advantage 接近 0；
- 看似"无害"，但实际上把一个本应不参与 hotword 学习的样本"挤压"成对 hotword 维度无梯度的样本，是一种隐式的 reward 信号污染；
- 返回 \(1.0\)（与 batch 内其他高 reward 样本同水位）同样使 advantage 接近 0，且语义更直观——"该样本对 hotword 维度无意见"；
- 这一选择与 SFT 阶段的处理对偶：SFT 中无候选样本完全不参与 hotword loss 计算，GRPO 中以中性 reward 表达"不参与"。

## 6. 加权组合与权重设计原则

最终 reward 是加权和：

\[
R_{\mathrm{total}}(\hat{y}, y; C) = w_{\mathrm{asr}}\, R_{\mathrm{asr}}(\hat{y}, y) + w_{\mathrm{hw}}\, R_{\mathrm{hw}}(\hat{y}, y; C),
\]

本工作取 \(w_{\mathrm{asr}} = 1.0\)，\(w_{\mathrm{hw}} = 0.3\)。

### 6.1 权重设计的两个约束

约束 A（主轴稳定）：\(w_{\mathrm{asr}} \gg w_{\mathrm{hw}}\)。CER 是 ASR 的最终目标，必须主导梯度方向。若 \(w_{\mathrm{hw}}\) 与 \(w_{\mathrm{asr}}\) 同量级，模型可能为提升单个候选词的命中率而以错读其他字符为代价。

约束 B（信号不被淹没）：\(w_{\mathrm{hw}}\) 必须使 hotword 维度的梯度贡献与 accuracy 维度可比。SFT 收敛后，\(R_{\mathrm{asr}}\) 通常落在 \([0.7, 0.95]\) 区间（组内方差小），\(R_{\mathrm{hw}}\) 落在 \([0.6, 0.95]\) 区间（组内方差更大，因 hotword 判别比 CER 更离散）。若 \(w_{\mathrm{hw}} = 0\)，hotword 维度完全不参与训练，GRPO 退化为纯 accuracy 优化。

\(0.3\) 的来源：经验上当 \(w_{\mathrm{hw}}/w_{\mathrm{asr}}\) 在 \([0.2, 0.4]\) 区间内，两条 reward 的有效梯度贡献相当；\(0.3\) 是该区间的中点。

### 6.2 两奖励的潜在冲突

| 冲突场景 | 机制 | 缓解 |
| --- | --- | --- |
| 模型为获得 hotword reward 而插入候选词 | 候选词不在音频中，但被强行说出 → \(\mathrm{CER}\) 上升、\(R_{\mathrm{asr}}\) 下降；hotword 上 FP 计 0 分（match_accuracy 设计） | \(w_{\mathrm{asr}}\) 主导 + match_accuracy 的 FP 惩罚双重保护 |
| 模型为获得 accuracy reward 而忽略候选词 | 转写正确但漏掉本应 bias 到的热词 → \(R_{\mathrm{asr}}\) 高、\(R_{\mathrm{hw}}\) 下降 | \(w_{\mathrm{hw}} = 0.3\) 提供足够梯度防止"放弃 hotword" |
| 静音样本上的过度激进 | accuracy 边界规则把静音上的非空输出归零，与 hotword 无关 | accuracy 的边界规则单独覆盖 |

### 6.3 反事实分析

| 设计选择 | 反事实（不采用的后果） |
| --- | --- |
| 选 GRPO 而非 PPO | 需要额外 critic 网络，4B+ 参数下显存翻倍；critic 对 sequence-level reward 的 token-level 回归大方差 |
| 用 \(1 - \mathrm{CER}\) 而非 \(1 - \mathrm{WER}\) | 中英混合场景下 WER 定义不一致；与下游 jiwer CER 评测有 metric gap |
| reward 负侧裁剪到 \(\ge 0\) | 极端 CER 样本的负 reward 主导组内 \(z\)-score；组内 advantage 数值不稳 |
| match_accuracy 而非 F1 | 模型有"凡候选必输出"的 hacking 路径，且 F1 在小候选集上方差极大 |
| 长串优先 + masked 匹配 | 短串嵌套长串导致重复计数（"北京"在"北京烤鸭"中），reward 与人类直觉不一致 |
| 无候选时 reward = 1 | reward = 0 会把无候选样本的 hotword 维度挤压成隐式负梯度；reward 缺省（NaN）会破坏 batch 平均 |
| \(w_{\mathrm{hw}} = 0.3\) | 太大 → accuracy 被 hotword 干扰；太小 → hotword 信号沉默；区间 [0.2, 0.4] 之外的取值任一方向都退化 |

## 7. 训练-评测对齐

可验证奖励的关键性质是 reward 函数与评测 metric 同构。形式化：

| 评测阶段指标 | 训练阶段 reward | 同构关系 |
| --- | --- | --- |
| CER（jiwer 字符级编辑距离 / 参考字符数） | \(\mathrm{CER}(\hat{y}, y) = d_{\mathrm{edit}}/\lvert y \rvert\) | 同函数 |
| Hotword Match Accuracy（候选上的二值判别一致率） | \(R_{\mathrm{hw}}\) | 同函数 |
| Hotword-CER（仅对热词位置计算的 CER） | 由 \(R_{\mathrm{hw}}\) + \(R_{\mathrm{asr}}\) 联合驱动 | 强相关但非完全同构 |

由"训练 reward = 评测 metric"可直接推出两个性质：

1. 训练 reward 单调上升必然反映在评测指标的提升上，不会出现 "reward 上升但 metric 下降" 的 reward-eval gap；
2. reward hacking 的任何形式都要求"在评测指标上看起来更好"——但评测指标本身就是 ground-truth，故 hacking 退化为"真实改进"。

第二点是 verifiable reward 范式的核心承诺：reward 不是 proxy（代理变量），而是真实目标本身。这一承诺仅在 ASR、数学、代码等"答案可机器验证"的任务上成立；对开放生成任务（如对话、创作）则必然失效，需要 reward model。

## 8. 与 SFT 的互补关系

GRPO 与 SFT 在 ASR 任务上承担不同的优化阶段：

| 维度 | SFT | GRPO |
| --- | --- | --- |
| 训练分布 | Teacher-forced，模型见到真实前缀 | Self-sampled，模型见到自己生成的前缀 |
| 优化目标 | Token-level cross-entropy（局部、密集信号） | Sequence-level reward（全局、稀疏信号） |
| 收敛区域 | 分布主体：典型样本的转写正确 | 边界样本：静音、热词判别、长尾失败模式 |
| 学习率 | \(10^{-5}\) | \(10^{-6}\)（保 \(\pi_{\mathrm{ref}}\) 漂移可控） |
| 训练 epoch | 多 epoch（\(\sim 6\)） | 单 epoch（\(\sim 1\)，RL 易过拟合） |

SFT 把模型推到"绝大多数样本都对"的收敛点；GRPO 在该点附近通过 reward 信号修剪边界失败。两阶段顺序不可调换：

- 跳过 SFT 直接 GRPO：模型在采样分布上几乎全错，所有 completion 的 reward 集中在 \([0, 0.2]\)，组内方差极小，advantage 趋零，无学习信号；
- 跳过 GRPO 直接 SFT 收敛：边界判别样本与度量-训练 gap 问题无解，下游 CER 留有 \(\sim 1\) 个绝对百分点的可压缩空间未被开发。

两阶段配合的另一关键点：SFT 数据增广（hotword 注入 + miss 模拟 + hard-negative，见 hotword_retrieval_method.md §4）已使 SFT 模型见过完整的 retrieve 行为谱；GRPO 在此基础上不需要再扩展数据分布，只需用 reward 推 SFT 已学到的边界判别能力。

## 9. 评估指标

GRPO 训练过程中需独立追踪以下指标：

| 指标 | 含义 |
| --- | --- |
| Reward mean | 每个 batch 内 \(R_{\mathrm{total}}\) 的平均值，反映模型整体性能；非单调上升通常预示 KL 失控 |
| Reward std (within-group) | 组内 \(G\) 条 completion 的 reward 方差；过小（< 0.05）表示样本饱和（advantage 趋零），需调高 temperature 或换 batch；过大（> 0.4）表示训练不稳 |
| KL divergence | \(D_{\mathrm{KL}}(\pi_\theta \| \pi_{\mathrm{ref}})\)，控制策略漂移；建议保持 \(<\) 0.1 |
| Per-reward decomposition | \(R_{\mathrm{asr}}\) 与 \(R_{\mathrm{hw}}\) 分别的均值与方差，监测两奖励是否同向上升或出现冲突 |

最终模型在与 SFT 同分布的 holdout 测试集上报告：

| 报告项 | 关联 |
| --- | --- |
| CER | \(R_{\mathrm{asr}}\) 的下游对应 |
| Hotword Match Accuracy（与 \(R_{\mathrm{hw}}\) 同函数） | \(R_{\mathrm{hw}}\) 的下游对应 |
| Hotword Recall@K / Precision@K | 独立的 retrieve 端指标（详见 hotword_retrieval_method.md §8） |
| Hotword-CER | 仅在热词位置计算的 CER，反映"热词命中且字符级正确"的细粒度能力 |

GRPO 前后的 \(\Delta\) 值（特别是 Hotword Match Accuracy 与 Hotword-CER）是论文实验章节的主要数据点。

---

## 自我批判

- 权重 \(w_{\mathrm{asr}} = 1.0\)、\(w_{\mathrm{hw}} = 0.3\) 由经验区间 \([0.2, 0.4]\) 中取中点而来，并非通过 reward shaping 理论严格推导；不同数据集分布下最优值可能不同。
- match_accuracy 在 \(\lvert C \rvert\) 极小（如只含 1 个候选）时退化为 \(\{0, 1\}\) 二值 reward，组内方差变大但样本绝对数也少，影响有限；但论文报告时应分桶（按 \(\lvert C \rvert\) 区间）观察。
- match_accuracy 的"必然 TN"盲点：候选集中部分候选可能与音频主题完全无关（如医疗语音 prompt 里有"故宫"），模型几乎不可能误报这类候选，对应的 TN 是"白拿"的 1 分，会虚高 \(R_{\mathrm{hw}}\) 的绝对值。这一盲点不影响相对比较（同 prompt 不同 completion 的 reward 仍有判别力），但跨样本的 \(R_{\mathrm{hw}}\) 平均值不可直接横向解读。
- 部分子串匹配未被计为命中（"诸葛"出现但完整"诸葛紫岐"未出现 → FN）。这一选择可能对部分正确转写过严，与人类感受不一致；但与 retrieve 阶段的"完整热词"语义自洽。
- GRPO 的 \(\pi_{\mathrm{ref}}\) 取 SFT 收敛点，假设 SFT 已足够好；若 SFT 本身欠拟合，GRPO 会放大 SFT 的偏差。本工作通过 SFT 阶段的多源数据 + hotword 数据增广覆盖来缓解这一前提的脆弱性。
- 本文档假设 reward 在 sequence-level 是无偏的；事实上 \(R_{\mathrm{asr}}\) 与 \(R_{\mathrm{hw}}\) 都不显式区分"哪些 token 该被奖励"，GRPO 把同一 advantage 平摊到 completion 所有 token 上。这一近似在长 completion（\(>500\) token）上误差较大，但 ASR 任务的典型 completion 长度（\(<200\) token）使该近似仍合理。
- CER 把所有编辑操作（替换、插入、删除）一视同仁，但在实际应用中误删一个数字（"3"→ ""）与误删一个语气词（"嗯"→""）的代价差异极大。这是 CER 的固有局限，不是 GRPO 的问题；论文实验章节如需细分，应另报 Named Entity 错误率等领域指标作为补充。
