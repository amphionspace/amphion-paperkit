<div align="center">

# Amphion PaperKit

**用同一套模板、规则和工具写 Amphion 技术报告：每份报告自包含，公共能力只维护一份。**

LaTeX 模板 · TikZ 调色板 · 参考资料索引 · AmphionEval 评测结果 · AI 协作规则 · CI

[安装](#安装) · [快速开始](#快速开始) · [仓库结构](#仓库结构) · [外部信息源](#外部信息源amphioneval) · [命令速查](#命令速查) · [活跃报告](#活跃报告) · [协作规则](#协作规则)

</div>

```text
$ tools/new-report.sh amphion-tts-2026 --title "AmphionTTS: ..." --shortname AmphionTTS --author "Amphion Team"
[ok] Bootstrapped egs/amphion-tts-2026/ from egs/_skeleton/.
$ uv run tools/fetch-refs.py egs/amphion-asr-2.0-2026        # 论文 / 数据集 PDF，sha256 校验
$ uv run tools/fetch-eval.py egs/amphion-asr-2.0-2026        # AmphionEval 评测记录（经 AmphionBucket）
$ cd egs/amphion-asr-2.0-2026 && latexmk -pdf main.tex
Output written on main.pdf
```

- **一份报告一个目录**：`egs/<slug>/` 放正文、图、表、参考资料和元数据，结构对齐 [icefall](https://github.com/k2-fsa/icefall) 的 egs 模式；报告之间不互相 `\input`。
- **公共层只有一份**：`template/amphion.cls`、`figures/_palette.tex`、`tools/`、`.cursor/rules/` 被所有报告共享，改动走 [CHANGELOG](template/CHANGELOG.md) 并重编全部报告。
- **事实可追溯**：论文与数据集 PDF 由 `INDEX.yaml` 声明并校验 sha256；评测数字来自 AmphionEval 发布的记录；正文每次修改都附 fact check。
- **AI 协作有硬约束**：[AGENTS.md](AGENTS.md) 规定作图、查资料、抽象层次、不自创归因等 9 条规则，Cursor / Claude Code / Codex 通用。

## 安装

需要 TeX Live（pdfLaTeX + latexmk）、Python 3.9+ 和 [uv](https://docs.astral.sh/uv/)。读取评测结果还需要 AmphionBucket（`ab`，团队内部工具）。

```bash
# uv（脚本依赖通过 PEP 723 声明，uv 自动建环境）
curl -LsSf https://astral.sh/uv/install.sh | sh

# macOS：MacTeX 自带全部宏包
brew install --cask mactex-no-gui

# Linux 无 root：TeX Live 装到用户目录（国内用阿里云 / 清华 CTAN 镜像更快）
R=https://mirrors.aliyun.com/CTAN/systems/texlive/tlnet
curl -fLO $R/install-tl-unx.tar.gz && tar xzf install-tl-unx.tar.gz
perl install-tl-*/install-tl --repository $R --scheme small --no-doc-install --no-src-install \
  --texdir ~/texlive/2026 --no-interaction
export PATH=~/texlive/2026/bin/x86_64-linux:$PATH   # 或 tlmgr option sys_bin ~/.local/bin && tlmgr path add
tlmgr option repository $R
tlmgr install collection-latexextra collection-fontsrecommended collection-pictures \
  collection-mathscience latexmk babel-latin hyphen-latin inconsolata tex-gyre fontawesome5 lipsum hyphenat
```

`scheme-small` 之外需要的宏包就是上面 `tlmgr install` 这一行；模板加载的完整宏包清单见 [latex-engineering 规则](.cursor/rules/latex-engineering.mdc)。新增宏包时同步更新这一行。

`ab` 首次使用前运行 `ab remotes`，能列出 AmphionEval 团队桶即可读取；凭据由 `ab` 自己管理，不写进本仓库。

## 快速开始

**1. 起一份新报告。** 不要手工复制 `_skeleton`，用脚本替换占位符：

```bash
tools/new-report.sh <slug> --title "..." --shortname "..." --author "..."
```

**2. 准备参考资料。** 在 `egs/<slug>/refs/notes/papers/INDEX.yaml` 和 `refs/datasets/INDEX.yaml` 登记论文与数据集（`sha256: null` 待回填），然后下载：

```bash
uv run tools/fetch-refs.py egs/<slug>
```

内部材料（plan、模型结构、训练与评测数据）放 `refs/docs/`，数据统计和净化后的结果放 `refs/internal/`。写任何一节前先读这里，见 [AGENTS.md 规则 2](AGENTS.md)。

**3. 接入评测结果（可选）。** 在 `egs/<slug>/refs/internal/amphion-eval.yaml` 声明要用的记录和测试集，再拉取，见[外部信息源](#外部信息源amphioneval)。

**4. 写作与编译。**

```bash
cd egs/<slug>
latexmk -pdf main.tex              # latexmkrc 已把仓库根加入 TEXINPUTS
../../tools/fact-check-regex.sh .  # 正文不能出现路径、脚本名、配置字段
```

图一律用 TikZ（`\input{_palette}` 复用公共调色板），源码和编译出的 PDF 都放 `figures/` 并提交。

## 仓库结构

```text
amphion-paperkit/
├── template/        amphion.cls + asr-macros.sty + IEEEtran2.bst + venues.bib（CHANGELOG 记版本）
├── figures/         公共 TikZ 调色板 _palette.tex 与架构图起手范本
├── tools/           new-report / build-all / fact-check-regex / fetch-refs / fetch-eval / overleaf-pack
├── .cursor/rules/   写作、LaTeX 工程、ASR 领域、复现、多报告边界规则 + 方法学源汇总
├── .github/         CI：编译全部报告、跑抽象层次自检
└── egs/
    ├── _skeleton/   新报告脚手架（只通过 new-report.sh 派生）
    └── <slug>/      main.tex · REPORT.md · sections/ · figures/ · tables/ · refs/ · ack/
```

单份报告的标准目录见 [egs/README.md](egs/README.md)。

## 外部信息源：AmphionEval

AmphionEval（`ae`，团队内部工具）把每次评测发布到团队对象存储桶的 `amphion-eval/` 下。报告里的评测数字应来自这里，而不是手抄：

| 远端路径 | 内容 |
| --- | --- |
| `records/<task>/<YYYY-MM>/<run-id>.json` | 发布记录：模型、benchmark、协议版本、逐切片指标（榜单只读这里） |
| `eval-sets/<project>/<name>@<version>/` | 测试集登记：切片标签、分组、样本数 |

`tools/fetch-eval.py` 通过 AmphionBucket 只读拉取报告声明的路径，不需要安装 `ae`：

```yaml
# egs/<slug>/refs/internal/amphion-eval.yaml
bucket: <bucket>:amphion-eval/
pull:
  - records/asr/2026-10/
  - eval-sets/open-audio-llm/ts-asr-benchmark@v12-20261022/
```

```bash
uv run tools/fetch-eval.py egs/<slug>               # 相同文件跳过，结束时按 benchmark / 模型统计记录数
uv run tools/fetch-eval.py egs/<slug> --overwrite   # 桶里的记录改过（如统一模型名）时取桶里的版本
```

- 镜像落在 `egs/<slug>/refs/internal/amphion-eval/`，布局与 `ae` 的状态目录相同，`ae --state-dir` 或按 `ae sync` 输出写的汇总脚本可以直接读。
- **镜像不入 git。** 记录里有不能公开的子集；本仓库是公开仓库。数字只能经过报告自己的净化与汇总（例如 `refs/internal/` 下的数据文件和构建脚本）进入正文，口径以该报告的 `refs/docs/plan.md` 为准。
- 正文不写 run ID、桶名、内部模型键；比较同一张表的结果时，只用同一 benchmark 版本、同一打分协议版本、全量（非抽样）的记录，规则见 AmphionEval 仓库里的结果组织说明（`docs/results.md`）。

## 命令速查

| 命令 | 用途 |
| --- | --- |
| `tools/new-report.sh <slug> --title ... --shortname ... --author ...` | 从 `_skeleton` 起一份新报告 |
| `uv run tools/fetch-refs.py egs/<slug>` | 按 `INDEX.yaml` 下载论文 / 数据集 PDF 并校验 sha256，回填空 sha256 |
| `uv run tools/fetch-eval.py egs/<slug>` | 经 AmphionBucket 拉取该报告声明的 AmphionEval 记录与测试集登记 |
| `cd egs/<slug> && latexmk -pdf main.tex` | 编译单份报告 |
| `tools/build-all.sh` | 编译全部活跃报告（跳过 `_` 开头目录） |
| `tools/fact-check-regex.sh [egs/<slug>]` | 检查正文有无路径、脚本名、配置字段（CI 同款） |
| `tools/overleaf-pack.sh <slug>` | 打包成可直接上传 Overleaf 的扁平目录 / zip |
| `cd egs/<slug>/figures && pdflatex <name>.tex` | 单独编译一张 TikZ 图 |

## 活跃报告

`REPORT.md` 是每份报告元数据的唯一真相源，下表从中汇总。

| slug | 报告 | 状态 | 模板 |
| --- | --- | --- | --- |
| [amphion-asr-2.0-2026](egs/amphion-asr-2.0-2026/) | AmphionASR 2.0: Target-Speaker Speech Recognition for Real-World Recordings --- A Benchmark and a Model | active（初稿） | v0.1 |
| [amphion-asr-1.7b-2026](egs/amphion-asr-1.7b-2026/) | AmphionASR: A Unified SpeechLLM for Context-Aware Mandarin–English Speech Recognition（AmphionASR 1.0，2026.07） | 已发布；缺 `REPORT.md` | — |
| [amphion-asr-2026](egs/amphion-asr-2026/) | AmphionASR: An Open-Source Industrial-Grade SpeechLLM for Personalised Mandarin–English Speech Recognition | active | v0.1 |

## 协作规则

| 文档 | 内容 |
| --- | --- |
| [AGENTS.md](AGENTS.md) | 9 条硬约束：TikZ 作图、先查 refs、fact check、正文不写实现细节、refs/docs 是原料、仿照同类文献、通用约定、egs 边界、不自创归因 |
| [.cursor/rules/](.cursor/rules/) | 写作风格、LaTeX 工程、ASR 领域报告项、复现与 LLM 使用披露、多报告边界 |
| [.cursor/rules/_sources.md](.cursor/rules/_sources.md) | 写作、评审、复现方法学的外部来源 |
| [template/CHANGELOG.md](template/CHANGELOG.md) | 公共层每次改动的原因、内容和兼容性 |
| [egs/README.md](egs/README.md) | 单份报告的目录约定 |

改公共层（`template/`、`figures/_palette.tex`、`tools/`、`.cursor/rules/`、`egs/_skeleton/`）先在 CHANGELOG 记一条，再用 `tools/build-all.sh` 确认所有报告无回归，单独提交。

[MIT License](LICENSE) · 模板继承的 arxiv-style 许可见 [LICENSE_arxiv-style.txt](LICENSE_arxiv-style.txt)
