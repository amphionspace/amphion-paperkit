#!/usr/bin/env bash
# Pack an egs/<slug>/ report into a self-contained, flat directory
# (and optional zip) that can be uploaded to Overleaf as-is.
#
# Why this script exists:
#   Overleaf requires main.tex at the project root and forbids path
#   escapes (../../ is sandboxed away). Our mono-repo keeps main.tex
#   under egs/<slug>/ and the shared LaTeX class under top-level
#   template/. The local build resolves the cross-layer reference via
#   egs/<slug>/latexmkrc:  TEXINPUTS=../../:$TEXINPUTS  — which does
#   not survive Overleaf's sandbox. This script flattens the two
#   layers into one directory by copying template/ alongside the egs
#   sources, so \documentclass{template/amphion} resolves from the
#   project root with no changes to main.tex.
#
# Usage:
#   tools/overleaf-pack.sh <slug> [--no-build] [--no-zip] [--output-dir <dir>]
#
# Examples:
#   tools/overleaf-pack.sh amphion-asr-2026
#   tools/overleaf-pack.sh amphion-asr-2026 --no-build
#   tools/overleaf-pack.sh amphion-asr-2026 \
#       --no-zip --output-dir ../overleaf-mirror
#
# Output (default):
#   build/overleaf/<slug>/        — flat project dir (upload as folder)
#   build/overleaf/<slug>.zip     — convenient "Upload Project" zip
#
# Uploading to Overleaf:
#   A. New project (one-shot, recommended for first-time setup):
#       1. Overleaf -> New Project -> Upload Project ->
#          select build/overleaf/<slug>.zip
#       2. If Overleaf asks, set "main.tex" as the main document.
#
#   B. Re-sync an existing project via Overleaf Git Bridge (paid):
#       1. git clone https://git.overleaf.com/<id> overleaf-mirror
#       2. tools/overleaf-pack.sh <slug> \
#               --no-zip --output-dir overleaf-mirror
#       3. cd overleaf-mirror && git add -A && \
#               git commit -m "sync from mono-repo" && git push
#      The script preserves overleaf-mirror/.git/ when re-running.
#
# Limitations:
#   The flow is one-way (mono-repo -> Overleaf). Edits made on Overleaf
#   must be diffed and copied back into egs/<slug>/ by hand; treat the
#   Overleaf project as a review / sharing snapshot, not a second source
#   of truth.
#
# Exit codes:
#   0 — packed
#   1 — missing input (slug not found, template/ missing, etc.)
#   2 — bad CLI usage

set -euo pipefail

if [[ $# -lt 1 ]]; then
  sed -n '3,46p' "$0"
  exit 2
fi

SLUG="$1"
shift

DO_BUILD=1
DO_ZIP=1
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-build)    DO_BUILD=0; shift ;;
    --no-zip)      DO_ZIP=0;   shift ;;
    --output-dir)  OUTPUT_DIR="$2"; shift 2 ;;
    -h|--help)     sed -n '3,46p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EGS_DIR="$REPO_ROOT/egs/$SLUG"
TPL_DIR="$REPO_ROOT/template"

if [[ ! -d "$EGS_DIR" ]]; then
  echo "Error: egs not found at $EGS_DIR" >&2
  exit 1
fi
if [[ ! -d "$TPL_DIR" ]]; then
  echo "Error: template/ not found at $TPL_DIR" >&2
  exit 1
fi
if [[ ! -f "$EGS_DIR/main.tex" ]]; then
  echo "Error: $EGS_DIR/main.tex not found" >&2
  exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  DEST="$REPO_ROOT/build/overleaf/$SLUG"
