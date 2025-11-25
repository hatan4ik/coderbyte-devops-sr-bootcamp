# Sample Data Files

This directory contains sample data files for testing the Module A exercises.

## Files

- **sample.log** - Sample log file with INFO, WARNING, and ERROR entries
- **sample.json** - JSON array with server information
- **sample.csv** - CSV file with server metrics
- **sample.txt** - Plain text file for word counting exercises

## Usage Examples

Test the exercises with these sample files:

```bash
# Bash exercises
./bash-basics/text_stats_01.sh sample_data/sample.txt
./bash-basics/json_parsing_jq_08.sh sample_data/sample.json '.[] | select(.status == "running")'

# Python exercises
python python-basics/log_parser_01.py sample_data/sample.log
python python-basics/json_filter_02.py sample_data/sample.json status running
python python-basics/csv_parser_05.py sample_data/sample.csv
python python-basics/file_word_count_04.py sample_data/sample.txt

# Go exercises
go run go-basics/file_read_02.go sample_data/sample.txt
```