# Bash: Top IPs from Log

Small utility to print the top N client IPs from a log file (default N=5).

## Usage
```bash
./top_ips.sh access.log [N]
```
- Validates input file exists.
- Defaults to top 5.
- Outputs lines as `count ip` sorted descending.

## Test
```bash
./tests.sh
```
