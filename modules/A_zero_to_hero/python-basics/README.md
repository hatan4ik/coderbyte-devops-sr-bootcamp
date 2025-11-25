# Python Basics Exercises

This directory contains 12 Python exercises covering essential DevOps automation tasks.

## Exercises

1. **log_parser_01.py** - Parse log files and extract error patterns
   ```bash
   python log_parser_01.py /var/log/syslog
   ```

2. **json_filter_02.py** - Filter JSON data based on criteria
   ```bash
   python json_filter_02.py data.json [key] [value]
   ```

3. **system_health_03.py** - Monitor CPU, memory, and disk usage
   ```bash
   python system_health_03.py
   ```

4. **file_word_count_04.py** - Count words and find most frequent words
   ```bash
   python file_word_count_04.py document.txt
   ```

5. **csv_parser_05.py** - Parse and analyze CSV data
   ```bash
   python csv_parser_05.py data.csv
   ```

6. **api_client_06.py** - Make HTTP requests and handle responses
   ```bash
   python api_client_06.py https://api.example.com/data [GET|POST] [json_data]
   ```

7. **process_monitor_07.py** - Monitor running processes
   ```bash
   python process_monitor_07.py [process_name]
   ```

8. **log_aggregator_08.py** - Aggregate logs from multiple files
   ```bash
   python log_aggregator_08.py "/var/log/*.log"
   ```

9. **web_scraper_09.py** - Simple web scraping with requests
   ```bash
   python web_scraper_09.py https://example.com
   ```

10. **concurrency_basics_10.py** - Threading and multiprocessing examples
    ```bash
    python concurrency_basics_10.py
    ```

11. **docker_sdk_automation_11.py** - Manage Docker containers with Python
    ```bash
    python docker_sdk_automation_11.py list
    python docker_sdk_automation_11.py stats container_name
    ```

12. **config_parser_ini_12.py** - Parse INI configuration files
    ```bash
    python config_parser_ini_12.py config.ini
    ```

## Prerequisites

Install required packages:
```bash
pip install psutil requests docker beautifulsoup4
```

## Learning Path

1. Start with basic file operations (1, 4, 5, 12)
2. Move to system monitoring (3, 7)
3. Practice API and web interactions (6, 9)
4. Learn concurrency concepts (10)
5. Explore Docker automation (11)

Each script includes error handling and can be run independently.