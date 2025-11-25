# Bash Basics Exercises

This directory contains 11 bash scripting exercises designed to build foundational DevOps skills.

## Exercises

1. **text_stats_01.sh** - Count lines, words, and characters in a file
   ```bash
   ./text_stats_01.sh filename.txt
   ```

2. **http_check_02.sh** - Check if a URL is accessible
   ```bash
   ./http_check_02.sh https://example.com
   ```

3. **backup_script_03.sh** - Create timestamped backups of directories
   ```bash
   ./backup_script_03.sh /path/to/directory [backup_location]
   ```

4. **user_management_04.sh** - List system users and their login status
   ```bash
   ./user_management_04.sh
   ```

5. **file_organizer_05.sh** - Organize files by extension into directories
   ```bash
   ./file_organizer_05.sh /path/to/messy/directory
   ```

6. **service_checker_06.sh** - Check status of common system services
   ```bash
   ./service_checker_06.sh
   ```

7. **disk_cleanup_07.sh** - Find and optionally remove large files
   ```bash
   ./disk_cleanup_07.sh [size_in_mb] [list|remove]
   ```

8. **json_parsing_jq_08.sh** - Parse JSON files using jq
   ```bash
   ./json_parsing_jq_08.sh data.json [jq_filter]
   ```

9. **ssl_cert_check_09.sh** - Check SSL certificate expiration
   ```bash
   ./ssl_cert_check_09.sh example.com [port]
   ```

10. **log_rotation_10.sh** - Rotate log files when they exceed size limit
    ```bash
    ./log_rotation_10.sh /path/to/logfile [max_size_mb]
    ```

11. **port_scanner_11.sh** - Check if ports are open on a host
    ```bash
    ./port_scanner_11.sh hostname 80 443 22 3000
    ```

## Prerequisites

- Bash shell
- Basic Unix utilities (curl, tar, openssl, etc.)
- jq (for JSON parsing exercise)

## Learning Path

Start with the simpler exercises (1-4) and progress to more complex ones (8-11). Each script includes error handling and usage instructions.