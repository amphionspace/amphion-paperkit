#!/usr/bin/env python3
"""
fetch-refs.py — Download reference PDFs declared in INDEX.yaml.

Usage:
    python tools/fetch-refs.py egs/<slug> [--workers 4] [--force]

Behaviour:
    1. Parse egs/<slug>/refs/notes/papers/INDEX.yaml and
       egs/<slug>/refs/datasets/INDEX.yaml.
    2. Validate both against tools/schemas/refs-index.schema.json. Schema errors
       abort immediately with file path + JSON pointer of the violation.
    3. Cross-check that papers[*].group references a defined groups[*].id.
    4. For each paper entry:
         - File exists & sha256 matches yaml         -> SKIP
         - File exists & yaml sha256 is null          -> compute hash, fill into
                                                        yaml in memory; SKIP
         - File exists & yaml sha256 mismatches       -> MISMATCH (do not
                                                        overwrite unless --force)
         - File missing                                -> download via urllib;
                                                        verify sha256; if yaml
                                                        sha256 is null fill in;
                                                        if yaml sha256 set &
                                                        download mismatches FAIL
    5. Run downloads in a ThreadPoolExecutor (--workers, default 4).
    6. Print one progress line per entry:
           [N/M] [OK|SKIP|FAIL|MISMATCH] <file> (<size>)
    7. After all entries finish, print a summary and rewrite INDEX.yaml only
       if any sha256 was newly filled. Caller is expected to `git diff` and
       commit the yaml changes.
    8. Exit 0 iff Failed == 0 and Mismatch == 0.

Dependencies:
    pip install -r tools/requirements-fetch.txt
    (PyYAML>=6.0, jsonschema>=4.0)

Notes:
    - One try per URL (no retry / backoff in this version).
    - No dry-run / offline / lock-file (intentionally minimal).
    - Run from repo root: `python tools/fetch-refs.py egs/<slug>`.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import threading
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.stderr.write(
        "ERROR: PyYAML not installed. Run: pip install -r tools/requirements-fetch.txt\n"
    )
    sys.exit(2)

try:
    import jsonschema
except ImportError:
    sys.stderr.write(
        "ERROR: jsonschema not installed. Run: pip install -r tools/requirements-fetch.txt\n"
    )
    sys.exit(2)


REPO_ROOT = Path(__file__).resolve().parent.parent
SCHEMA_PATH = REPO_ROOT / "tools" / "schemas" / "refs-index.schema.json"
INDEX_RELPATHS = [
    Path("refs/notes/papers/INDEX.yaml"),
    Path("refs/datasets/INDEX.yaml"),
]
CHUNK = 64 * 1024
USER_AGENT = "amphion-fetch-refs/1.0 (+https://amphion.dev)"


@dataclass
class Job:
    index_yaml: Path
    index_dir: Path
    entry_idx: int
    file: str
    url: str
    expected_sha256: str | None


@dataclass
class Result:
    job: Job
    status: str
    detail: str
    new_sha256: str | None


PRINT_LOCK = threading.Lock()


def progress(msg: str) -> None:
    with PRINT_LOCK:
        print(msg, flush=True)


def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while True:
            chunk = f.read(CHUNK)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def human_size(n: int) -> str:
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f}{unit}" if unit != "B" else f"{n}{unit}"
        n /= 1024
    return f"{n:.1f}TB"


def download(url: str, dest: Path) -> int:
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(dest.suffix + ".part")
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    total = 0
    try:
        with urllib.request.urlopen(req) as resp, tmp.open("wb") as out:
            while True:
                chunk = resp.read(CHUNK)
                if not chunk:
                    break
                out.write(chunk)
                total += len(chunk)
        tmp.replace(dest)
        return total
    except Exception:
        if tmp.exists():
            try:
                tmp.unlink()
            except OSError:
                pass
        raise


def process_job(job: Job, force: bool) -> Result:
    target = job.index_dir / job.file
    expected = job.expected_sha256

    if target.exists() and not force:
        actual = sha256_of(target)
        if expected is None:
            return Result(job, "SKIP", f"sha256 filled in: {actual}", actual)
        if actual == expected:
            return Result(job, "SKIP", "sha256 OK", None)
        return Result(
            job,
            "MISMATCH",
            f"existing file sha256 {actual} != yaml {expected}",
            None,
        )

    try:
        size = download(job.url, target)
    except Exception as exc:
        return Result(job, "FAIL", f"{type(exc).__name__}: {exc}", None)

    actual = sha256_of(target)
    if expected is not None and actual != expected:
        return Result(
            job,
            "MISMATCH",
            f"downloaded sha256 {actual} != yaml {expected}; kept new file",
            None,
        )
    if expected is None:
        return Result(job, "OK", f"downloaded {human_size(size)}; sha256 filled", actual)
    return Result(job, "OK", f"downloaded {human_size(size)}; sha256 OK", None)


def load_yaml(path: Path) -> dict:
    if not path.exists():
        sys.stderr.write(f"ERROR: missing {path.relative_to(REPO_ROOT)}\n")
        sys.exit(2)
    try:
        with path.open("r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except yaml.YAMLError as exc:
        sys.stderr.write(f"ERROR: invalid YAML in {path}: {exc}\n")
        sys.exit(2)


def dump_yaml(path: Path, data: dict) -> None:
    with path.open("w", encoding="utf-8") as f:
        yaml.safe_dump(
            data,
            f,
            sort_keys=False,
            allow_unicode=True,
            default_flow_style=False,
            width=100,
        )


def validate_schema(yaml_path: Path, data: dict, schema: dict) -> None:
    rel = yaml_path.relative_to(REPO_ROOT)
    try:
        jsonschema.validate(instance=data, schema=schema)
    except jsonschema.ValidationError as exc:
        path = "/".join(str(p) for p in exc.absolute_path) or "<root>"
        sys.stderr.write(
            f"ERROR: schema violation in {rel} at /{path}: {exc.message}\n"
        )
        sys.exit(2)
    group_ids = {g["id"] for g in data["groups"]}
    for i, paper in enumerate(data["papers"]):
        if paper["group"] not in group_ids:
            sys.stderr.write(
                f"ERROR: {rel} papers[{i}] '{paper['file']}' references "
                f"undefined group '{paper['group']}'. "
                f"Known groups: {sorted(group_ids)}\n"
            )
            sys.exit(2)


def collect_jobs(yaml_path: Path, data: dict) -> list[Job]:
    index_dir = yaml_path.parent
    jobs: list[Job] = []
    for i, paper in enumerate(data["papers"]):
        jobs.append(
            Job(
                index_yaml=yaml_path,
                index_dir=index_dir,
                entry_idx=i,
                file=paper["file"],
                url=paper["url"],
                expected_sha256=paper.get("sha256"),
            )
        )
    return jobs


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("egs_path", help="Path to an egs directory, e.g. egs/amphion-asr-2026")
    parser.add_argument("--workers", type=int, default=4, help="Parallel download workers (default 4)")
    parser.add_argument("--force", action="store_true", help="Re-download even if file exists")
    args = parser.parse_args()

    egs_dir = (REPO_ROOT / args.egs_path).resolve() if not Path(args.egs_path).is_absolute() else Path(args.egs_path)
    if not egs_dir.is_dir():
        sys.stderr.write(f"ERROR: not a directory: {egs_dir}\n")
        return 2

    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))

    yaml_states: list[tuple[Path, dict]] = []
    all_jobs: list[Job] = []
    for relpath in INDEX_RELPATHS:
        yaml_path = egs_dir / relpath
        data = load_yaml(yaml_path)
        validate_schema(yaml_path, data, schema)
        yaml_states.append((yaml_path, data))
        all_jobs.extend(collect_jobs(yaml_path, data))

    total = len(all_jobs)
    if total == 0:
        progress("No entries to process.")
        return 0

    progress(f"Processing {total} entries from {len(yaml_states)} INDEX.yaml file(s) with {args.workers} worker(s).")

    counts = {"OK": 0, "SKIP": 0, "FAIL": 0, "MISMATCH": 0}
    fills: dict[Path, dict[int, str]] = {p: {} for p, _ in yaml_states}
    completed = 0

    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {pool.submit(process_job, job, args.force): job for job in all_jobs}
        for fut in as_completed(futures):
            job = futures[fut]
            res = fut.result()
            completed += 1
            counts[res.status] += 1
            progress(f"[{completed:>3}/{total}] [{res.status:<8}] {job.file} — {res.detail}")
            if res.new_sha256 is not None:
                fills[job.index_yaml][job.entry_idx] = res.new_sha256

    for yaml_path, data in yaml_states:
        new_hashes = fills[yaml_path]
        if not new_hashes:
            continue
        for idx, h in new_hashes.items():
            data["papers"][idx]["sha256"] = h
        dump_yaml(yaml_path, data)
        progress(f"Updated {yaml_path.relative_to(REPO_ROOT)} with {len(new_hashes)} new sha256 value(s); please git diff and commit.")

    progress("")
    progress("Summary:")
    progress(f"  Downloaded: {counts['OK']}")
    progress(f"  Skipped:    {counts['SKIP']}")
    progress(f"  Failed:     {counts['FAIL']}")
    progress(f"  Mismatch:   {counts['MISMATCH']}")

    if counts["FAIL"] > 0 or counts["MISMATCH"] > 0:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
