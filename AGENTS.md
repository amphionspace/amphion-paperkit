# AGENTS.md — LLM-ASR Technical Report 协作规范

本文件是该工程所有 AI agent（Cursor / Claude Code / Codex / 任意 SDK 客户端）的硬约束。
人协作者也建议遵守，方便保持工程一致。

工作目录：`~/Documents/llm-asr-report`
编译命令：`PATH=/Library/TeX/texbin:$PATH latexmk -pdf main.tex`
默认沟通语言：中文（代码注释保持英文）

## 配套规则集（必须连同本文件一起遵守）

更细颗粒度的规则在 `.cursor/rules/`，按 Cursor / Claude Code / Codex 通用 rules 协议加载：

| 文件 | 范围 | 说明 |
| --- | --- | --- |
| .cursor/rules/paper-writing.mdc | 始终生效 | 写作风格、章节结构、anti-hallucination、回复必含 fact-check block |
| .cursor/rules/latex-engineering.mdc | *.tex / *.bib / *.cls / *.sty | 文件布局、bib key、单位、编译流程 |
| .cursor/rules/asr-domain.mdc | 始终生效 | WER 上报规范、baseline 选择、数据 / 模型 / 训练 / 鲁棒性的报告项 |
| .cursor/rules/reproducibility.mdc | 始终生效 | 代码 / 模型 / 数据 release 标准、model card、ICLR 2026 LLM 使用披露 |

调研到的所有外部参考源（论文 / blog / github skill / 评审指南）见 `refs/notes/research-references.md`。

---

## 规则 1：所有图一律用 TikZ，多图必须风格统一

### 强制要求

- 所有 figure 一律 TikZ 源码：`figures/<name>.tex`（standalone class），输出 `figures/<name>.pdf`，主文档用 `\includegraphics{figures/<name>.pdf}` 引入。
- 禁止：PowerPoint / Keynote / drawio / Mermaid / Excalidraw 用于最终 paper figure。
- 数据可视化（loss / WER 曲线、柱状图、热力图）优先 pgfplots；如必须用 matplotlib，输出 PDF 矢量并保持字体 sans serif。

### 风格 preset（已建立，必须复用）

存在于 `figures/architecture.tex` 顶部，新增图请复制该 preamble 起手，不要另起调色板。

调色板与 main.tex 的「warm ivory + petrol teal」主题同源：encoder / token 走 teal 冷色族（输入侧），adapter / LLM / prompt / boundary 走 amber / clay 暖色族（核心 + prompt 侧），整张图就有「冷输入 → 暖核心」的方向感。

颜色（HEX）：

| 用途 | 底色 | 描边 | 备注 |
| --- | --- | --- | --- |
| audio / text 通用 | F5EFE3 | 6E6E6E | 暖象牙底 + 中灰描边 |
| encoder | DDE9EC | 2D8294 | 浅 petrol teal + 中 teal 描边 |
| token cell | E5EEF0 | 5E8090 | 浅 teal + slate teal 描边 |
| adapter | F0DFC9 | B07849 | 暖 peach + 哑 clay 描边 |
| LLM | F4E6D5 | A0763C | 暖 cream + 深 tan 描边，全图唯一暖色锚点 |
| prompt 框 | F1ECE3 | 8E7A55 | 浅 cream + 哑 bronze 描边 |
| boundary cell | ECDFD3 | 9C7558 | 暖 peach + 陶土描边 |
| frozen 标记 | 8A8A8A | — | 中灰 |
| trainable 标记 | 2D8294 | — | 主 teal |
| fine-tune 标记 | B07849 | — | clay |

形状与文字：

- 模块圆角 3pt，line width 0.7pt
- 字体 `\sffamily\small`（标题）/ `\sffamily\scriptsize`（注解）
- 箭头 `-Stealth`，line width 0.8pt
- 标签字色 `black!55` 或 `black!70`
- 模块间距 `node distance=0.9cm and 0.85cm`

### 新增图的步骤

