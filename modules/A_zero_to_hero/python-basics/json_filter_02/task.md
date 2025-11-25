# JSON Filter 02 – Active Users
# System Health 03 – System Metrics Reporter

Write a Python script that:
Write a Python script that checks the local system's health and prints a JSON report.

1. Reads `users.json` from the current directory.
2. Filters only users where `active` is `true`.
3. Prints them as pretty JSON.
The report should include:
1.  CPU usage percentage.
2.  Memory usage percentage.
3.  Disk usage percentage for the root filesystem (`/`).

Example input:
Example output (values will vary):

```json
[
  {"name": "alice", "active": true},
  {"name": "bob", "active": false}
]
{
  "cpu_percent": 12.5,
  "memory_percent": 58.3,
  "disk_percent": 45.1
}
```

Expected output:
Requirements:

```json
[
  {"name": "alice", "active": true}
]
- Implement `get_system_health() -> dict`.
- Use the `psutil` library to fetch system metrics.
- The script should print the report as a JSON string when executed.
- Create a `requirements.txt` file listing the `psutil` dependency.

To install the dependency:
```sh
pip install -r requirements.txt
```

Requirements:

- Implement `filter_active_users(path: str) -> list`.
- Use `json` module.
- When run as script, read `users.json` and print filtered list.
