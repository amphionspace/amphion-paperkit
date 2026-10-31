#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "PyYAML>=6.0",
# ]
# ///
"""
fetch-eval.py — Mirror AmphionEval results from the team bucket into an egs.

Usage:
    uv run tools/fetch-eval.py egs/<slug> [--overwrite]

AmphionEval (`ae`) publishes every evaluation run to a team COS bucket:
`records/<task>/<YYYY-MM>/<run-id>.json` holds the per-run summary that the
leaderboard reads, and `eval-sets/<project>/<name>@<version>/` holds the
test-set registrations (labels, groups, sample counts). This script pulls the
prefixes a report declares, read-only, through AmphionBucket (`ab`).

Behaviour:
    1. Read egs/<slug>/refs/internal/amphion-eval.yaml:
           bucket: <bucket>:<root>/       # AmphionEval team root
           pull:                          # prefixes relative to that root
             - records/asr/2026-10/
             - eval-sets/open-audio-llm/<name>@<version>/
       A missing file means the report uses no AmphionEval data (exit 0).
    2. `ab pull <bucket><prefix> egs/<slug>/refs/internal/amphion-eval/<prefix>`
       for every prefix. The local layout matches an `ae` state directory, so
       `ae --state-dir egs/<slug>/refs/internal/amphion-eval ...` and scripts
       written against `ae sync` output read it unchanged.
    3. Identical files are skipped by `ab`. A file that changed in the bucket
       (records are sometimes rewritten, e.g. to unify model names) is reported
       as a conflict; rerun with --overwrite to take the bucket version.
    4. Print how many records exist per benchmark and model.
    5. Exit 0 iff every pull succeeded.

The mirror is gitignored: records contain subsets that must not leave the
company. Numbers reach the
report only through tables or sanitised data files that follow the report's
own external-facing rules (see egs/<slug>/refs/docs/plan.md).
"""

from __future__ import annotations

import argparse
import collections
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "ERROR: PyYAML not installed. Run via uv: `uv run tools/fetch-eval.py ...`.\n"
    )
    sys.exit(2)


REPO_ROOT = Path(__file__).resolve().parent.parent
CONFIG_RELPATH = Path("refs/internal/amphion-eval.yaml")
MIRROR_RELPATH = Path("refs/internal/amphion-eval")


def find_ab() -> str | None:
    found = shutil.which("ab")
    if found:
        return found
    fallback = Path.home() / ".local" / "bin" / "ab"
    return str(fallback) if fallback.is_file() and os.access(fallback, os.X_OK) else None


def load_config(path: Path) -> tuple[str, list[str]]:
    data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
    bucket = data.get("bucket")
    prefixes = data.get("pull") or []
    if not isinstance(bucket, str) or ":" not in bucket:
        sys.stderr.write(f"ERROR: {path}: 'bucket' must look like '<bucket>:<root>/'\n")
        sys.exit(2)
    if not isinstance(prefixes, list) or not all(isinstance(p, str) and p for p in prefixes):
        sys.stderr.write(f"ERROR: {path}: 'pull' must be a list of prefixes\n")
        sys.exit(2)
    for p in prefixes:
        if p.startswith("/") or ".." in Path(p).parts:
            sys.stderr.write(f"ERROR: {path}: prefix must be relative to the bucket root: {p}\n")
            sys.exit(2)
    return bucket.rstrip("/") + "/", prefixes


def summarise(mirror: Path) -> None:
    counts: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    for f in sorted((mirror / "records").rglob("*.json")):
        try:
            rec = json.loads(f.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        counts[rec.get("benchmark") or "(none)"][rec.get("model_name") or "(none)"] += 1
    if not counts:
        return
    print("\nrecords per benchmark / model:")
    for bench in sorted(counts):
        models = counts[bench]
        print(f"  {bench}  ({sum(models.values())})")
        for model, n in sorted(models.items()):
            print(f"      {n:4d}  {model}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("egs_path", help="Path to an egs directory, e.g. egs/amphion-asr-2.0-2026")
    parser.add_argument("--overwrite", action="store_true",
                        help="Replace local files whose bucket copy changed (passed to `ab pull`)")
    args = parser.parse_args()

    egs_dir = Path(args.egs_path)
    egs_dir = egs_dir if egs_dir.is_absolute() else (Path.cwd() / egs_dir)
    egs_dir = egs_dir.resolve()
    config = egs_dir / CONFIG_RELPATH
    if not config.is_file():
        print(f"no {CONFIG_RELPATH} in {egs_dir.name}; nothing to fetch")
        return 0

    ab = find_ab()
    if ab is None:
        sys.stderr.write(
            "ERROR: AmphionBucket (`ab`) not found on PATH or at ~/.local/bin/ab.\n"
            "Install it from the releases of the team's AmphionBucket repository.\n"
        )
        return 2

    bucket, prefixes = load_config(config)
    mirror = egs_dir / MIRROR_RELPATH
    failed = []
    for i, prefix in enumerate(prefixes, 1):
        dest = mirror / prefix
        dest_arg = str(dest) + ("/" if prefix.endswith("/") else "")
        if prefix.endswith("/"):
            dest.mkdir(parents=True, exist_ok=True)
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
        cmd = [ab, "pull", bucket + prefix, dest_arg] + (["--overwrite"] if args.overwrite else [])
        print(f"[{i}/{len(prefixes)}] {bucket}{prefix}", flush=True)
        if subprocess.run(cmd).returncode != 0:
            failed.append(prefix)

    summarise(mirror)
    if failed:
        sys.stderr.write("\nFAILED or conflicting prefixes (see `ab` output above):\n")
        for p in failed:
            sys.stderr.write(f"  {p}\n")
        sys.stderr.write("Rerun with --overwrite to take the bucket version of changed files.\n")
        return 1
    print(f"\nmirror: {mirror.relative_to(REPO_ROOT) if mirror.is_relative_to(REPO_ROOT) else mirror}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
