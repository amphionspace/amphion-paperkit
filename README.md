# AmphionASR Technical Report

LaTeX 工程，基于 [X-LANCE Lab pre-print template](https://github.com/X-LANCE/LaTeX-Template-for-X-LANCE-Lab)（`xlance.cls` v0.2.4-20260429）的 OpenDFM 蓝紫主题。

## 目录结构

```
.
├── main.tex                    # 主文件：documentclass + 输入各章节
├── references.bib              # 我们自己的参考文献
├── latexmkrc                   # latexmk 配置
├── xlance/                     # 模板（vendored，不要改动）
│   ├── xlance.cls              # 文档类，自带主题/字体/promptbox/IEEE 引用
│   ├── IEEEtran2.bst           # 引用样式
│   ├── venues.bib              # 模板维护的会议/期刊缩写
│   └── assets/                 # logo / 图标
├── sections/
│   ├── 00_abstract.tex         # 纯文本，被 main.tex 用 \abstract{\input{}} 包装
│   ├── 01_introduction.tex
│   ├── 02_related_work.tex
│   ├── 03_data.tex
│   ├── 04_model.tex
│   ├── 05_training.tex
│   ├── 06_experiments.tex
│   ├── 07_hotwords.tex
│   ├── 08_ts_asr.tex
│   ├── 09_noise_robustness.tex
│   ├── 10_analysis.tex
│   ├── 11_limitations_ethics.tex
│   ├── 12_conclusion.tex
│   └── A_appendix.tex
├── figures/
│   ├── architecture.tex / .pdf  # 架构图（首页 teaser）
│   └── ...
├── refs/                        # 参考文档（fact-check 用，由 AGENTS.md 引用）
└── AGENTS.md                    # AI 协作硬规则
```

## 本地编译

需要 TeX Live 2026（或同等支持 Palatino + tcolorbox 的发行版）。一次性安装：

```bash
brew install --cask mactex-no-gui
# 装完后新开一个 terminal 让 PATH 生效，或手动 source：
eval "$(/usr/libexec/path_helper)"
```

编译：

```bash
PATH=/Library/TeX/texbin:$PATH latexmk -pdf -interaction=nonstopmode main.tex
```

清理中间文件：

```bash
PATH=/Library/TeX/texbin:$PATH latexmk -c
```

## 模板要点

- 主题：OpenDFM 蓝紫（`\documentclass[opendfm]{xlance/xlance}`）。去掉 `[opendfm]` 即切回 X-LANCE 红。
- 首页 logo 已在 `main.tex` 里通过覆盖 `\fancypagestyle{firstpage}` 关掉。
- 引用风格：IEEE numeric `[1]`（`natbib + xlance/IEEEtran2.bst`）。所有引用一律 `\cite{key}`，不用 `\citep / \citet`。
- abstract 是一个**命令**（`\abstract{...}`），不是 environment。`sections/00_abstract.tex` 是裸文本。
- 标题、作者、摘要、metadata 全部在 `main.tex` 的 preamble 里声明，`\maketitle` 之后是架构图 teaser + `\tableofcontents`。
- 已加载且不要重复 `\usepackage` 的：`amsmath, amssymb, mathtools, booktabs, multirow, subcaption, graphicx, hyperref, cleveref, natbib, listings, tcolorbox, xcolor, microtype, ...`（完整列表见 `xlance/xlance.cls`）。

## 协作规范

- 全局规则：见 `AGENTS.md`。
- 细化规则：`.cursor/rules/*.mdc`（paper-writing / latex-engineering / asr-domain / reproducibility）。
- 内容修改前必须 fact-check 并参照 `refs/`。

## Required tlmgr packages

完整 TeX Live 2026 已包含。最小集合（如裸装 BasicTeX 需要补）：

```
tlmgr install collection-fontsrecommended tgpagella mathpazo inconsolata \
              tcolorbox nicematrix multirow longtable tabularx adjustbox \
              enumitem cleveref natbib hyperref microtype hyphenat \
              setspace parskip babel-latin lipsum
```
