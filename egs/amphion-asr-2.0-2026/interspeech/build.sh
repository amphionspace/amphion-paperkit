#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if command -v latexmk >/dev/null 2>&1; then
  latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
elif [[ -x "$HOME/tools/tex/bin/tectonic" ]]; then
  "$HOME/tools/tex/bin/tectonic" --keep-logs --keep-intermediates main.tex
else
  printf '%s\n' 'Install TeX Live with latexmk, or provide Tectonic in ~/tools/tex/bin.' >&2
  exit 1
fi
