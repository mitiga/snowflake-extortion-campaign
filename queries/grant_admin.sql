SELECT *
FROM snowflake.account_usage.query_history
WHERE QUERY_TYPE = 'GRANT'
AND (
    QUERY_TEXT ILIKE '%grant%role%accountadmin%to%'
    OR QUERY_TEXT ILIKE '%grant%role%securityadmin%to%'
    OR QUERY_TEXT ILIKE '%grant%role%sysadmin%to%')
