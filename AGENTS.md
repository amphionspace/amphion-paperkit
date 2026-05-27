# AGENTS.md — Amphion PaperKit 协作规范

本文件是 Amphion PaperKit 框架所有 AI agent（Cursor / Claude Code / Codex / 任意 SDK 客户端）的硬约束。
人协作者也建议遵守，方便保持工程一致。

工作目录：`~/Documents/amphion-paperkit`（mono-repo 根；具体报告住在 `egs/<slug>/`）
编译命令：`cd egs/<slug> && PATH=/Library/TeX/texbin:$PATH latexmk -pdf main.tex`
一键编全部：`tools/build-all.sh`
默认沟通语言：中文（代码注释保持英文）

## 仓库形态

mono-repo + icefall 风格 `egs/` 叶子节点。每份报告自包含；公共能力（LaTeX 模板、AI 协作规则、共享参考资料、helper scripts、CI）在顶层。详见顶层 [README.md](README.md) 与 [egs/README.md](egs/README.md)。

```
amphion-paperkit/
├── template/      amphion.cls + asr-macros.sty + IEEEtran2.bst + venues.bib
├── tools/         new-report.sh / build-all.sh / fact-check-regex.sh / fetch-refs.py / schemas/
├── figures/       公共 TikZ preset（_palette.tex / architecture-skeleton.tex）
├── references.bib 顶层 starter cites（仅基础公认文献）
├── .cursor/rules/ 公共写作 / 工程规则（含 _sources.md 方法学源汇总）
├── egs/_skeleton/ 新报告脚手架（含 refs/ 骨架；不要直接编辑作发布内容）
└── egs/<slug>/    单份报告：main.tex / sections / figures / tables / refs / ack
```

## 配套规则集（必须连同本文件一起遵守）

更细颗粒度的规则在 `.cursor/rules/`，按 Cursor / Claude Code / Codex 通用 rules 协议加载：

| 文件 | 范围 | 说明 |
| --- | --- | --- |
| .cursor/rules/paper-writing.mdc | 始终生效 | 写作风格、章节结构、anti-hallucination、回复必含 fact-check block |
| .cursor/rules/latex-engineering.mdc | *.tex / *.bib / *.cls / *.sty | 文件布局、bib key、单位、编译流程 |
| .cursor/rules/asr-domain.mdc | 始终生效 | WER 上报规范、baseline 选择、数据 / 模型 / 训练 / 鲁棒性的报告项 |
| .cursor/rules/reproducibility.mdc | 始终生效 | 代码 / 模型 / 数据 release 标准、model card、ICLR 2026 LLM 使用披露 |
| .cursor/rules/multi-report.mdc | 始终生效 | mono-repo 边界：当前在哪个 egs / 是否要改公共层 / 模板 fork 流程 |

调研到的所有外部参考源（论文 / blog / github skill / 评审指南）见 [`.cursor/rules/_sources.md`](.cursor/rules/_sources.md)。

---

## 规则 1：所有图一律用 TikZ，多图必须风格统一

### 强制要求

- 所有 figure 一律 TikZ 源码：`egs/<slug>/figures/<name>.tex`（standalone class），输出 `egs/<slug>/figures/<name>.pdf`，主文档用 `\includegraphics{figures/<name>.pdf}` 引入（路径相对当前 egs 的 main.tex）。
- 禁止：PowerPoint / Keynote / drawio / Mermaid / Excalidraw 用于最终 paper figure。
- 数据可视化（loss / WER 曲线、柱状图、热力图）优先 pgfplots；如必须用 matplotlib，输出 PDF 矢量并保持字体 sans serif。

### 风格 preset（已建立，必须复用）

公共调色板与 tikzset 在顶层 `figures/_palette.tex`；最简起手范本在顶层 `figures/architecture-skeleton.tex`。新增图请 `\input{_palette}` 复用，不要另起调色板（也不要在每张图里复制粘贴整段颜色定义）。

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

1. 在当前 egs 下：`cp ../../figures/architecture-skeleton.tex egs/<slug>/figures/<new-name>.tex` 起手
2. 在新文件 preamble 中保留 `\input{_palette}`（路径会通过 latexmkrc 的 TEXINPUTS 解析到顶层 `figures/_palette.tex`），不要重新定义颜色或样式
3. 用现有 `tikzset` 样式（`encoder` / `adapter` / `llmbox` / `tokenizer` / `boundbox` / ...），不要重新定义
4. 新增颜色一律加入顶层 `figures/_palette.tex` 同一调色板段并起 `c<XXX>` 命名（如 `cEval`）；新颜色受顶层公共层管控（与规则 8 联动）
5. 编译验证：`cd egs/<slug>/figures && pdflatex -interaction=nonstopmode <new-name>.tex`
6. 在 main 用 `\includegraphics[width=\linewidth]{figures/<new-name>.pdf}` 引入
7. `cd egs/<slug> && latexmk -pdf main.tex` 检查整体效果
8. `git add egs/<slug>/figures/<new-name>.{tex,pdf}` 并 commit

