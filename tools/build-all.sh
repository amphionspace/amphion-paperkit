#!/usr/bin/env bash
# Build every active egs/<slug>/main.tex into a PDF.
# Skips egs/_skeleton/ and any directory whose name starts with "_".
#
# Usage:
#   tools/build-all.sh
#
# Exit status:
#   0 — all reports built
#   1 — at least one report failed to build

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LATEXMK="${LATEXMK:-latexmk}"

failed=()
built=()

for d in "$REPO_ROOT"/egs/*/; do
  slug="$(basename "$d")"
  case "$slug" in
    _*) continue ;;
  esac
  if [[ ! -f "$d/main.tex" ]]; then
    continue
  fi
  echo "=========================================="
  echo "[build] $slug"
  echo "=========================================="
  if (cd "$d" && "$LATEXMK" -pdf -interaction=nonstopmode main.tex); then
    built+=("$slug")
  else
    failed+=("$slug")
  fi
done

echo
echo "[build] succeeded: ${built[*]:-none}"
if [[ ${#failed[@]} -gt 0 ]]; then
  echo "[build] FAILED:    ${failed[*]}" >&2
  exit 1
fi
