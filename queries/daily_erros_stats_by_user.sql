WITH error_stats AS (
    SELECT 
        TO_DATE(START_TIME) AS date,
        USER_NAME, 
        COUNT(*) AS error_count
    FROM snowflake.account_usage.query_history
    WHERE error_code IS NOT NULL
    GROUP BY date, USER_NAME
),

total_queries AS (
    SELECT 
        TO_DATE(START_TIME) AS date,
        USER_NAME, 
        COUNT(*) AS total_queries
    FROM snowflake.account_usage.query_history
    GROUP BY date, USER_NAME
),

final_stats AS (
    SELECT 
        tq.date, 
        tq.USER_NAME, 
        tq.total_queries, 
        COALESCE(es.error_count, 0) AS error_count,
        (COALESCE(es.error_count, 0) / tq.total_queries) * 100 AS daily_error_percentage
    FROM total_queries tq
    LEFT JOIN error_stats es 
        ON tq.date = es.date 
        AND tq.USER_NAME = es.USER_NAME
)

SELECT * 
FROM final_stats
ORDER BY date, USER_NAME;
