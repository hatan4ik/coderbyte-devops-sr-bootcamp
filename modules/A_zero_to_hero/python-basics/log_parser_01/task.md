# Log Parser 01 – Failed Login Counter

Write a Python script that:

1. Reads `server.log` in the current directory.
2. Counts login failures.
3. Lists unique usernames that failed.

Lines to match look like:

```text
2024-11-03 12:27:01 ERROR login failed: user=admin ip=10.10.1.5
```

Expected JSON output:

```json
{
  "failed_attempts": 2,
  "unique_users": ["admin", "root"]
}
```

Requirements:

- Implement `parse_log(file_path: str) -> dict`.
- Use `re` to parse lines.
- When run as a script, read `server.log` and print JSON.
