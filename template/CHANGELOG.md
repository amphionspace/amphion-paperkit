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

---

## v0.2 — 2026-05-14 — refs/ 下沉到 egs

公共层与各 egs 之间的参考资料组织重构。**这是一次破坏性变更**：所有现存 egs 必须按下列检查表迁移；新报告由 `tools/new-report.sh` 自动产出新结构。

公共层的具体变更：

- 删除顶层 `refs/`（原含 `notes/papers/` + `notes/research-references.md` + `notes/commercial-systems.md` + `datasets/` + `leaderboards/` + `README.md`）。理由：可预见会有 5+ 份 egs，每份 egs 自带的论文 / 数据集 / 商用系统资料并非完全交集，强行公共会污染所有报告的引用面；下沉后每份报告自维护，启动新报告时由 `_skeleton` 拷骨架。
- 新增 `.cursor/rules/_sources.md`：原 `refs/notes/research-references.md` 的写作 / 复现 / 评审 / agent / LaTeX 工程方法学源汇总上提。该文件作为 `.cursor/rules/*.mdc` 与 `AGENTS.md` 各项规则的脚注，所有 egs 共享一份；下划线前缀 (`_`) 表示 Cursor 不会把它当 rule 加载。
- 新增 `tools/schemas/refs-index.schema.json`：JSON Schema (draft-07) 描述 `INDEX.yaml` 结构（groups + papers，schema 校验 + papers[*].group 与 groups[*].id 交叉校验）。
- 新增 `tools/fetch-refs.py`：按 `egs/<slug>/refs/{notes/papers,datasets}/INDEX.yaml` 并行下载 PDF + sha256 校验 + 首次回填 + MISMATCH 硬失败。
- 新增 `tools/requirements-fetch.txt`：fetch-refs.py 的 Python 依赖（PyYAML + jsonschema）。
- 修改 `.gitignore`：`refs/notes/papers/*.pdf` → `egs/*/refs/notes/papers/*.pdf` + `egs/*/refs/datasets/*.pdf`。所有论文 / 数据集 PDF 一律不入 git。
- 修改 `AGENTS.md` 第 19 / 38 行（结构图 + 规则源链接）；规则 2 全段重写为单层 egs/<slug>/refs 表 + `tools/fetch-refs.py` 工作流；规则 3 fact-check 例子路径；规则 6 多处 `refs/notes/papers/` → 本 egs `refs/notes/papers/`；规则 8 公共层定义补充 `tools/schemas/*` / `.cursor/rules/*` / `egs/_skeleton/*`。
- 修改 `.cursor/rules/paper-writing.mdc` lookup order + fact-check 例子路径。
- 修改 `.cursor/rules/multi-report.mdc` 公共层定义（移除 `refs/`，加入 `tools/schemas/` 与 `.cursor/rules/_sources.md`）。
- 修改 `egs/_skeleton/refs/`：扩展为完整骨架（`notes/papers/{INDEX.yaml,INDEX.md,.gitkeep}` + `notes/commercial-systems.md` + `datasets/{INDEX.yaml,INDEX.md,.gitkeep}` + `leaderboards/.gitkeep` + `README.md`），新报告启动即可用。

每 egs 的影响 / 迁移检查表：

- `egs/amphion-asr-2026/`：本次 PR 内同步迁移完成。
  - `refs/notes/papers/{INDEX.yaml + INDEX.md}` 已从原顶层 `refs/notes/papers/INDEX.md` 转 yaml，46 条 entry，sha256 全部回填；46 个 PDF 从 `refs/notes/papers/` 物理迁入。
  - `refs/datasets/{INDEX.yaml + INDEX.md}` 已从原顶层 `refs/datasets/INDEX.md` 转 yaml，31 条 entry，sha256 全部回填；31 个 PDF 物理迁入。
  - `refs/notes/commercial-systems.md` 物理迁入。
  - `refs/leaderboards/.gitkeep` `git mv` 保留历史。
  - `refs/README.md` 重写。
- 其他 active egs：本 PR 时刻只有一份 active egs，无需额外迁移；规划中的 amphion-tts-2026 / amphion-omni-2026 启动时直接由新 `_skeleton` 拷出。

被破坏的兼容性（PR 后必须手动修复的潜在外部引用）：

- 任何引用 `refs/notes/papers/...pdf` / `refs/datasets/...pdf` / `refs/notes/research-references.md` / `refs/notes/commercial-systems.md` 的外部文档（仅 README / AGENTS / rules 已在本 PR 同步），如有 user-private 笔记 / external doc 需手动改。
- 任何 CI / 脚本依赖顶层 `refs/` 路径会失败 —— 当前没有此类依赖。

参考 `egs/amphion-asr-2026/refs/README.md` 与 `tools/fetch-refs.py` 顶部 docstring 看新工作流细节。

---

## v0.3 — 2026-05-15 — fetch-refs 切换到 uv (PEP 723)

`tools/fetch-refs.py` 从"`pip install -r requirements-fetch.txt` + `python ...`" 工作流切到"`uv run ...`"工作流。脚本头部按 PEP 723 inline metadata 声明 PyYAML + jsonscheme 依赖，[uv](https://docs.astral.sh/uv/) 第一次运行时建临时 venv 并缓存。**非破坏性**：脚本本身仍是合法 Python，stock `python tools/fetch-refs.py ...` 在已有 venv 里也能跑。

具体变更：

- `tools/fetch-refs.py` 头部加 `# /// script` PEP 723 块（requires-python>=3.9 + dependencies = PyYAML>=6.0 + jsonschema>=4.0）；shebang 改 `#!/usr/bin/env -S uv run --script`；docstring 中 Usage / Notes 更新到 uv；ImportError 提示改为指向 `uv run`。
- 删 `tools/requirements-fetch.txt`（替代品就是 PEP 723 块）。
- `README.md` / `AGENTS.md` 规则 2 / `egs/amphion-asr-2026/refs/README.md` / `egs/_skeleton/refs/README.md` 中所有 `pip install -r tools/requirements-fetch.txt` + `python tools/fetch-refs.py ...` 改为 `uv run tools/fetch-refs.py ...`。
- `egs/amphion-asr-2026/refs/{notes/papers,datasets}/INDEX.yaml` 顶部注释（之前被首次 sha256 回填的 PyYAML safe_dump 抹掉）手工恢复，改成 uv 版本，并加注释提示 PyYAML 重写会丢注释、本头部为人工 restore。
- `egs/_skeleton/refs/{notes/papers,datasets}/INDEX.yaml` 头部注释同步改 uv 版本。
- `.cursor/rules/multi-report.mdc` 公共层文件清单去掉 `tools/requirements-fetch.txt`。
- 本 entry。

每 egs 影响：仅文档 / 调用方式变化，PDF / sha256 / yaml 结构均不动；不需要 `depends_on_template` bump。
