#!/usr/bin/env bash
# Run AGENTS.md rule 4's regex self-check across egs/<slug>/sections/*.tex.
# Hits indicate that implementation-level details (file paths, class names,
# config field names, repo-internal scripts) leaked into the report prose
# and must be rewritten.
#
# Usage:
#   tools/fact-check-regex.sh                  # check all egs (skips _skeleton)
#   tools/fact-check-regex.sh egs/<slug>       # check one egs
#
# Exit status:
#   0 — clean
#   1 — at least one match found

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

PATTERN='\.py|\.sh|\.json|\.yaml|\.jsonl|\.gz|\.tar|src/|local/|configs/|/ai_sds_wuzz/|/data/'

declare -a TARGETS
if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
else
  while IFS= read -r -d '' d; do
    case "$(basename "$d")" in
      _skeleton|_*) continue ;;
    esac
    TARGETS+=("$d")
  done < <(find "$REPO_ROOT/egs" -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "[fact-check] no egs to check"
  exit 0
fi

hits=0
for t in "${TARGETS[@]}"; do
  [[ -d "$t/sections" ]] || continue
  if rg --color=never -n -e "$PATTERN" "$t/sections" 2>/dev/null; then
    hits=$((hits + 1))
  fi
done

if [[ $hits -gt 0 ]]; then
  echo "[fact-check] FAILED: implementation details leaked into report prose. See AGENTS.md rule 4." >&2
  exit 1
fi
echo "[fact-check] OK"
