#!/bin/bash
# Test runner for Module A exercises

echo "=== Module A - Zero to Hero Test Runner ==="
echo

# Test Bash exercises
echo "Testing Bash exercises..."
echo "1. Text statistics:"
./bash-basics/text_stats_01.sh sample_data/sample.txt

echo -e "\n2. File word count (Python):"
python python-basics/file_word_count_04.py sample_data/sample.txt

echo -e "\n3. Log parser (Python):"
python python-basics/log_parser_01.py sample_data/sample.log

echo -e "\n4. JSON filter (Python):"
python python-basics/json_filter_02.py sample_data/sample.json status running

echo -e "\n5. CSV parser (Python):"
python python-basics/csv_parser_05.py sample_data/sample.csv

echo -e "\n6. File read (Go):"
go run go-basics/file_read_02.go sample_data/sample.txt

echo -e "\n7. Hello World (Go):"
go run go-basics/hello_world_01.go DevOps

echo -e "\n8. System health (Python):"
python python-basics/system_health_03.py

echo -e "\nAll tests completed!"