1. `cp figures/architecture.tex figures/<new-name>.tex` 起手，删主体 keep preamble
2. 用现有 `tikzset` 样式（`encoder` / `adapter` / `llm` / `audio` / `prompt`），不要重新定义
3. 新增颜色一律加入同一调色板段并起 `c<XXX>` 命名（如 `cEval`），避免散落
4. 编译验证：`pdflatex -interaction=nonstopmode figures/<new-name>.tex`
5. 在 main 用 `\includegraphics[width=\linewidth]{figures/<new-name>.pdf}` 引入
6. 重新 `latexmk -pdf main.tex` 检查整体效果
7. `git add figures/<new-name>.{tex,pdf}` 并 commit

---

## 规则 2：参考资料在 `refs/`，写内容前必须查阅

### 工作流

`refs/` 目录由用户陆续填充：论文 PDF、模型 spec、数据集 doc、benchmark 说明、内部数据统计等。

在「写任何一节」或「画任何一张图」前，agent 必须执行：

1. `ls refs/` 查看当前可用参考
2. 用文件名 / 标题做 keyword 匹配，识别与本次任务相关的文件
3. 用 Read / Grep 读取相关文件
4. 在内容里复用参考的术语、引用其中文献（能定位的话）

### 禁止

- 跳过 `refs/` 直接凭"领域常识"写——哪怕只是一段引言。
- 引用 `refs/` 里没出现 且 自己也无法外部验证 的"事实"。
- 把模型架构数字、数据集 hours、benchmark 分数当默认知识写出，无对照来源。

### 推荐放进 `refs/` 的内容

- 同类系统的 technical report（Whisper / Step-Audio / Kimi-Audio / Seed-ASR / Qwen-Audio / SALMONN / SLAM-ASR）
- 用到的数据集 datasheet（LibriSpeech / GigaSpeech / CommonVoice / FLEURS / AMI 等）
- 内部数据统计表 / 训练日志摘要
- 自有模型的 model card / config 截图
- 特定 benchmark 的 README（评测协议）

---

## 规则 3：每次修改内容前必须做一次 fact check

### 范围

不限于技术细节，包括但不限于：

- 模型架构（层数、hidden dim、参数量、注意力 head 数）
- 数据集（hours、language 数、license、采样率）
- Benchmark（数据集 split、指标定义、SOTA 数字、年份）
- 引用文献（作者全名、年份、会议、arXiv ID）
- 行业术语区分（CTC / RNN-T / AED / Conformer / SSL / weakly-supervised）
- 时间线 / 版本号 / API 行为

### 必须执行的步骤

1. 先查 `refs/` 是否有 ground truth（用 Grep + Read）
2. 再用 WebSearch / WebFetch 验证 1–2 个独立来源（论文 abstract、官方 GitHub README、官方 blog）
3. 不确定的事实一律标 `% TODO: verify ...`，不要编造
4. 数字 / 名字 / 年份必须能对应一个可验证来源；写 placeholder（`?`、`TODO`）也好过写一个没核对过的具体数

### 输出格式（重要）

每次修改回复里必须含一段简短「fact check 摘要」，例如：

> Fact check：
> - LibriSpeech 总时长 960h，来源 refs/librispeech-paper.pdf §3.1，已确认
> - Conformer 论文一作 Anmol Gulati，Interspeech 2020，已确认（arxiv 2005.08100）
> - Seed-ASR 训练数据规模找不到权威数字，已在 03_data.tex 标 TODO

不要只输出 diff 而不解释依据。

---

## 规则 4：抽象层次 — 报告里不写实现细节

技术报告面向研究读者，不是该 repo 的工程文档。所有 code 层细节必须留在 codebase / model card / 附录脚注，正文只描述"概念 / 算法 / 数据 / 数字"。

### 严禁出现在 sections/*.tex 里

- 文件路径：`src/...py`、`local/...py`、`configs/.../*.yaml`、`configs/.../*.json`、`*.sh`、`*.jsonl.gz`、`*.tar.gz`、绝对路径 `/ai_sds_wuzz/...`、`/data/...`
- 类名 / 函数名形式：`EscForegroundMix`、`build_hotwords_for_sample`、`compute_silence_metrics`、`SpeakerPool.load_dataset`
- repo 内部脚本名：`eval_vllm.sh`、`serve_vllm.sh`、`run_rollout_server.sh`、`convert_amphion_to_hf.py`
- 配置字段名当变量用：`train_dataset_samples=1,000,000`、`prompt_hotword_prob=0.8` ← 改成英文概念加括号给数字（"the per-source utterance cap (1\,M)"、"the prompt-hotword keep probability (0.8)"）

