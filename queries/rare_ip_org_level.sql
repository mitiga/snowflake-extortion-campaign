WITH ip_percentage AS (
    SELECT 
        CLIENT_IP, 
        (COUNT(*) / SUM(COUNT(*)) OVER () * 100) AS usage_percentage
    FROM snowflake.account_usage.login_history
    GROUP BY CLIENT_IP
)
SELECT
    lh.CLIENT_IP, 
    ARRAY_AGG(DISTINCT DATE(lh.EVENT_TIMESTAMP)) AS dates_used,
    ARRAY_AGG(DISTINCT lh.USER_NAME) AS users, 
    ip_percentage.usage_percentage
FROM ip_percentage
JOIN table(information_schema.login_history()) lh ON ip_percentage.CLIENT_IP = lh.CLIENT_IP
WHERE ip_percentage.usage_percentage < 5
GROUP BY lh.CLIENT_IP, ip_percentage.usage_percentage;
