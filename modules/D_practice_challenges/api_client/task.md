# Challenge: Simple API Client

Write `client.py` that:

1. Fetches JSON from URL given as first argument.
2. Assumes the JSON is a list of objects with `active` (bool) and `id` (string).
3. Prints a JSON list of IDs where `active == true`.

Example input:

```json
[
  {"id": "u1", "active": true},
  {"id": "u2", "active": false}
]
```

Output:

```json
["u1"]
```
