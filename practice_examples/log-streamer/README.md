# Python: Concurrent Log Streaming Parser

Counts error lines across multiple log files concurrently, safe for large files (streaming). Outputs JSON with per-file counts and totals.

## Usage
```bash
python stream.py file1.log file2.log
# or glob via shell
python stream.py logs/*.log
```

## Features
- Streams files line-by-line (no full read into memory).
- Concurrent processing via ThreadPoolExecutor.
- Counts lines containing "ERROR" (case-insensitive).
- JSON output with per-file counts and total lines/total errors.

## Test
```bash
python tests.py
```
