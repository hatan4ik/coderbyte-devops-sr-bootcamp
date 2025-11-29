# Problem 1: Analyze Public Data with BigQuery

## Objective

Your task is to use the BigQuery web UI to run SQL queries against a large public dataset.

## Scenario

You are a data analyst trying to find interesting trends in the "USA Names" public dataset, which contains data on names given to babies in the United States from 1910 to 2013.

## Requirements

1.  **Navigate to BigQuery**: In the GCP Console, go to the BigQuery section.
2.  **Find the Public Dataset**: In the "Explorer" panel, click "+ Add Data" and select "Public datasets". Search for `usa_names` and add it to your project.
3.  **Run Queries**: Open a new query editor and run the following queries. For each one, look at the results and think about what they mean.

    -   **Query 1: Most popular names in a specific year**
        What were the top 5 most popular female names in 1985?
        ```sql
        SELECT name, SUM(number) as total
        FROM `bigquery-public-data.usa_names.usa_1910_2013`
        WHERE year = 1985 AND gender = 'F'
        GROUP BY name
        ORDER BY total DESC
        LIMIT 5;
        ```

    -   **Query 2: Trend of a specific name over time**
        How has the popularity of the name "Ashley" changed over the years?
        ```sql
        SELECT year, SUM(number) as total
        FROM `bigquery-public-data.usa_names.usa_1910_2013`
        WHERE name = 'Ashley'
        GROUP BY year
        ORDER BY year;
        ```
        (BigQuery has a nice feature to visualize this data as a chart directly from the query results!)

    -   **Query 3: Names that have become more gender-neutral**
        Find names that were once predominantly male but are now more common for females. (This is a more complex query!)
        ```sql
        -- This is a complex query, let's just find names with a close gender split in a recent year.
        SELECT name, SUM(IF(gender = 'M', number, 0)) as male_count, SUM(IF(gender = 'F', number, 0)) as female_count
        FROM `bigquery-public-data.usa_names.usa_1910_2013`
        WHERE year = 2010
        GROUP BY name
        HAVING male_count > 100 AND female_count > 100
        ORDER BY ABS(male_count - female_count)
        LIMIT 10;
        ```

## Verification

-   The queries should run without errors.
-   You should see the results of each query in the panel below the editor.

## Challenge

Write your own query to answer a question you have about the data. For example:
-   What are the most popular names that start with the letter 'Z'?
-   How many distinct names are there in the entire dataset?
-   What was the most popular name in the year you were born?
