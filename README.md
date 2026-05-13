# LLM-ASR Technical Report

基于 [arxiv-style](https://github.com/kourgeorge/arxiv-style) 模板的 LLM ASR technical report 工程。

## 目录结构

```
.
├── main.tex                    # 主文件，按章节 \input
├── arxiv.sty                   # arxiv 风格样式（来自 kourgeorge/arxiv-style）
├── orcid.pdf                   # ORCID 图标
├── references.bib              # 文献库
├── latexmkrc                   # latexmk 配置
├── sections/
│   ├── 00_abstract.tex
│   ├── 01_introduction.tex
│   ├── 02_related_work.tex
│   ├── 03_data.tex
│   ├── 04_model.tex
│   ├── 05_training.tex
│   ├── 06_experiments.tex
│   ├── 07_analysis.tex
│   ├── 08_limitations_ethics.tex
│   ├── 09_conclusion.tex
│   └── A_appendix.tex
├── figures/                    # 放图
└── tables/                     # （可选）单独管理大表
```

## 本地编译

需要 MacTeX 或 TeX Live。一次性安装：

```bash
brew install --cask mactex-no-gui
# 装完后新开一个 terminal 让 PATH 生效，或手动 source：
eval "$(/usr/libexec/path_helper)"
```

编译：

```bash
latexmk main.tex
# 或单次：
pdflatex main && bibtex main && pdflatex main && pdflatex main
```

清理中间文件：

```bash
latexmk -c
```

## 上传 Overleaf

1. 在仓库根目录打包：`zip -r llm-asr-report.zip . -x "*.git*" -x "main.pdf"`
2. Overleaf → New Project → Upload Project → 选 zip
3. Overleaf 里 Compiler 选 pdfLaTeX，Main document 选 `main.tex`
```
