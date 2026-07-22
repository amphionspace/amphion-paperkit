# LLM Usage Disclosure — AmphionASR

按 ICLR / NeurIPS 2026 投稿要求，本报告需要在 Acknowledgments 中披露大语言模型的使用情况。本文件记录每次 agent 协助的范围，便于后续生成可信的披露语句。

参见 .cursor/rules/reproducibility.mdc §4。

## Entries

<!-- 在下方追加 entries，最新的放最上面 -->
| 日期 | 范围 | 模型 | 摘要 |
| --- | --- | --- | --- |
| 2026.07.22 | hotword latency reporting | GPT-5 | structured the supplied latency measurements into a reproducible internal report and manuscript subsection, preserved shared-GPU, sample-size, mock-pool, cold-start, and deployment boundaries, and verified the rendered latency table |
| 2026.07.21 | positioning and claim audit | GPT-5 | tightened the system positioning, added related work and ownership boundaries, narrowed hotword and target-speaker claims, corrected references, and added the disclosure; figures, tables, reported values, and training settings were not changed |
| 2026.07.21 | full-report prose revision | GPT-5 | rewrote title, abstract, introduction, methods narration, results discussion, analysis, limitations, and conclusion for academic tone; tables and reported values were not changed |
| 2026.05.14 | report relocation | claude-opus-4.7 | git-mv main.tex / sections / figures / refs/docs into egs/amphion-asr-2026/; no prose was modified in this PR |
| 2026.05.14 | template fork | claude-opus-4.7 | preamble overrides absorbed into template/amphion.cls (PR 1) |

## Acknowledgments draft

> Portions of this manuscript were drafted with the assistance of large language models. All technical content, numerical results, and citations were verified by the authors against primary sources before inclusion.
