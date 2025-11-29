#!/usr/bin/env python3
"""Reproducible benchmarks for baseline vs FAANG implementations."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path
from typing import Dict, List, Tuple

import psutil

REPO_ROOT = Path(__file__).resolve().parents[1]


def generate_log_dataset(path: Path, lines: int) -> Tuple[Path, int]:
    """Generate a synthetic log file with deterministic content."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as handle:
        for i in range(lines):
            if i % 23 == 0:
                level = "ERROR"
            elif i % 17 == 0:
                level = "WARN"
            elif i % 5 == 0:
                level = "DEBUG"
            else:
                level = "INFO"
            handle.write(
                f"2024-01-01T00:00:{i % 60:02d}Z {level} "
                f"request_id={i:07d} user_id={i % 3000:05d} payload_size={i % 2048}\n"
            )
    return path, lines


def run_command(cmd: List[str]) -> Dict[str, float]:
    """Run a command, tracking wall time and peak RSS."""
    start = time.perf_counter()
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    proc = psutil.Process(process.pid)
    max_rss = 0.0

    while True:
        if process.poll() is not None:
            break
        try:
            max_rss = max(max_rss, proc.memory_info().rss)
        except psutil.NoSuchProcess:
            break
        time.sleep(0.02)

    try:
        max_rss = max(max_rss, proc.memory_info().rss)
    except psutil.NoSuchProcess:
        pass

    stderr = ""
    if process.stderr:
        stderr = process.stderr.read()

    duration = time.perf_counter() - start
    if process.returncode != 0:
        raise RuntimeError(f"Command failed ({process.returncode}): {' '.join(cmd)}\n{stderr}")

    return {
        "seconds": round(duration, 3),
        "max_rss_mb": round(max_rss / (1024**2), 2),
    }


def benchmark_log_parser(log_path: Path, lines: int) -> Dict[str, Dict[str, float]]:
    """Benchmark baseline and FAANG log parsers against the same dataset."""
    baseline_script = REPO_ROOT / "modules" / "A_zero_to_hero" / "python-basics" / "log_parser_01.py"
    faang_script = REPO_ROOT / "modules" / "A_zero_to_hero" / "python-basics" / "log_parser_faang.py"

    return {
        "dataset": str(log_path),
        "lines": lines,
        "baseline": run_command([sys.executable, str(baseline_script), str(log_path)]),
        "faang": run_command([sys.executable, str(faang_script), str(log_path), "--json"]),
    }


def format_markdown(results: Dict[str, Dict[str, Dict[str, float]]]) -> str:
    """Render results as a markdown table."""
    lines = [
        "Benchmark        Dataset         Runtime (s)   Max RSS (MB)",
        "---------------  --------------  ------------  -------------",
    ]
    log = results["log_parser"]
    dataset_label = f"{log['lines']} lines"
    lines.append(
        f"log_parser_base  {dataset_label:<14}  {log['baseline']['seconds']:<12}  "
        f"{log['baseline']['max_rss_mb']:<13}"
    )
    lines.append(
        f"log_parser_faang {dataset_label:<14}  {log['faang']['seconds']:<12}  "
        f"{log['faang']['max_rss_mb']:<13}"
    )
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Benchmark baseline vs FAANG implementations.")
    parser.add_argument("--log-lines", type=int, default=200_000, help="Lines to generate in log dataset.")
    parser.add_argument("--format", choices=["markdown", "json"], default="json", help="Output format.")
    args = parser.parse_args()

    dataset_path, lines = generate_log_dataset(REPO_ROOT / "benchmarking" / "artifacts" / "log_dataset.log", args.log_lines)
    results = {"log_parser": benchmark_log_parser(dataset_path, lines)}

    if args.format == "markdown":
        print(format_markdown(results))
    else:
        print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
