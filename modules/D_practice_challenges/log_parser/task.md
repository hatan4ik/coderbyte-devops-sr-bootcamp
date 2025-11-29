# Challenge: Log Parser Summary

Write `log_summary.py` that:

1. Accepts a log file path as first argument.
2. Counts:
   - total lines
   - lines containing the word `ERROR`
   - lines containing the word `WARN`
3. Prints JSON:

```json
{
  "total": 10,
  "errors": 3,
  "warnings": 2
}
```
