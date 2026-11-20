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
- 2026-11-19: condensed to the Interspeech format with one figure and four tables.
- 2026-11-20: adopted the user-approved OFA-TS title and model name; aligned
  the abstract, introduction, benchmark framing, model caption, result labels,
  and conclusion with using one model across scenarios.
- Existing measurements are retained. No new experiments or causal claims
  were added during the title revision.
