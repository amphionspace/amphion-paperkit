#!/usr/bin/env bash
# Bootstrap a new technical report under egs/<slug>/ from egs/_skeleton/.
#
# Usage:
#   tools/new-report.sh <slug> \
#       --title    "Report title (full)"            \
#       --shortname "ShortName"                     \
#       --author   "Author Names"                   \
#       [--date    "YYYY.MM.DD"]                    \
#       [--venue   "arXiv | ICLR-2026 | ..."]       \
#       [--github-url   "https://github.com/..."]   \
#       [--github-slug  "org/repo"]                 \
#       [--maintainers "@user1, @user2"]            \
#       [--subject "cs.CL, cs.SD"]                  \
#       [--keywords "Speech, ASR, ..."]
#
# What it does:
#   1. cp -r egs/_skeleton/ egs/<slug>/
#   2. Substitute the <<NAME>> placeholders in main.tex / REPORT.md /
#      ack/llm-usage.md / sections/00_abstract.tex.
#   3. Print follow-up instructions.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  sed -n '3,22p' "$0"
  exit 2
fi

SLUG="$1"
shift

TITLE=""
SHORTNAME=""
AUTHOR=""
DATE="$(date +%Y.%m.%d)"
VENUE="arXiv"
GITHUB_URL="https://github.com/amphionspace/technical-reports"
GITHUB_SLUG="amphionspace/technical-reports"
MAINTAINERS="TBD"
SUBJECT="cs.CL"
KEYWORDS="TBD"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title)        TITLE="$2";        shift 2 ;;
    --shortname)    SHORTNAME="$2";    shift 2 ;;
    --author)       AUTHOR="$2";       shift 2 ;;
    --date)         DATE="$2";         shift 2 ;;
    --venue)        VENUE="$2";        shift 2 ;;
    --github-url)   GITHUB_URL="$2";   shift 2 ;;
    --github-slug)  GITHUB_SLUG="$2";  shift 2 ;;
    --maintainers)  MAINTAINERS="$2";  shift 2 ;;
    --subject)      SUBJECT="$2";      shift 2 ;;
    --keywords)     KEYWORDS="$2";     shift 2 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$TITLE" || -z "$SHORTNAME" || -z "$AUTHOR" ]]; then
  echo "Error: --title, --shortname, --author are required." >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$REPO_ROOT/egs/_skeleton"
DST_DIR="$REPO_ROOT/egs/$SLUG"

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: skeleton dir not found at $SRC_DIR" >&2
  exit 1
fi

if [[ -e "$DST_DIR" ]]; then
  echo "Error: $DST_DIR already exists; pick a different slug." >&2
  exit 1
fi

cp -r "$SRC_DIR" "$DST_DIR"

# Substitute placeholders in every file under the new egs.
substitute() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  sed \
    -e "s|<<SLUG>>|$SLUG|g" \
    -e "s|<<TITLE>>|$TITLE|g" \
    -e "s|<<SHORTNAME>>|$SHORTNAME|g" \
    -e "s|<<AUTHOR>>|$AUTHOR|g" \
    -e "s|<<DATE>>|$DATE|g" \
    -e "s|<<VENUE>>|$VENUE|g" \
    -e "s|<<GITHUB-URL>>|$GITHUB_URL|g" \
    -e "s|<<GITHUB-SLUG>>|$GITHUB_SLUG|g" \
    -e "s|<<MAINTAINERS>>|$MAINTAINERS|g" \
    -e "s|<<SUBJECT>>|$SUBJECT|g" \
    -e "s|<<KEYWORDS>>|$KEYWORDS|g" \
    "$file" > "$tmp"
  mv "$tmp" "$file"
}

while IFS= read -r -d '' f; do
  case "$f" in
    *.gitkeep) continue ;;
  esac
  substitute "$f"
done < <(find "$DST_DIR" -type f -print0)

cat <<EOF
[ok] Bootstrapped egs/$SLUG/ from egs/_skeleton/.

Next steps:
  1. cd egs/$SLUG && latexmk -pdf main.tex   # smoke-build the placeholder PDF
  2. Drop internal docs into egs/$SLUG/refs/docs/
  3. Fill sections/ in the order recommended by paper-writing.mdc
  4. Add an entry for this report to the top-level README.md table
  5. Update egs/$SLUG/REPORT.md as the report progresses
EOF
