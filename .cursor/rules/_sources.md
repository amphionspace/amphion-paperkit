# Sources for `.cursor/rules/*.mdc` and `AGENTS.md`

> 本文件是 `.cursor/rules/*.mdc` 与 `AGENTS.md` 各项规则的源汇总。
>
> 原本住在 `refs/notes/research-references.md`；2026-05-14 起作为规则的附属脚注上提到此处（顶层 `refs/` 目录已取消，参考 [template/CHANGELOG.md](../../template/CHANGELOG.md)）。
>
> 下划线前缀 (`_sources.md`) 表示本文件是规则附属，不会被 Cursor 当作 rule 加载。
>
> 修改任一规则前，先回到这里查证；新增源时按现有分组归类并附"用处"。

## 1. ML paper writing 通用

| 来源 | 链接 | 用处 |
| --- | --- | --- |
| Highly Opinionated Advice on How to Write ML Papers (2026) | https://blog.wahdany.eu/2026/Jan/6/bm-how-to-write-ml-papers/ | 写作流程 + 评审随机性数据 |
| Simon Peyton Jones — How to write a great research paper | https://www.cis.upenn.edu/~sweirich/icfp-plmw15/slides/peyton-jones.pdf | One ping / 早写 / Story telling 七原则 |
| Jennifer Widom — Tips for Writing Technical Papers | https://cs.stanford.edu/people/widom/paper-writing.html | Intro 的五问 |
| Jason Eisner — How to write a paper? | https://www.cs.jhu.edu/~jason/advice/write-the-paper-first.html | Write-the-paper-first 哲学 |
| Tim Rocktäschel & Jakob Foerster — How to ML Paper | https://twitter.com/j_foerst/status/1526593779502829569 | ML paper 章节结构 |
| zhijing-jin/nlp-phd-global-equality | https://github.com/zhijing-jin/nlp-phd-global-equality | 巨量 PhD / paper writing 资源链接 hub |
| ICML 2022 Paper Best Practices | https://icml.cc/Conferences/2022/BestPractices | 理论 + 实验报告通用 checklist |
| STRaWBERRY framework | https://ml-and-vis.org/strawberry/ | LLM 自评估 paper draft 的 checklist |

## 2. AI agent 写 paper / Cursor 协作

| 来源 | 链接 | 用处 |
| --- | --- | --- |
| Vibe Paper Writing Skill (Cursor / Claude Code / Codex / Copilot 兼容) | https://github.com/Zhangyanbo/vibe-paper-writing | Endorsement awareness、voice preservation、compilation-gated output |
| PaperOrchestra (Google 多代理 paper writing 框架) | https://skillsllm.com/skill/paperorchestra | Outline → Plot → LitReview → Section → Refine 五代理 pipeline |
| ARIS (Auto-Research-In-Sleep) | https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep | Cursor / Claude Code 中长链式科研代理 |
| Cursor Rules 文档 | https://cursor.com/docs/rules.md | rules / AGENTS.md 协议规范 |
| AGENTS.md (60k+ projects) | 见 cursor.com docs | 通用 agent 文档协议 |

## 3. ML paper 评审 (2025-2026)

| 来源 | 链接 | 用处 |
| --- | --- | --- |
| ICLR 2026 Reviewer Guide | https://iclr.cc/Conferences/2026/ReviewerGuide | 评审标准、LLM 披露要求、leaning-to-accept / reject 范例 |
| ICLR 2026 评审复盘 | https://blog.iclr.cc/2026/03/31/a-retrospective-on-the-iclr-2026-review-process/ | LLM 生成的虚假 cite 是当下顶级雷区 |
| NeurIPS 2025 PC chairs 反思 | https://blog.neurips.cc/2025/09/30/reflections-on-the-2025-review-process-from-the-program-committee-chairs/ | 21,575 投稿的 calibration 难题 |
| Insights from ICLR Peer Review and Rebuttal Process (2025) | https://arxiv.org/abs/2511.15462 | rebuttal 过程数据 |

## 4. Reproducibility / release

| 来源 | 链接 | 用处 |
| --- | --- | --- |
| NeurIPS 2026 Code Submission Policy | https://neurips.cc/public/guides/CodeSubmissionPolicy | 代码 / 数据集 release 必备项 |
| NeurIPS 2026 Call for Reproducibility | https://nips.cc/Conferences/2026/CallForReproducibility | 复现 checklist |
| NeurIPS 2026 Evaluations & Datasets Track | https://neurips.cc/Conferences/2026/EvaluationsDatasetsHosting | Croissant metadata、HF / Dataverse / Kaggle 托管 |
| Papers with Code — releasing-research-code | https://github.com/paperswithcode/releasing-research-code | release repo 标准目录 |
| Datasheets for Datasets (Gebru et al.) | https://arxiv.org/abs/1803.09010 | 数据集 datasheet 模板 |

## 5. LaTeX 工程实战

| 来源 | 链接 | 用处 |
| --- | --- | --- |
| Overleaf — Management in a large project | https://overleaf.com/learn/latex/Management_in_a_large_project | input vs include、includeonly |
| Thetapad — Taming 200-Page Monsters | https://www.thetapad.com/blog/managing-large-documents | 大型 LaTeX 工程结构 |
| Sussman Lab — Writing collaborative papers with LaTeX | https://www.dmsussman.org/resources/latexCollaboration/ | 多人协作约定 |
| LaTeX Cloud Studio — Managing Large Documents | https://resources.latex-cloud-studio.com/learn/latex/how-to/large-documents | preamble 拆分、分章 |

## 6. ASR / speech 领域专属

> - 领域专属论文 PDF 在每份 egs 自己的 `egs/<slug>/refs/notes/papers/`；该目录的 `INDEX.yaml` 是真相源，PDF 由 `tools/fetch-refs.py` 按 yaml 下载并 sha256 校验。
> - 数据集 datasheet 同理在 `egs/<slug>/refs/datasets/`，`INDEX.yaml` + `INDEX.md` 一对。
> - 闭源 / 商用 ASR / TTS / Audio-LLM 系统（Doubao / gpt-4o-transcribe 等）的官方信息源在每份 egs 的 `egs/<slug>/refs/notes/commercial-systems.md`。
>
> 下表仅保留非论文类（评测协议、博客、方法学）参考；具体论文 PDF 清单不在这里维护。

| 来源 | 链接 | 用处 |
| --- | --- | --- |
| Aksenova et al. 2021 — How Might We Create Better Benchmarks for Speech Recognition? | https://aclanthology.org/2021.bppf-1.4/ | WER 之外的 metric、benchmark 多样性 |
| Gladia ASR Benchmarking 文档 | https://docs.gladia.io/chapters/pre-recorded-stt/benchmarking | 工业界 normalization 实践 |
| OpenSLR resources list | https://openslr.org/resources.php | aidatatang / MagicData / Primewords / RIR 等无 paper 资源的官方入口 |

## 7. 行业 prompt collection（不是规则，是辅助灵感）

- 50 AI Prompts for Scientists & Researchers (2026) — https://sureprompts.com/blog/ai-prompts-for-scientists
- 15 Prompts by Paper Section — https://proofreaderpro.ai/blog/ai-prompts-for-academic-writing
- Multi-LLM workflow for writing — https://suprmind.ai/hub/insights/best-ai-for-writing-research-papers-a-multi-llm-workflow-that-holds/

---

下次想引入新规则或者 fact-check 时，先在这里检索。新增源放进对应分组并附"用处"，方便后续 agent 快速定位。
