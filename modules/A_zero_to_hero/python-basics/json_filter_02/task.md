# JSON Filter 02 – Active Users

Write a Python script that:

1. Reads `users.json` from the current directory.
2. Filters only users where `active` is `true`.
3. Prints them as pretty JSON.

Example input:

```json
[
  {"name": "alice", "active": true},
  {"name": "bob", "active": false}
]
```

Expected output:

```json
[
  {"name": "alice", "active": true}
]
```

Requirements:

- Implement `filter_active_users(path: str) -> list`.
- Use `json` module.
- When run as script, read `users.json` and print filtered list.
