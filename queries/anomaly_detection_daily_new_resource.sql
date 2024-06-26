WITH ranked_accesses AS (
  SELECT *,
         ROW_NUMBER() OVER(PARTITION BY USER_NAME,DATABASE_NAME ORDER BY CAST(START_TIME AS TIMESTAMP)) AS row_number,
         TO_DATE(CAST(START_TIME AS TIMESTAMP)) AS access_date
  FROM snowflake.account_usage.query_history
),
first_time_accesses AS (
  SELECT access_date, USER_NAME,DATABASE_NAME 
  from ranked_accesses
  WHERE row_number = 1
),
daily_new_resource_count AS (
  SELECT access_date, USER_NAME, COUNT(DISTINCT DATABASE_NAME) AS count, ARRAY_AGG(DISTINCT DATABASE_NAME) AS database_names
  FROM first_time_accesses
  GROUP BY access_date, USER_NAME 
),
stats AS (
  SELECT AVG(count) AS avg_count, STDDEV_POP(count) AS stddev_count
  FROM daily_new_resource_count
),
outlier_detection AS (
  SELECT *,
         (SELECT avg_count FROM stats) + 3 * (SELECT stddev_count FROM stats) AS upper_bound,
         (SELECT avg_count FROM stats) - 3 * (SELECT stddev_count FROM stats) AS lower_bound
  FROM daily_new_resource_count
)
SELECT *
FROM outlier_detection
WHERE count > upper_bound OR count < lower_bound
