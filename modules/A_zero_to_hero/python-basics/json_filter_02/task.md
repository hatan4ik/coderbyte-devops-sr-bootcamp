# Backup Script 03 – Automated Directory Backup

Write a Bash script that creates a compressed backup of a specified directory.

The script must:
1.  Accept two arguments: the source directory to back up and the destination directory where the backup file will be stored.
2.  Create a `tar.gz` archive of the source directory.
3.  The archive filename must be in the format: `backup_YYYY-MM-DD_HHMMSS.tar.gz`.
4.  Print the full path to the created backup file on success.
5.  Exit with a non-zero status code and print an error message if the number of arguments is incorrect, or if the source directory does not exist.

Example usage:

```sh
./solution.sh /var/log /tmp/backups
```

Expected output:

```text
/tmp/backups/backup_2024-11-03_123000.tar.gz
```