# Lab Task: Query a Public Dataset with BigQuery

## Objective

Your task is to use the `bq` command-line tool to run an SQL query against a BigQuery public dataset to find the most popular Shakespeare works.

## Background

BigQuery hosts a variety of public datasets, including one containing the complete works of William Shakespeare (`bigquery-public-data.samples.shakespeare`). Each row in the table represents a single word from a play.

## Requirements

1.  **Formulate a Query**:
    -   Write an SQL query that:
        -   Selects from the `bigquery-public-data.samples.shakespeare` table.
        -   Counts the number of words in each work (`corpus`).
        -   Groups the results by the corpus.
        -   Orders the results in descending order of word count.
        -   Limits the result to the top 10 most wordy works.

2.  **Execute the Query**:
    -   Use the `bq query` command to execute your SQL query.
    -   Use the `--use_legacy_sql=false` flag to ensure you are using standard SQL.

3.  **Verification**:
    -   The output should be a table showing the 10 longest Shakespeare works, with `Hamlet` at the top.
    -   Provide the full `bq` command and the SQL query you used.

## Example Schema

The `bigquery-public-data.samples.shakespeare` table has the following relevant columns:
-   `word`: A single word from a play (string).
-   `corpus`: The name of the work (e.g., 'hamlet', 'kinglear') (string).
-   `word_count`: The total number of words in the row (always 1).
