# template/ Changelog

`template/amphion.cls` 是从 [X-LANCE LaTeX pre-print template](https://github.com/X-LANCE/LaTeX-Template-for-X-LANCE-Lab) (`xlance.cls` v0.2.2-20260304) fork 而来。原模板继承的 arxiv-style license 见 `LICENSE_arxiv-style.txt`。

修改约束：每次改动 amphion.cls / asr-macros.sty / venues.bib 都必须在此追加一条 entry，并通过编译至少 2 个 egs（amphion-asr-2026 + _skeleton）确认无回归。详见 `AGENTS.md` 规则 8。

---

## v0.1 — 2026-05-14

首次 fork。从 xlance.cls 整体迁移到 amphion.cls，吸收原 main.tex preamble 中"实际上覆盖了模板默认值"的 ~50 行代码。

class 文件层面的具体变更：

- ProvidesClass 由 `xlance` 改为 `amphion`；保留头部对原 X-LANCE 模板的 attribution。
- 内部 namespace 全量重命名：所有 `\if@xlance@...` / `\@xlance@...` / `\xlance@...` 内部宏与 `xlance@base` listing style 改为 `\if@amphion@...` / `\@amphion@...` / `\amphion@...` / `amphion@base`，避免与上游同名 class 共存时的污染。
- 新增 Theme C "amphion" (warm ivory `F5EFE3` + petrol teal `0E5A6F` 主色族 + amber/clay `A86232` 辅色族) 作为新默认主题；不带 option 时即激活。原 X-LANCE 红主题 (`themeAcolor@*`) 经 `[xlance]` option 切换；OpenDFM 蓝紫主题 (`themeBcolor@*`) 经 `[opendfm]` option 切换。三选一互斥。
- 新增正交 option `[withlogo]`：默认关闭 first-page header 的 X-LANCE / OpenDFM logo 渲染；用户传 `[withlogo]` 时恢复上游行为（与 `[opendfm]` / `[xlance]` 正交叠加）。
- `firstpage` 与 `body` page styles 的 `\headrulewidth` 默认 0pt（无水平分隔线）；`[withlogo]` 时恢复上游 0.4pt。
- 默认加载 `url` package 以提供 `\path` 命令。
- 所有 logo 路径从 `xlance/assets/logos/...` 重写为 `template/assets/logos/...`。

伴生文件：

- 新增 `asr-macros.sty`：抽出原 main.tex 中的 ASR 数学宏 (`\wer / \cer / \mer / \hotwerN`)。ASR / Audio-LLM 报告显式 `\usepackage{template/asr-macros}`；非 ASR 报告（如 TTS）不加载。

不影响：

- `IEEEtran2.bst`、`venues.bib`：仅文件位置从 `xlance/` 移到 `template/`，内容不变。
- `assets/logos/*.png`：内容不变。
