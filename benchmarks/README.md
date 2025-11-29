# Benchmarking Methodology

Reproducible benchmarks validating performance claims in `FAANG_COMPLETE.md`.

## Methodology

- **Tool:** Python `timeit` (1000 iterations)
- **Hardware:** 4-core, 8GB RAM baseline
- **Datasets:** Production-scale samples in `datasets/`
- **Metrics:** Execution time, memory (via `memory_profiler`)

## Benchmarks

| Script | Claim | Dataset |
|--------|-------|---------|
| `log_parser_benchmark.py` | 3.75x faster | 100K log lines |
| `system_health_benchmark.py` | 2.9x faster | 50 concurrent checks |
| `http_check_benchmark.py` | 7.2x faster | 100 endpoints |

## Running

```bash
cd benchmarks
pip install -r requirements.txt
python log_parser_benchmark.py
```

Results saved to `results/` with timestamps.
