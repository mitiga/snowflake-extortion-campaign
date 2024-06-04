SET username = ''; -- set user to investigate 
SET s_time = ''; -- set start time
SET e_time = CURRENT_TIMESTAMP;


--- This query creats a joined timeline of events from login_history and query_history, taken by a suspected user.


WITH query_history AS (
    SELECT
    'query' AS log_type,
        START_TIME,
        USER_NAME,
        QUERY_ID,
        QUERY_TEXT,
        DATABASE_NAME,
        QUERY_TYPE,
        EXECUTION_STATUS,
        ERROR_CODE,
        ERROR_MESSAGE,
        NULL AS EVENT_ID,
        NULL AS EVENT_TYPE,
        NULL AS CLIENT_IP,
        NULL AS FIRST_AUTHENTICATION_FACTOR,
        NULL AS SECOND_AUTHENTICATION_FACTOR,
        NULL AS IS_SUCCESS
    FROM
        snowflake.account_usage.query_history
    WHERE
        USER_NAME = $username
        AND start_time BETWEEN $s_time AND $e_time
),
login_history AS (
    SELECT
    'login' AS log_type,
        EVENT_TIMESTAMP AS start_time,
        USER_NAME,
        NULL AS QUERY_ID,
        NULL AS QUERY_TEXT,
        NULL AS DATABASE_NAME,
        NULL AS QUERY_TYPE,
        NULL AS EXECUTION_STATUS,
        ERROR_CODE,
        NULL AS ERROR_MESSAGE,
        EVENT_ID,
        EVENT_TYPE,
        CLIENT_IP,
        FIRST_AUTHENTICATION_FACTOR,
        SECOND_AUTHENTICATION_FACTOR,
        IS_SUCCESS
    FROM
        snowflake.account_usage.login_history
    WHERE
        USER_NAME = $username
        AND EVENT_TIMESTAMP BETWEEN $s_time AND $e_time
)

SELECT
    log_type,
    start_time,
    USER_NAME,
    QUERY_ID,
    QUERY_TEXT,
    DATABASE_NAME,
    QUERY_TYPE,
    EXECUTION_STATUS,
    ERROR_CODE,
    ERROR_MESSAGE,
    EVENT_ID,
    EVENT_TYPE,
    CLIENT_IP,
    FIRST_AUTHENTICATION_FACTOR,
    SECOND_AUTHENTICATION_FACTOR,
    IS_SUCCESS
FROM
    query_history
UNION ALL
SELECT
    log_type,
    start_time,
    USER_NAME,
    QUERY_ID,
    QUERY_TEXT,
    DATABASE_NAME,
    QUERY_TYPE,
    EXECUTION_STATUS,
    ERROR_CODE,
    ERROR_MESSAGE,
    EVENT_ID,
    EVENT_TYPE,
    CLIENT_IP,
    FIRST_AUTHENTICATION_FACTOR,
    SECOND_AUTHENTICATION_FACTOR,
    IS_SUCCESS
FROM
    login_history
ORDER BY
    start_time;
