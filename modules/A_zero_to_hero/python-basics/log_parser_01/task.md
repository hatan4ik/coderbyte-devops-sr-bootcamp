# Log Parser 01 – Failed Login Counter
# Config Parser 12 – INI File Reader
# Log Aggregator 08 – Directory Log Scanner

Write a Python script that:
Write a Python script that reads a configuration file named `app.ini` and prints the value of a specific key.
Write a Python script that scans a directory for `.log` files, searches for lines containing "ERROR", and aggregates a count of errors per file.

1. Reads `server.log` in the current directory.
2. Counts login failures.
3. Lists unique usernames that failed.
The script must:
1.  Read `app.ini` using the `configparser` module.
2.  Extract the value of the `api_key` from the `[database]` section.
3.  Print the retrieved value.
4.  Handle potential errors, such as the file, section, or key not being found.
1.  Accept a directory path as a command-line argument.
2.  Recursively search for all files ending in `.log`.
3.  For each file, count the number of lines that contain the word "ERROR".
4.  Print a JSON object where keys are file paths and values are the error counts.

Lines to match look like:
Example `app.ini`:
```ini
[server]
host = 127.0.0.1
port = 8080

```text
2024-11-03 12:27:01 ERROR login failed: user=admin ip=10.10.1.5
[database]
user = admin
api_key = abc-123-def-456
```

Expected JSON output:

Example output:
```json
{
  "failed_attempts": 2,
  "unique_users": ["admin", "root"]
  "logs/app1/server.log": 15,
  "logs/app2/server.log": 0,
  "logs/db/postgres.log": 3
}
Expected output:
```

Requirements:

- Implement `parse_log(file_path: str) -> dict`.
- Use `re` to parse lines.
- When run as a script, read `server.log` and print JSON.
Database API Key: abc-123-def-456
```
