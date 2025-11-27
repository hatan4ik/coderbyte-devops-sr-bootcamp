#!/bin/bash

# This script uses the bq CLI to query a public dataset.

# The SQL query to find the top 10 most popular Shakespeare works by word count.
SQL_QUERY="
  SELECT
    corpus,
    SUM(word_count) AS word_count
  FROM
    `bigquery-public-data.samples.shakespeare`
  GROUP BY
    corpus
  ORDER BY
    word_count DESC
  LIMIT 10
"

echo "-------------------------------------------"
echo "Running BigQuery query..."
echo "-------------------------------------------"
echo "Query:"
echo "$SQL_QUERY"
echo "-------------------------------------------"
echo "Results:"

# Execute the query using the bq command-line tool.
# --use_legacy_sql=false ensures we are using the standard SQL dialect.
bq query --use_legacy_sql=false "$SQL_QUERY"
