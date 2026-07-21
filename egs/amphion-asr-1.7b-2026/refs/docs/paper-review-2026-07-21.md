# AmphionASR 论文审阅与整改清单

- 日期：2026-07-21
- 范围：`egs/amphion-asr-1.7b-2026/`
- 状态：待作者确认关键事实后执行
- 属性：内部审阅记录，不是论文草稿，不应直接翻译进正文

## 1. 审阅结论

当前最需要解决的不是局部措辞，而是核心贡献、实际 checkpoint、训练配方与实验所能支持的结论尚未完全对齐。

建议将论文收束为：以大词表 contextual/hotword ASR 为主要研究增量，以 target-speaker、degradation robustness 和 whispered ASR 展示同一模型的能力范围，以 plain ASR 作为能力保留检查。Mandarin 和 English 只用于限定当前实验范围，不作为系统身份或优势。

在完成第 2 节的阻塞项之前，不建议大规模润色标题、摘要和引言，以免因模型身份或实验口径变化而返工。

## 2. 阻塞项（P0）

### P0-1：确认实际模型与 checkpoint

- [ ] 确认全文表格结果来自下列哪一个模型：
  - Qwen3-ASR-1.7B；或
  - `model_arch.md` 记录的 Qwen3-AuT + Qwen3-4B-Instruct checkpoint。
- [ ] 以最终评测 checkpoint 的实际配置和权重形状为唯一真相源，重新核对模型名称、总参数量、encoder 输出维度、projector、LLM hidden size、层数和可训练模块。
- [ ] 若最终模型是 1.7B，标记或更新过期的 `model_arch.md`，避免后续 agent 继续引用 4B 配置。
- [ ] 若最终模型是 4B，全面修正标题、摘要、模型表、architecture figure、baseline 关系和参数量。

证据：

