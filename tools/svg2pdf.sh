#!/usr/bin/env bash
# Convert SVG figures to vector PDF for \includegraphics.
# Text in the SVG should use font-family="TeX Gyre Pagella" (the report body
# font); the TeX Live copy of that font is made visible to fontconfig for this
# run only, so nothing has to be installed system-wide.
#
# Usage:
#   tools/svg2pdf.sh egs/<slug>/figures/<name>.svg [more.svg ...]
#   -> writes egs/<slug>/figures/<name>.pdf next to each SVG
#
# Requires rsvg-convert (librsvg: apt install librsvg2-bin / brew install librsvg)
# and kpsewhich (TeX Live).
#
# Exit status:
#   0 — all files converted
#   1 — at least one conversion failed
#   2 — usage error, or rsvg-convert / kpsewhich missing

set -uo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: $0 <figure.svg> [more.svg ...]" >&2
  exit 2
fi
for tool in rsvg-convert kpsewhich; do
  if ! command -v "$tool" >/dev/null; then
    echo "[svg2pdf] $tool not found" >&2
    exit 2
  fi
done

gyre="$(kpsewhich -var-value TEXMFDIST)/fonts/opentype/public/tex-gyre"
if [[ ! -d "$gyre" ]]; then
  echo "[svg2pdf] TeX Gyre fonts not found under $gyre (tlmgr install tex-gyre)" >&2
  exit 2
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/fonts.conf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
  <dir>$gyre</dir>
  <cachedir>$tmp/cache</cachedir>
</fontconfig>
EOF

failed=0
for svg in "$@"; do
  pdf="${svg%.svg}.pdf"
  if FONTCONFIG_FILE="$tmp/fonts.conf" rsvg-convert -f pdf -o "$pdf" "$svg"; then
    echo "[svg2pdf] $svg -> $pdf"
  else
    echo "[svg2pdf] failed: $svg" >&2
    failed=1
  fi
done
exit "$failed"