---

## 规则 2：参考资料在 `egs/<slug>/refs/`，写内容前必须查阅

### 单层结构（每份 egs 自维护）

| 路径 | 范围 | git 跟踪 |
| --- | --- | --- |
| `egs/<slug>/refs/docs/` | 内部 plan / model_arch / task_prompts / train_eval_data | tracked |
| `egs/<slug>/refs/internal/` | 数据统计、内部 model card、训练日志摘要 | tracked |
| `egs/<slug>/refs/notes/papers/INDEX.yaml` | 论文清单真相源（file/url/sha256/group/usage） | tracked |
| `egs/<slug>/refs/notes/papers/INDEX.md` | 论文清单人类视图（由 yaml 派生） | tracked |
| `egs/<slug>/refs/notes/papers/*.pdf` | 论文 PDF | gitignored |
| `egs/<slug>/refs/notes/commercial-systems.md` | 闭源 / 商用 ASR / TTS / Audio-LLM 系统的官方信息源 | tracked |
| `egs/<slug>/refs/datasets/INDEX.yaml` | 数据集清单真相源 | tracked |
| `egs/<slug>/refs/datasets/INDEX.md` | 数据集清单人类视图 | tracked |
| `egs/<slug>/refs/datasets/*.pdf` | 数据集 datasheet PDF | gitignored |
| `egs/<slug>/refs/leaderboards/` | 评测榜单截图（按需） | tracked |
| `egs/<slug>/refs/README.md` | 本目录说明 | tracked |

通用写作方法学源（评审 / 复现 / 写作建议 / agent 协作 / LaTeX 工程）见 [`.cursor/rules/_sources.md`](.cursor/rules/_sources.md)，所有报告共享一份；不在 egs refs 里。

### 工作流

