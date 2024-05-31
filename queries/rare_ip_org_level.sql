SELECT 
    lh.CLIENT_IP, 
    COLLECT_SET(lh.date) AS dates_used, 
    COLLECT_SET(lh.USER_NAME) AS users, 
    ip_percentage.usage_percentage
FROM (
    SELECT CLIENT_IP, (COUNT(*) / SUM(COUNT(*)) OVER () * 100) AS usage_percentage
    FROM login_history
    GROUP BY CLIENT_IP
) ip_percentage
JOIN login_history lh ON ip_percentage.CLIENT_IP = lh.CLIENT_IP
WHERE ip_percentage.usage_percentage < 5
GROUP BY lh.CLIENT_IP, ip_percentage.usage_percentage