# LLM Usage Disclosure — AmphionASR 2.0: Target-Speaker Speech Recognition for Real-World Recordings --- A Benchmark and a Model

按 ICLR / NeurIPS 2026 投稿要求，本报告需要在 Acknowledgments 中披露大语言模型的使用情况。本文件记录每次 agent 协助的范围，便于后续生成可信的披露语句。

参见 .cursor/rules/reproducibility.mdc §4。

## 记录格式

每条 entry 一行：

date | section/scope | model | summary

## Entries

<!-- 在下方追加 entries，最新的放最上面 -->
| 日期 | 范围 | 模型 | 摘要 |
| --- | --- | --- | --- |
| 2026.11.02 | HTML 报告源码（本机）、refs/README | Claude (Claude Code) | HTML 版同步隐藏数据配方、prompt 与输出格式原文、训练超参数与硬件；内部原料改为只放本机 |
| 2026.11.01 | sections/*、figures/scenarios、references.bib、refs/notes/papers | Claude (Claude Code) | 重画场景图与架构图、新增基准构造图；压缩数据配方细节；把 CocktailASR-1 比较并入实验节；新增 10 篇相关工作并逐篇核对 PDF；去掉 prompt 原文；英文措辞修改（数字与主张不变）；去掉输出格式原文与训练超参数 |
| 2026.10.31 | sections/*、tables/*、figures/*、references.bib | Claude (Claude Code) | 按 HTML 定稿与 refs/docs 起草 LaTeX 初稿；表格由脚本从 HTML 表格转换；4 张 TikZ / pgfplots 图；头条数字用 AmphionEval 记录复算；文献作者表按 arXiv API 核对 |
| 2026.10.31 | refs/docs, refs/internal, refs INDEX | Claude (Claude Code) | 整理 HTML 版报告的原料：计划与口径、模型 / 数据 / 基准事实、净化后的数据与构建脚本、文献与数据集索引（arXiv 编号逐条核对） |
| 2026.10.30–31 | HTML 技术报告（中 / 英） | Claude (Claude Code) | 起草发布版 HTML 报告的正文、表格与图；数字由脚本从评测记录生成 |
| 2026.10.31 | report bootstrap | (TBD) | scaffolded from egs/_skeleton/ |

## Acknowledgments draft

> Portions of this manuscript were drafted with the assistance of large language models. All technical content, numerical results, and citations were verified by the authors against primary sources before inclusion.