首次准备 PDF（脚本通过 PEP 723 inline metadata 声明依赖，由 [uv](https://docs.astral.sh/uv/) 自动建虚拟环境）：

```bash
uv run tools/fetch-refs.py egs/<slug>
```

脚本会按 INDEX.yaml 并行下载（默认 4 路）+ sha256 校验 + 失败 / mismatch 报告。后续 sha256 不一致会硬失败（URL 漂移 / 文件损坏的早期信号）。

在「写任何一节」或「画任何一张图」前，agent 必须执行：

1. `ls egs/<slug>/refs/` 看当前可用参考
2. 用文件名 / 标题 / INDEX.yaml 的 `usage` 字段做 keyword 匹配，识别与本次任务相关的文件
3. 用 Read / Grep 读取相关 PDF / md
4. 在内容里复用参考的术语、引用其中文献

### 禁止

- 跳过 `egs/<slug>/refs/` 直接凭"领域常识"写——哪怕只是一段引言。
- 引用 `refs/` 里没出现 且 自己也无法外部验证 的"事实"。
- 把模型架构数字、数据集 hours、benchmark 分数当默认知识写出，无对照来源。
- 加新 PDF 时只 download 不更新 INDEX.yaml —— `tools/fetch-refs.py` 是按 yaml 驱动的，没在 yaml 里 declare 的 PDF 等同于不存在。

### 推荐放进 `egs/<slug>/refs/` 的内容

- 同类系统的 technical report（Whisper / Step-Audio / Kimi-Audio / Seed-ASR / Qwen-Audio / SALMONN / SLAM-ASR）→ `notes/papers/`
- 用到的数据集 datasheet（LibriSpeech / GigaSpeech / CommonVoice / FLEURS / AMI 等）→ `datasets/`
- 闭源系统资料（Doubao / gpt-4o-transcribe 等）→ `notes/commercial-systems.md`
- 内部数据统计表 / 训练日志摘要 → `internal/`
- 自有模型的 model card / config 截图 → `internal/`
- 特定 benchmark 的 README（评测协议）→ `leaderboards/` 或 `notes/papers/`

### 加新论文 / 数据集 PDF 的步骤

1. 在 `egs/<slug>/refs/{notes/papers,datasets}/INDEX.yaml` 加 entry，`sha256: null` 待回填
2. 跑 `uv run tools/fetch-refs.py egs/<slug>`，脚本下载并把 sha256 写回 yaml
3. 同步 `INDEX.md`（人类视图，加一行表格）
4. `git add` 两份 INDEX.yaml + 两份 INDEX.md，commit

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

1. 先查 `egs/<slug>/refs/` 是否有 ground truth（用 Grep + Read；INDEX.yaml 是 PDF 清单的真相源）
2. 再用 WebSearch / WebFetch 验证 1–2 个独立来源（论文 abstract、官方 GitHub README、官方 blog）
3. 不确定的事实一律标 `% TODO: verify ...`，不要编造
4. 数字 / 名字 / 年份必须能对应一个可验证来源；写 placeholder（`?`、`TODO`）也好过写一个没核对过的具体数

### 输出格式（重要）

每次修改回复里必须含一段简短「fact check 摘要」，例如：

> Fact check：
> - LibriSpeech 总时长 960h，来源 egs/amphion-asr-2026/refs/datasets/panayotov2015-librispeech.pdf §3.1，已确认
> - Conformer 论文一作 Anmol Gulati，Interspeech 2020，已确认（arxiv 2005.08100）
> - Seed-ASR 训练数据规模找不到权威数字，已在 03_data.tex 标 TODO

不要只输出 diff 而不解释依据。

---

## 规则 4：抽象层次 — 报告里不写实现细节

技术报告面向研究读者，不是该 repo 的工程文档。所有 code 层细节必须留在 codebase / model card / 附录脚注，正文只描述"概念 / 算法 / 数据 / 数字"。

### 严禁出现在 `egs/<slug>/sections/*.tex` 里

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

写完任意 `egs/<slug>/sections/*.tex` 后，必须运行：

```bash
tools/fact-check-regex.sh egs/<slug>
```

它对该 egs 的 `sections/` 跑如下 regex，命中即必须改写：

```
\.py|\.sh|\.json|\.yaml|\.jsonl|\.gz|\.tar|src/|local/|configs/|/ai_sds_wuzz/|/data/
```

CI（`.github/workflows/lint.yml`）在每次 push / PR 也会跑同一脚本扫所有 active egs。脚本退出非 0 即视为本轮 commit 不应通过。

---

## 规则 5：egs/<slug>/refs/docs 是原料库，不是论文素材；不清楚要问

### 文档属性识别

`egs/<slug>/refs/docs/*.md`（`plan.md` / `model_arch.md` / `task_prompts.md` / `train_eval_data.md` 等）是该报告团队内部的实验记录与工作 plan，典型特征：

- 绝对路径（`/ai_sds_wuzz/...`）、conda env、HPC 账号、git 分支
- 代码类名 / 函数名 / 配置字段
- 待办与 `@人名` 分配
- 调试中间结果、占位 TODO、未结案问题、已废弃实验

它们提供事实和数字，但不提供 paper 的句式 / 叙述 / 卖点。把 md 当"原料库"用，不要当成"草稿"用。

### 提炼 vs 照搬

读 `egs/<slug>/refs/docs` 时只做两件事：

1. 抽事实：hours、参数量、benchmark 数字、阶段时间线、最终采用的 prompt 模板、最终采用的训练配置
2. 抽卖点：把"目标 / 已完成"翻译成 1–2 句 paper-level claim，例如：
    - 内部："中文热词测试集 SOTA"  →  claim："we surpass the strongest open contextual ASR baseline on an in-house Mandarin hotword benchmark"
    - 内部："libri2mix 较差，原因未排查"  →  这不是卖点，可能进 Limitations，先问

不搬路径、不抄类名、不复述调试过程 —— 与规则 4 联动。

### 不清楚要问，不要凭原料硬猜

`egs/<slug>/refs/docs` 是动态工作记录，常包含 未结案 / 已废弃 / 占位 / 实验失败 的痕迹。任何要进 paper 的 claim，遇到下列情况必须停下来问用户，不要自行裁断：

- 某个测试集结果在 refs 里只出现一次，没说是 final 还是 ablation
- `plan.md` 里某项标"测试进度：无"或"未排查"，但你想拿来做卖点
- `task_prompts.md` / `model_arch.md` 里出现多个版本，没说哪个是最终采用
- `egs/<slug>/refs/docs` 里的数字与同一 egs `refs/notes/papers/` 中官方 PDF 的数字不一致
- 某段描述无法判断是已落地、还是 plan 里的待办（"@xxx 动作：…"）
- 用户口头没说过、refs 里也没明确背书，但你"觉得是好卖点"的内容

提问格式（写进回复，而不是直接动笔）：

> 问：`egs/amphion-asr-2026/refs/docs/plan.md` 中 libri2mix 较差未排查；这个测试集是否进 headline 表？是否仅在 Limitations 提及？

### 禁止

- 把 `plan.md` 的待办（"@xxx 动作：…"）误读成已完成结果
- 把 `task_prompts.md` 里的 prompt 调试历史抄进 Methods（只保留最终模板，与规则 4、ASR 域规则联动）
- 把 `model_arch.md` 里张量级细节 / 类名 / 路径搬进 paper
- 把 `plan.md` 的"目标 / 动作 / 谁负责"原样翻译成英文段落

---

## 规则 6：写法仿照同类文献，不要凭原料自由发挥

### 核心原则

paper 的「风格 / 结构 / 段落分配 / 表格组织 / 卖点句式」一律仿照本 egs `refs/notes/papers/` 中的同类技术报告（或外部同类）。`egs/<slug>/refs/docs` 只提供 fact，不提供 form。

不要凭 `egs/<slug>/refs/docs` 内容原创叙述结构 —— 最常见的失败模式是把"项目周报语气"或"中文工作记录直译"带进英文 paper（同时违反规则 4 + 规则 6）。

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

样板源头：先查本 egs `refs/notes/papers/`（用 `INDEX.md` / `INDEX.yaml` 的 usage 字段定位）；找不到再 WebSearch / WebFetch 找该论文的官方 PDF；都找不到就停下问用户，不要"凭印象写"。

### 工作流（开始写任一新章节前）

1. 找出 1 篇最相近的样板文献，定位到对应章节
2. 把样板章节的"段落主题树"复述一遍（每段讲什么），这就是本节的骨架
3. 仿样板的句式 / 表格列名 / 命名约定填空
4. 用 `egs/<slug>/refs/docs` 抽到的事实做填充
5. 通读检查：有没有从 `egs/<slug>/refs/docs` 直接译过来的句子？有就重写

### 触发：fact-check block 必加一行

> 仿照样板：`<paper key>`（`egs/<slug>/refs/notes/papers/...`）§X.Y

如果没有样板，要明确写"无样板，凭领域常识"，然后先停下来问用户确认是否继续。

### 不要做的事

- 不看参考文献就开始原创一套叙述
- 仿写 "翻译化" —— 直接把 `egs/<slug>/refs/docs` 中文段落英译当 paper 段落
- 把 `plan.md` 的工作流条目（"目标 / 动作 / 谁负责"）原样译成 paper 句子
- 仿照过头 —— 直接抄样板原文（reword 但不抄词序、不抄独特短语）

---

## 规则 7：通用约定

- 修改后立即 git commit，commit message 用 conventional commit 前缀：`feat(...)` / `fix(...)` / `chore(...)` / `docs(...)` / `refactor(...)`；scope 用最小相关层级（`feat(template): ...` / `feat(amphion-asr): ...` / `chore(common): ...`）
- commit message 主体说明 why，不只 what
- 不向 `egs/<slug>/main.pdf` 写 git（已在 .gitignore），但 figure PDF（`egs/<slug>/figures/<name>.pdf`）要 commit（用于 reproducibility）
- 引用一律 `\cite{key}`（IEEE numeric style，`template/amphion.cls` 默认），bib key 形式 `<lastname><year><firstword>`，例：`gulati2020conformer`
- 数字带千位分隔符用 `10{,}000`，单位用 `\,`：`960\,h`、`16\,kHz`

---

## 规则 8：跨 egs 与模板边界

### 单份报告自包含

每个 `egs/<slug>/` 完全自包含。`main.tex` / `sections` / `figures` / `tables` / `refs` / `ack` 都不应跨 egs `\input{...}` 或读取另一个 egs 的内容。"借鉴另一份报告的某段叙述 / 某张图"不是合法理由 —— 把它抽到公共层（`figures/_palette.tex`、`template/...`、`.cursor/rules/_sources.md`）才是；论文 PDF 这种"领域参考资料"则在两份 egs 各自维护一份 INDEX.yaml entry（PDF 文件可以共存于两份 refs/，用同一 sha256 验证）。

### 公共层修改流程

修改公共层（`template/*`、`figures/_palette.tex`、`figures/architecture-skeleton.tex`、顶层 `references.bib`、`tools/*`、`tools/schemas/*`、`.cursor/rules/*`、`egs/_skeleton/*`）影响所有 active egs。所有此类修改必须：

1. 在 `template/CHANGELOG.md` 追加一条 entry，描述"为什么改、改了什么、是否破坏向后兼容"
2. 编译 `egs/_skeleton` 与所有 active egs（用 `tools/build-all.sh`）；**视觉无回归** 才能 commit
3. 如果是破坏性变更（`amphion.cls` 中重命名 / 删除 macro、改 option 默认值），bump `template/CHANGELOG.md` 中的 minor / major 版本号，并在每个受影响 egs 的 `REPORT.md` 的 `depends_on_template` 字段更新到新版本号
4. commit scope 用 `feat(template): ...` / `chore(common): ...`，不要混入某个 egs 的 commit

### 起一份新报告

不要手工 cp `_skeleton`，用脚本：

```bash
tools/new-report.sh <slug> --title "..." --shortname "..." --author "..."
```

它会替换 `<<NAME>>` 占位符并提示后续步骤。

### 在叶子层只能动叶子

agent 在 `egs/<slug>/` 工作时，原则上不要改 `template/` / `figures/_palette.tex` / 顶层 `references.bib` / `tools/`。如果发现公共层确实需要变（比如新增颜色、新增数学宏），停下来与用户确认，单开一个 PR / commit 走规则 8 的流程，不要混进当前报告的 commit。

### 不要在叶子里建公共层副本

不要把 `template/` 或 `figures/_palette.tex` 或顶层 `references.bib` 的副本拷到 `egs/<slug>/` 内自用。所有报告共享同一份公共层，这是 mono-repo 的核心收益。

---

## 规则 9：不自作聪明 — refs/docs 没说的 why / 归因 / 机理一律不补

### 核心原则

看到一个反常实验数字（FLEURS-en 30% WER、LibriMix 性能差、hotword 五个最优、训练只用 ZeRO-2 而非 ZeRO-3）就给出 mechanism 解释，是 agent 常见的"自作聪明"失败模式。

准则：

- 如果 `egs/<slug>/refs/docs` 没有写明这个 why / 归因 / 机理，agent 一律不要自创解释。
- 如果 `refs/docs` 明确写了「原因未排查」「论文里一笔带过」之类字眼，agent 必须遵守，不要绕过该指示去补假设性归因。

### 工作流

写「Discussion / Analysis / Limitations」类涉及 why 的段落前：

1. 在 `egs/<slug>/refs/docs/` 中检索该现象的 keyword（如 `LibriMix` / `FLEURS` / `ZeRO` / `hotword` / `repetition`），看作者是否已写归因或机理；
2. 若有，如实复述（语言强度也不要超过 refs/docs 的原始判断），在 fact-check block 列出来源行号；
3. 若没有，按下列模板一笔带过，不要发挥：
    - 「the underlying cause has not yet been diagnosed」
    - 「a controlled ablation is on the agenda for the next iteration」
    - 「a mechanistic decomposition is left to future work」
    - 「the cause has not been investigated; a qualitative error-type breakdown is the planned next step」

### 禁用写作模式（无 refs/docs 背书时）

下列短语在正文出现且无 refs/docs 对应支撑，一律视为违规：

- 「We attribute X to Y」
- 「We suspect / believe / hypothesize / posit / conjecture that ...」
- 「This is consistent with the intuition that ...」
- 「The likely cause is ...」/「The remaining suspects are ...」
- 「indicating that ... works as intended」（除非该 design-test 闭环在 refs/docs 中已被明确写下）
- 「matches the residual patterns reported by ...」（无 cite 支撑时）
- 「Why X」段落标题 + 自创机理（除非 refs/docs 已经明确给出原因）

### 触发：fact-check block 必加一行

> 自作聪明 audit：所有 why / 归因 / 机理段落已对照 `refs/docs/<file>`，未背书项一笔带过，无新增 hypothesis。

### 与既有规则的关系

- 与规则 3（fact-check）联动：fact-check block 必须显式标注 why 的来源行号，或明确写"refs/docs 未背书，已一笔带过"。
- 与规则 5（refs/docs 是原料库，不清楚要问）联动：refs/docs 写「未排查」「论文里一笔带过」是最高优先级指示，不要绕过。
- 与 `.cursor/rules/paper-writing.mdc` §3 hedge 部分一致：hedge 用语（"suggests", "indicates", "may"）不能成为「写未经核实 mechanism」的借口；hedge 的作用是把已有证据的判断说得克制，不是把无证据的猜测包装成"看上去克制"的论断。