else
  case "$OUTPUT_DIR" in
    /*) DEST="$OUTPUT_DIR" ;;
    *)  DEST="$PWD/$OUTPUT_DIR" ;;
  esac
fi

# Some macOS users keep latexmk under /Library/TeX/texbin (basictex /
# MacTeX) which isn't on the default shell PATH; prepend it eagerly so
# the script works in a fresh terminal.
export PATH="/Library/TeX/texbin:$PATH"

if [[ "$DO_BUILD" -eq 1 ]]; then
  if ! command -v latexmk >/dev/null 2>&1; then
    echo "Error: latexmk not found in PATH. Install latexmk, or rerun with --no-build after building manually." >&2
    exit 1
  fi
  echo "[overleaf-pack] pre-building $SLUG so figures/*.pdf are fresh..."
  (cd "$EGS_DIR" && latexmk -pdf -interaction=nonstopmode main.tex >/dev/null)
fi

# Clear DEST but keep DEST/.git/ if present (Git Bridge mirror case).
if [[ -d "$DEST" ]]; then
  find "$DEST" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
else
  mkdir -p "$DEST"
fi

# Copy egs sources. Exclude:
#   - internal-only directories (refs/, .cursor/)
#   - per-egs metadata that has no meaning on Overleaf (REPORT.md, latexmkrc)
#   - LaTeX build artifacts (we copy the figures/*.pdf the build produced,
#     but not main.aux/.log/.bbl/...)
rsync -a \
  --exclude '/refs/' \
  --exclude '/.cursor/' \
  --exclude '/REPORT.md' \
  --exclude '/latexmkrc' \
  --exclude '/main.pdf' \
  --exclude '/main.synctex.gz' \
  --exclude '*.aux' \
  --exclude '*.bbl' \
  --exclude '*.blg' \
  --exclude '*.fdb_latexmk' \
  --exclude '*.fls' \
  --exclude '*.log' \
  --exclude '*.out' \
  --exclude '*.toc' \
  --exclude '*.synctex.gz' \
  --exclude '*.synctex(busy)' \
  --exclude '.DS_Store' \
  --exclude '.gitkeep' \
  "$EGS_DIR"/ "$DEST"/

# Copy template/ to DEST/template/ so \documentclass{template/amphion}
# resolves from the project root.
# CHANGELOG.md is mono-repo bookkeeping; the colour-swatch HTML is dev-only.
rsync -a \
  --exclude '/CHANGELOG.md' \
  --exclude '/assets/test_theme_colors.html' \
  --exclude '.DS_Store' \
  "$TPL_DIR"/ "$DEST/template"/

# Sanity-check: the flat project must contain everything main.tex names.
required=(
  main.tex
  references.bib
  template/amphion.cls
  template/asr-macros.sty
  template/IEEEtran2.bst
  template/venues.bib
  figures/architecture.pdf
)
missing=()
for f in "${required[@]}"; do
  if [[ ! -e "$DEST/$f" ]]; then
    missing+=("$f")
  fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: required files missing in $DEST:" >&2
  for f in "${missing[@]}"; do
    echo "  - $f" >&2
  done
  exit 1
fi

echo "[overleaf-pack] flat project ready at $DEST"

if [[ "$DO_ZIP" -eq 1 ]]; then
  ZIP_PARENT="$(dirname "$DEST")"
  ZIP_NAME="$(basename "$DEST").zip"
  ZIP_PATH="$ZIP_PARENT/$ZIP_NAME"
  rm -f "$ZIP_PATH"
  (cd "$ZIP_PARENT" && zip -qr "$ZIP_NAME" "$(basename "$DEST")")
  echo "[overleaf-pack] zip ready at $ZIP_PATH"
fi

cat <<EOF

Next steps:
  A. New Overleaf project:
       Overleaf -> New Project -> Upload Project -> select the .zip above
  B. Re-sync existing project via Git Bridge:
       git clone https://git.overleaf.com/<id> overleaf-mirror
       tools/overleaf-pack.sh $SLUG --no-zip --output-dir overleaf-mirror
       cd overleaf-mirror && git add -A && \\
           git commit -m "sync from mono-repo" && git push
EOF