### 允许 / 鼓励出现

- 概念性组件名：encoder / projector / boundary prompts / data registry / evaluation harness / rollout server
- 学术变量名：$\rho$, $K$, $\mathrm{SNR}$, $w_\text{acc}$
- 论文级技术词：LoRA, ZeRO-2, GRPO, vLLM, ms-swift（这些是已发表工作 / 库名，不是本 repo 文件）
- 公开数据集 key：LibriSpeech, AISHELL-2, FLEURS, MUSAN, SLR26（学术读者直接认）
- 数字参数本体：seed=124, $K=10$, max\_hotwords=20 ← 但用 `\texttt` 而不是 `\path`，且不带路径前缀

### 改写策略（口径模板）

| 不要写 | 改写成 |
| --- | --- |
| 由 \path{local/prepare\_tsasr\_data.py} 离线合成 | 由 an offline TS-ASR synthesiser 离线合成 |
| \texttt{configs/target\_speaker/train.yaml} 中的 \texttt{train\_dataset\_samples} | the multi-task training mixture's per-source utterance cap |
| \texttt{EscForegroundMix} 在线混音 | an on-the-fly ESC foreground mixer |
| \texttt{src/dataset\_registry.py} 注册表 | a unified dataset registry |
| \texttt{src/compute\_wer.py} | the evaluation harness |
| \texttt{eval\_vllm.sh -w K} | the evaluation client (with $K$ hotwords requested) |

### 触发：每次写 `*.tex` 后必须自检

写完任意 `sections/*.tex` 后，必须用如下 regex 自查（grep / ripgrep），命中即必须改写：

```
\.py|\.sh|\.json|\.yaml|\.jsonl|\.gz|\.tar|src/|local/|configs/|/ai_sds_wuzz/|/data/
```

如该 regex 在 `sections/*.tex` 里有 match，本轮 commit 不应通过。

---

## 规则 5：refs/docs 是原料库，不是论文素材；不清楚要问

### 文档属性识别

`refs/docs/*.md`（`plan.md` / `model_arch.md` / `task_prompts.md` / `train_eval_data.md` 等）是团队内部的实验记录与工作 plan，典型特征：

- 绝对路径（`/ai_sds_wuzz/...`）、conda env、HPC 账号、git 分支
- 代码类名 / 函数名 / 配置字段
- 待办与 `@人名` 分配
- 调试中间结果、占位 TODO、未结案问题、已废弃实验

它们提供事实和数字，但不提供 paper 的句式 / 叙述 / 卖点。把 md 当"原料库"用，不要当成"草稿"用。

### 提炼 vs 照搬

读 `refs/docs` 时只做两件事：

1. 抽事实：hours、参数量、benchmark 数字、阶段时间线、最终采用的 prompt 模板、最终采用的训练配置
2. 抽卖点：把"目标 / 已完成"翻译成 1–2 句 paper-level claim，例如：
    - 内部："中文热词测试集 SOTA"  →  claim："we surpass the strongest open contextual ASR baseline on an in-house Mandarin hotword benchmark"
    - 内部："libri2mix 较差，原因未排查"  →  这不是卖点，可能进 Limitations，先问

不搬路径、不抄类名、不复述调试过程 —— 与规则 4 联动。

### 不清楚要问，不要凭原料硬猜

`refs/docs` 是动态工作记录，常包含 未结案 / 已废弃 / 占位 / 实验失败 的痕迹。任何要进 paper 的 claim，遇到下列情况必须停下来问用户，不要自行裁断：

- 某个测试集结果在 refs 里只出现一次，没说是 final 还是 ablation
- `plan.md` 里某项标"测试进度：无"或"未排查"，但你想拿来做卖点
- `task_prompts.md` / `model_arch.md` 里出现多个版本，没说哪个是最终采用
- `refs/docs` 里的数字与 `refs/notes/papers` 里同来源的官方数字不一致
- 某段描述无法判断是已落地、还是 plan 里的待办（"@xxx 动作：…"）
- 用户口头没说过、refs 里也没明确背书，但你"觉得是好卖点"的内容

