WITH error_stats AS (
SELECT date, USER_NAME8, COUNT(*) AS error_count
FROM query_history
WHERE error_code != 'NULL'
GROUP BY date, USER_NAME8),

total_queries AS (
SELECT date, USER_NAME8, COUNT(*) AS total_queries
FROM query_history
GROUP BY date, USER_NAME8),

final_stats AS (
SELECT tq.date, tq.USER_NAME8, tq.total_queries, 
       COALESCE(es.error_count, 0) AS error_count,
       (COALESCE(es.error_count, 0) / tq.total_queries) * 100 AS daily_error_percentage
FROM total_queries tq
LEFT JOIN error_stats es ON tq.date = es.date AND tq.USER_NAME8 = es.USER_NAME8)

SELECT * FROM final_stats;