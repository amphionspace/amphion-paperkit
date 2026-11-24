# OFA-TS

**OFA-TS: One Model for All Real-World Scenarios in Target-Speaker ASR**

This is the Interspeech adaptation of the AmphionASR 2.0 technical report.
OFA-TS is the manuscript's new model name; it refers to the same model and
experimental results. AmphionTS-Bench retains its existing dataset name.
"One Model for All" describes using one set of model parameters across the
evaluated acoustic and conversational conditions. The manuscript retains
the benchmark's Mandarin-only coverage, domain overlap, and failure cases.

Run ./build.sh from this directory to compile main.pdf.
The build uses latexmk when available, or ~/tools/tex/bin/tectonic.
The checked-in figure PDF is sufficient for the main build.

The unmodified Interspeech.cls and IEEEtran.bst are from the 2026 Paper
Kit, as distributed by O-COCOSDA 2026:
https://www.ococosda2026.com.ph/assets/paper_templates/Interspeech2026-Paper-Kit.zip
Official template: https://www.overleaf.com/latex/templates/interspeech-paper-kit/svqkgcpdbxfg
The class remains in review mode and displays its original 2026 review label.

## Revision provenance

- Source: the parent report's Sections 2--6 and 8--9 at commit b1712538.
- Structure: condensed from the existing report; no new scientific sections.
- 2026-11-19: condensed to the Interspeech format with one figure and four tables (three after 2026-11-22).
- 2026-11-20: adopted the user-approved OFA-TS title and model name; aligned
  the abstract, introduction, benchmark framing, model caption, result labels,
  and conclusion with using one model across scenarios.
- Existing measurements are retained. No new experiments or causal claims
  were added during the title revision.
- 2026-11-22: the reported checkpoint changed to ts-robust-064-avg3 (the
  user's choice after comparing the Mandarin v12 and English v1 TS-ASR
  benchmarks). All TS-ASR numbers are re-pooled from the AmphionEval v12
  records of that checkpoint and of both CocktailASR-1 modes (protocol v4,
  248 subsets). The paper now covers TS-ASR only: the plain-ASR retention
  table and the hotword results were removed. Real-conversation CER is
  labelled as clean enrollment, and the contaminated-enrollment comparison
  now uses the same corpora for both sides. The parent report is unchanged.
- 2026-11-22: added the English counterpart (ts-asr-benchmark-en@v1-20261031,
  220 subsets, 23,021 samples): benchmark description in Section 2, Table 4
  and its discussion in Section 4, and updated abstract, introduction,
  limitations and conclusion. English numbers come from the 064-avg3 record
  and from both CocktailASR-1 modes rescored with whisper-normalizer 0.1.15
  (the version of the 064-avg3 record). Added bib entries for VCTK,
  CS-Dialogue, DiPCo and ICSI.
- 2026-11-23: added two extract-then-recognize cascade baselines (WeSep or
  LauraTSE followed by Qwen3-ASR-1.7B) as columns W and L of Tables 2, 3 and 4,
  with their setup in Section 4.1, discussion, a limitation and a conclusion
  clause. Numbers come from full AmphionEval external-worker runs on hpc
  (2026-11-22, same scoring protocol and normalizer), pooled with the same
  script that reproduces the 064-avg3 table cells. LauraTSE used a KV-cached
  decoder whose outputs matched the official decoder bit for bit on a
  256-sample check. Added bib entries for WeSep and LauraTSE; the GenAI
  disclosure now names the new runs.
- 2026-11-23: Figure 1 redrawn as an architecture diagram (inputs, frozen
  convolutions and text embedding, token rows with the learnable separator,
  AuT Transformer, projection, language model, output language tag, legend
  and frozen/trainable marks), laid out after Figure 1 of the streaming TSE
  paper in tse-experiments. Compared systems are now named in full
  (Xiaomi-CocktailASR-1, WeSep + Qwen3-ASR-1.7B, LauraTSE + Qwen3-ASR-1.7B)
  in tables and text: the Mandarin and English result tables are merged into
  one full-width Table 2 with systems as rows, and the diagnostic table
  (now Table 3) is transposed to full width. Numbers are unchanged.
- 2026-11-23: Figure 1 module names shortened at the user's request: the
  Transformer box is "Audio encoder" (the dashed AuT frame is removed),
  "Projection", and "LLM"; the caption follows these names.
- 2026-11-23: Figure 1: "Projection" renamed "Projector"; the separator token
  no longer carries a trainable mark (its trainability is stated in the text);
  token colours made more distinct (deep teal enrollment, light slate mixture,
  dark grey separator, bronze instruction, clay language tag, white
  transcript), all tints of existing palette hues.
- 2026-11-23: Figure 1: the mixture label no longer shows the 25 s limit
  (the request limit stays in Section 3.1).
- 2026-11-23: the baseline is called CocktailASR-1 and its chain-of-thought
  mode CocktailASR-1-CoT throughout (the bib title and the released weight
  name keep "Xiaomi-"). Tables 2 and 3 gain a Type column (Cascade / E2E);
  rows are ordered cascades, E2E baselines, then OFA-TS last. Numbers are
  unchanged.
