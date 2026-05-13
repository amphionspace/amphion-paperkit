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

存在于 `figures/architecture.tex` 顶部，新增图请复制该 preamble 起手，不要另起调色板：

颜色（HEX）：

| 用途 | 底色 | 描边 |
| --- | --- | --- |
| audio / text 通用 | F2F4F7 | 黑40 |
| encoder | D9E5F4 | 4A7BB7 |
| adapter | D9F0DA | 4F9D58 |
| LLM | FBE3CC | D08A3F |
| prompt 框 | F7F2E8 | B89464 |
| frozen 标记 | 8A8A8A | — |
| trainable 标记 | 2F6FB1 | — |
| fine-tune 标记 | 2F8E40 | — |

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

## 规则 4：通用约定

- 修改后立即 git commit，commit message 用 conventional commit 前缀：`feat(...)` / `fix(...)` / `chore(...)` / `docs(...)` / `refactor(...)`
- commit message 主体说明 why，不只 what
- 不向 main.pdf 写 git（已在 .gitignore），但 figure PDF 要 commit（用于 reproducibility）
- 引用一律 `\citep{key}` / `\citet{key}`，bib key 形式 `<lastname><year><firstword>`，例：`gulati2020conformer`
- 数字带千位分隔符用 `10{,}000`，单位用 `\,`：`960\,h`、`16\,kHz`
