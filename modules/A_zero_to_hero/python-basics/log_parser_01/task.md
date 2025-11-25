# Log Aggregator 08 – Directory Log Scanner

Write a Python script that scans a directory for `.log` files, searches for lines containing "ERROR", and aggregates a count of errors per file.

The script must:
1.  Accept a directory path as a command-line argument.
2.  Recursively search for all files ending in `.log`.
3.  For each file, count the number of lines that contain the word "ERROR".
4.  Print a JSON object where keys are file paths and values are the error counts.

Example output:
```json
{
  "logs/app1/server.log": 15,
  "logs/app2/server.log": 0,
  "logs/db/postgres.log": 3
}
```