- 正文将系统描述为 Qwen3-ASR-1.7B、约 2.0B 参数：[`../../sections/04_model.tex`](../../sections/04_model.tex)。
- 内部架构文档记录的是约 4.735B 的 Qwen3-AuT + Qwen3-4B-Instruct：[`model_arch.md`](model_arch.md)。
- 官方 Qwen3-ASR-1.7B 配置为 24 层、`d_model=1024` 的音频编码器，`output_dim=2048`，以及 28 层、`hidden_size=2048` 的语言模型：[Qwen3-ASR-1.7B config](https://huggingface.co/Qwen/Qwen3-ASR-1.7B/blob/main/config.json)。

验收标准：论文、figure、内部真相源和最终 checkpoint 的模型身份及全部架构数字一致。

### P0-2：建立与最近相关工作的差异边界

- [ ] 在 Related Work 和 Introduction 中加入 *Contextual Biasing for LLM-Based ASR with Hotword Retrieval and Reinforcement Learning*（arXiv:2512.21828）。
- [ ] 明确列出该工作与 AmphionASR 在 retriever、candidate construction、prompt injection、RL reward、训练数据和评测协议上的相同点与差异。
- [ ] 将真正由本工作拥有且经过实验验证的差异写入贡献列表；无法通过实验隔离的设计不作为 headline contribution。
- [ ] 在同一评测协议下加入最接近的 contextual-ASR baseline，或明确说明无法直接比较的协议差异。
- [ ] 修正 `references.bib` 中该论文的错误作者信息；arXiv 页面列出的作者为 YuXiang Kong 等人，而当前条目写成 Egor Lakomkin。

证据：

- 本地论文清单已将其标为“GLCLAP 检索 + GRPO RL”的强对照：[`../notes/papers/INDEX.md`](../notes/papers/INDEX.md)。
- 该文采用 GLCLAP top-\(K\) 检索、文本 prompt 注入和同时优化热词及转写的 GRPO reward：[arXiv:2512.21828](https://arxiv.org/abs/2512.21828)。
- 当前正文只引用 GLCLAP，没有引用上述最接近工作：[`../../sections/04_model.tex`](../../sections/04_model.tex)。

验收标准：审稿人能从 Introduction 的贡献列表和 Related Work 中直接回答“AmphionASR 相比 GLCLAP+GRPO 工作新增了什么，以及证据在哪里”。

### P0-3：冻结并验证最终 GRPO 配方

- [ ] 确认最终 GRPO 是两项 reward，还是包含 format reward 的三项 reward。
- [ ] 确认最终 SFT 使用 ZeRO-1 还是 ZeRO-2，并以训练日志或最终配置为准。
- [ ] 修正正文中“negative CER clipped to \([0,1]\)”的表述；公式实际是 \(\max(0,1-\mathrm{CER})\)。
- [ ] 明确空 reference 的边界规则：只有 reference 与 hypothesis 同为空时得 1，否则得 0。
- [ ] 定义候选集为空时的 \(R_\mathrm{hw}\)，避免公式出现 \(|C|=0\) 的未定义情况。
- [ ] 解释或消融 match accuracy 的类别不平衡风险：当候选列表较大且真热词很少时，true negatives 可能主导该 reward。
- [ ] 增加 SFT 与 SFT+GRPO 的对照，至少报告普通转写误差、hotword entity error、hotword match 指标和负样本行为。

证据：

- 正文只写两项 reward 和权重 `1.0/0.3`：[`../../sections/05_training.tex`](../../sections/05_training.tex)。
- `task_prompts.md` 写三项 reward 和权重 `1.0/0.3/0.1`，并记录 ZeRO-2：[`task_prompts.md`](task_prompts.md)。
- `gpro_method.md` 将 GRPO 前后差值列为主要实验数据点：[`gpro_method.md`](gpro_method.md)。

验收标准：正文配方与最终训练日志一致，并有直接实验说明 GRPO 对最终结果的增量。

### P0-4：让 hotword 实验能够隔离 retrieval 的贡献

- [ ] 将当前 `no retrieval` 与 `retrieval` 对比改造成可解释的消融矩阵。
- [ ] 至少包含：无 hotword、oracle hotword、retrieved hotword、random/frequency-matched hotword。
- [ ] 若论文保留 GRPO 贡献，再分别报告 SFT 与 SFT+GRPO。
- [ ] 在相同 hotword 输入条件下比较 contextual-ASR baselines；不得把 plain-ASR baseline 与有额外上下文的 AmphionASR 当作同输入排名。
- [ ] 报告 candidate-pool coverage、Recall@\(K\) 和下游 entity error，区分“目标词不在候选池”“retriever 未召回”和“decoder 未使用召回词”。
- [ ] 说明 CommonVoice candidate pool 使用 test-split transcript 生成的协议边界，并补充自动热词标注的人工质量抽查或 annotation precision/recall。

证据：

- 当前两个条件同时改变了上下文是否存在和检索器是否启用：[`../../sections/06_experiments.tex`](../../sections/06_experiments.tex)。
- 当前 GigaSpeechBench baselines 均为 plain ASR，无 hotword 输入：[`../../sections/07_hotwords.tex`](../../sections/07_hotwords.tex)。

验收标准：每一个 headline hotword claim 都能对应一个只改变单一因素的对照。

### P0-5：闭合 TS-ASR 的训练—评测链条

- [ ] 为 target-absent negatives 报告 false-alarm、rejection 或 silence accuracy，不能只报告 positive-slice WER。
- [ ] 在相同协议下加入专用 TS-ASR baseline，而不只使用缺少目标说话人选择能力的通用 Qwen 模型。
- [ ] 分开报告 in-house synthetic test 和 Libri2Mix/Libri3Mix，明确前者与训练使用同一生成流水线带来的证据边界。
- [ ] 检查 LibriMix 的 enrollment、mixture、reference 和 normalization 是否与专用 baseline 协议一致。
- [ ] 保留“Libri2Mix 与 Libri3Mix 差异原因尚未建立”的克制表述，不增加未经内部材料背书的机理解释。

证据：

- 训练数据包含 target-absent empty-transcript negatives：[`../../sections/03_data.tex`](../../sections/03_data.tex)。
- 当前实验明确只报告 positive slice：[`../../sections/06_experiments.tex`](../../sections/06_experiments.tex) 与 [`../../sections/08_ts_asr.tex`](../../sections/08_ts_asr.tex)。
- 本地 refs 已收录 SQ-Whisper、Target Speaker ASR with Whisper 等专用工作：[`../notes/papers/INDEX.md`](../notes/papers/INDEX.md)。

验收标准：论文对“目标存在时转写正确”和“目标不存在时保持静音”两个训练目标都有直接证据。

## 3. 高优先级整改（P1）

### P1-1：重设论文主线和语言范围

- [ ] 从 title、PDF metadata、abstract 系统定义和 conclusion 系统定义中移除将 `Mandarin--English` 当作身份的写法。
- [ ] 在 abstract 或 Experiments 中保留一次清晰范围声明：当前研究在 Mandarin 和 English benchmarks 上验证。
- [ ] 不把 degradation robustness 和 whispered ASR 统称为 personalised recognition 或 context-aware ASR。
- [ ] 决定统一口径：hotword/contextual ASR 是主要研究贡献，其余任务是 shared-model capability breadth；或为更宽泛的统一任务主张补充相应消融。
- [ ] 将 plain ASR 始终称为 retention check，不使用 `competitive sanity check`。

涉及位置：

- [`../../main.tex`](../../main.tex)
- [`../../sections/00_abstract.tex`](../../sections/00_abstract.tex)
- [`../../sections/01_introduction.tex`](../../sections/01_introduction.tex)
- [`../../sections/12_conclusion.tex`](../../sections/12_conclusion.tex)

验收标准：标题、摘要、贡献列表、teaser、实验主表和结论共同讲同一个主要研究增量。

### P1-2：补齐可复现实验配置

- [ ] 对自行运行的所有 baseline 和 AmphionASR 写明 checkpoint revision、prompt、offline/streaming mode、greedy/beam、temperature、max tokens 和 batch 设置。
- [ ] 明确 Mandarin normalizer 的可复现规则或公开实现。
- [ ] 区分“作者自行重跑”与“从原论文/benchmark 复制”的数字。
- [ ] 对复制的 degradation baseline 数字确认 normalization 与 AmphionASR 是否一致；若不一致则分表或显式标注。
- [ ] 给所有表格补充 dataset split 和统一评测协议说明。

验收标准：第三方能够仅根据论文和 release material 重现每张 headline table 的评测流程。

### P1-3：调整章节顺序与篇幅

- [ ] 将核心 Model/Method 提前到 Data 之前，避免 retrieval 方法到第 7 页才首次完整出现。
- [ ] 将逐语料计数、hotword pool 细节和 TS-ASR 合成参数更多地移入 Appendix。
- [ ] 新增 Related Work，重点覆盖 contextual ASR、hotword retrieval/RL 和 TS-ASR；压缩泛化的 ASR 历史回顾。
- [ ] 删除或合并 `Cross-Task Observations`：当前内容主要重复结果和证据边界，应分别回到 Plain ASR 与 TS-ASR 结果小节。
- [ ] 在 Conclusion 中删除未定义的 `unmeasured generation failures`，改成具体、已在正文说明的证据边界。

验收标准：读者在前两页即可理解问题、主要方法、相对最近工作的差异和最重要证据。

### P1-4：重做关键图表

- [ ] 用 TikZ 重做 `capabilities-v4.png`，并提交 `.tex` 与 `.pdf`。
- [ ] teaser 必须与 headline scope 一致；若声称四种条件，图中不能遗漏 whispered ASR。
- [ ] 为 `architecture.pdf` 补齐受版本控制的 TikZ 源码。
- [ ] 避免用含义不清的单一 `RAG` 方框代替 candidate retrieval、ranking、prompt injection 和 decoding 路径。
- [ ] 将两张 12-domain GigaSpeechBench 表改为更易读的主表摘要；完整 per-domain 数字放 Appendix。
- [ ] 提高 degradation table 的字号，或拆分 Real/Sim，确保 100% 缩放可读。
- [ ] 调整 Appendix 最后一页的 float 布局，减少大面积空白。

验收标准：所有最终 paper figures 均有 TikZ 源码、风格一致，并能在 100% 缩放下阅读。

### P1-5：清理引用与披露

- [ ] 将 Qwen3-ASR 条目改为权威论文/官方仓库信息，并核对 2026 年份与作者。
- [ ] 修正 Gemini 3-Flash baseline 当前引用 Gemini 2.5 论文的问题。
- [ ] 为 GPT-4o Transcribe 使用能直接支持该 endpoint 的官方来源。
- [ ] 为 `aidatatang_200zh`、AudioSet road-traffic subset 等数据源补充直接引用。
- [ ] 删除或迁移会直接打印进 bibliography 的内部说明性 `note` 字段。
- [ ] 补齐参考文献的完整作者、标题、年份和 venue，避免 `others` 与错误作者。
- [ ] 将 [`../../ack/llm-usage.md`](../../ack/llm-usage.md) 中的披露落实到最终 Acknowledgments。
- [ ] 增加代码、模型、数据与 model card 的 release-status 声明。

验收标准：每个引用直接支持相邻 claim；最终 bibliography 不包含内部工作备注；投稿披露与实际 agent 使用记录一致。

## 4. 次要优化（P2）

- [ ] 将 `production-grade audio` 替换为具体声学条件。
- [ ] 将 `trains the model to remain silent`、`the decoder learns to ignore` 等无直接消融支持的效果表述改为设计意图。
- [ ] 简化摘要：保留一个主要结果，不罗列全部能力。
- [ ] 在 prompt table 中说明 degradation robustness 使用 plain-ASR prompt，而不是让读者误以为遗漏任务。
- [ ] 在 architecture caption 中区分三阶段 SFT、独立 retriever training 和 GRPO，避免把不同训练阶段写成同时更新。
- [ ] 统一 `Mandarin`、`Chinese`、`ZH` 的使用场景：正文语言名、表格紧凑标签、数据集官方名称分别采用固定口径。
- [ ] 检查所有 evaluative modifiers，只有存在明确比较标准时才保留 `strong`、`competitive`、`leading` 等词。

## 5. 推荐执行顺序

1. 作者确认实际 checkpoint、最终 SFT/GRPO 配方和各表格对应 checkpoint。
2. 修正 references 与最近相关工作，确定可防御的 owned delta。
3. 补 hotword、GRPO 和 TS-ASR 的关键对照实验。
4. 决定论文 one ping，并重排 Model/Data/Training/Experiments。
5. 重写 title、abstract、introduction、conclusion。
6. 重做 teaser 与宽表，完成视觉检查。
7. 补齐复现、release 和 LLM-use disclosure。
8. 运行全文 fact check、regex 检查和完整编译。

## 6. 待作者确认

以下问题没有可靠依据，不能由 agent 自行裁断：

1. 当前全部实验结果最终来自 1.7B 还是 4B checkpoint？
2. 最终 SFT 使用 ZeRO-1 还是 ZeRO-2？每阶段实际 GPU 数、batch size、learning rate 和 epoch 是什么？
3. 最终 GRPO 是否包含 format reward？哪些 headline 表使用了 GRPO checkpoint？
4. 是否已有 SFT vs GRPO、oracle vs retrieval、target-absent negative 的未整理结果？
5. CommonVoice hotword split 和 LLM annotation 是否经过人工抽查？
6. 论文最终定位是 contextual ASR 为主，还是坚持将四种条件作为同等贡献？

## 7. 当前验证快照

- `main.pdf`：22 页。
- `latexmk -pdf -interaction=nonstopmode main.tex`：通过。
- LaTeX warning、未解析 citation/reference：未发现。
- `tools/fact-check-regex.sh egs/amphion-asr-1.7b-2026`：通过。
- 视觉检查：teaser 文字偏小且缺少 whispered ASR；GigaSpeechBench 与 degradation 表在 100% 缩放下偏小；Appendix 末页留白明显。

## 8. Fact check 与写作约束

- Qwen3-ASR 官方说明该系列支持 30 种语言和 22 种中文方言；因此 Mandarin/English 应被描述为本报告当前的评测范围，而不是 backbone 的能力边界：[Qwen3-ASR 官方仓库](https://github.com/QwenLM/Qwen3-ASR)。
- 最近相关工作已确认采用 GLCLAP retrieval、prompt injection 和 GRPO；论文必须正面讨论该重合，而不能只引用 GLCLAP 前置工作。
- 所有 why、归因和机理修改仍需回查 `refs/docs/`；无内部证据时只描述观察与证据边界，不新增 hypothesis。
- 写任何 `sections/*.tex` 后必须重新运行 fact-check regex 和全文编译，并在修改回复中附 Fact check、仿照样板与自作聪明 audit。
