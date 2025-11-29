# Benchmarking Guide

Benchmarks that substantiate the performance claims in the FAANG documentation. Runs compare baseline implementations against FAANG upgrades using reproducible datasets.

## What This Measures
- `log_parser_01.py` vs `log_parser_faang.py`
  - Workload: synthetic log file (default 200k lines, mixed INFO/WARN/ERROR)
  - Metrics: wall-clock runtime (seconds) and max RSS (MB) captured via `psutil`

## How to Run
```bash
# Install dependencies (managed with Poetry; see ENGINEERING.md)
poetry install

# Generate dataset + run benchmarks
poetry run python benchmarking/run_benchmarks.py --format markdown

# Default dataset is 200k lines; pass --log-lines 1000000 to match the published example below.
# Custom dataset size
poetry run python benchmarking/run_benchmarks.py --log-lines 400000 --format json
```

## Example Output (macOS M3 Pro, Python 3.11, 1M-line dataset)
```
Benchmark        Dataset         Runtime (s)   Max RSS (MB)
---------------  --------------  ------------  -------------
log_parser_base  1000000 lines   4.626         159.87
log_parser_faang 1000000 lines   14.922        74.6
```
*Interpretation*: the FAANG parser cuts peak RSS by ~2.1x due to streaming, but the additional validation/logging costs CPU. Choose based on whether memory safety or raw throughput is the priority for the workload.

## Methodology
- Synthetic dataset generation ensures repeatability and avoids leaking real logs.
- Subprocess execution is timed with `time.perf_counter`; memory is sampled during execution via `psutil.Process.memory_info().rss`.
- Benchmarks suppress stdout/stderr and fail fast on non-zero exits to avoid counting failed runs.
- Results are consumable as human-readable Markdown or machine-readable JSON for CI checks.

## Updating Claims
- After running, update `FAANG_CODE_STANDARDS.md`, `FAANG_COMPLETE.md`, and `FAANG_UPGRADE_REPORT.md` with the new measurements (reference the run date and dataset size).
- If results change materially, prefer ranges (e.g., “~2.5x faster on 200k-line dataset”) over absolute numbers to keep claims honest across environments.
