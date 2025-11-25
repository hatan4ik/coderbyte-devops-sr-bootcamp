# Bash HTTP Check 02 – Simple Health Probe

Write `http_check.sh` that:

1. Accepts URL as first arg.
2. Performs a GET with `curl` (silent).
3. Exits with:
   - code 0 if HTTP status is 200
   - code 1 otherwise

Also print:

```text
status=<code>
```