提问格式（写进回复，而不是直接动笔）：

> 问：`refs/docs/plan.md` 中 libri2mix 较差未排查；这个测试集是否进 headline 表？是否仅在 Limitations 提及？

### 禁止

- 把 `plan.md` 的待办（"@xxx 动作：…"）误读成已完成结果
- 把 `task_prompts.md` 里的 prompt 调试历史抄进 Methods（只保留最终模板，与规则 4、ASR 域规则联动）
- 把 `model_arch.md` 里张量级细节 / 类名 / 路径搬进 paper
- 把 `plan.md` 的"目标 / 动作 / 谁负责"原样翻译成英文段落

---

## 规则 6：写法仿照同类文献，不要凭原料自由发挥

### 核心原则

paper 的「风格 / 结构 / 段落分配 / 表格组织 / 卖点句式」一律仿照 `refs/notes/papers/` 或外部同类技术报告。`refs/docs` 只提供 fact，不提供 form。

不要凭 `refs/docs` 内容原创叙述结构 —— 最常见的失败模式是把"项目周报语气"或"中文工作记录直译"带进英文 paper（同时违反规则 4 + 规则 6）。

### 对照表：哪个文献当哪节的样板

| 章节 | 主要参考 | 借鉴什么 |
| --- | --- | --- |
| Architecture / Overview | SLAM-ASR、Qwen2-Audio | 三模块叙述（Encoder + Projector + LLM）+ 模块表 |
| Methods 章节 ordering | Seed-ASR、Step-Audio 2 | Section 安排、热词与目标说话人小节的拆分方式 |
| Data 章节 | Kimi-Audio、Whisper | 按 source 列表 + per-source hours 表 + 清洗 pipeline 描述 |
| Prompt / Task design | Qwen-Audio | 任务清单表 + literal prompt template |
| Experiments 主表 | Seed-ASR、Whisper | Headline 表 + 对比 baseline + ablation 组织 |
| Robustness | Whisper §3.7 | SNR sweep + 噪声集对比 |
| Contextual ASR | Seed-ASR 热词小节 | 卖点句式 + U-WER / B-WER 分指标 |
| Target-speaker ASR | 最近的 TS-ASR / 多说话人论文 | 评测协议 + speaker prompt 表述 |

样板源头：先查 `refs/notes/papers/`；找不到再 WebSearch / WebFetch 找该论文的官方 PDF；都找不到就停下问用户，不要"凭印象写"。

### 工作流（开始写任一新章节前）

1. 找出 1 篇最相近的样板文献，定位到对应章节
2. 把样板章节的"段落主题树"复述一遍（每段讲什么），这就是本节的骨架
3. 仿样板的句式 / 表格列名 / 命名约定填空
4. 用 `refs/docs` 抽到的事实做填充
5. 通读检查：有没有从 `refs/docs` 直接译过来的句子？有就重写

### 触发：fact-check block 必加一行

> 仿照样板：`<paper key>`（`refs/notes/papers/...`）§X.Y

如果没有样板，要明确写"无样板，凭领域常识"，然后先停下来问用户确认是否继续。

### 不要做的事

- 不看参考文献就开始原创一套叙述
- 仿写 "翻译化" —— 直接把 `refs/docs` 中文段落英译当 paper 段落
- 把 `plan.md` 的工作流条目（"目标 / 动作 / 谁负责"）原样译成 paper 句子
- 仿照过头 —— 直接抄样板原文（reword 但不抄词序、不抄独特短语）

---

## 规则 7：通用约定

- 修改后立即 git commit，commit message 用 conventional commit 前缀：`feat(...)` / `fix(...)` / `chore(...)` / `docs(...)` / `refactor(...)`
- commit message 主体说明 why，不只 what
- 不向 main.pdf 写 git（已在 .gitignore），但 figure PDF 要 commit（用于 reproducibility）
- 引用一律 `\cite{key}`（IEEE numeric style，xlance.cls 默认），bib key 形式 `<lastname><year><firstword>`，例：`gulati2020conformer`
- 数字带千位分隔符用 `10{,}000`，单位用 `\,`：`960\,h`、`16\,kHz`
