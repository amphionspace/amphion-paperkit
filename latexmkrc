# Top-level latexmkrc — shared defaults for every egs build.
# Each egs/<slug>/latexmkrc augments TEXINPUTS / BIBINPUTS / BSTINPUTS so that
# template/amphion.cls, template/asr-macros.sty, references.bib, and
# IEEEtran2.bst all resolve from a leaf working directory.
#
# Top-level direct compilation is intentionally not supported: there is no
# main.tex at the project root (reports live under egs/<slug>/). Run
# `cd egs/<slug> && latexmk -pdf main.tex` or `tools/build-all.sh`.

$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -file-line-error -synctex=1 %O %S';
$bibtex_use = 2;
$clean_ext = 'synctex.gz acn acr alg aux bbl bcf blg brf fdb_latexmk fls glg glo gls idx ilg ind ist lof log lol lot out run.xml toc';
