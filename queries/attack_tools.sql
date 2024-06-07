SELECT
    *
FROM
    snowflake.account_usage.sessions
WHERE
    PARSE_JSON(CLIENT_ENVIRONMENT):APPLICATION = 'rapeflake'
    OR
    (
        PARSE_JSON(CLIENT_ENVIRONMENT):APPLICATION = 'DBeaver_DBeaverUltimate'
        AND
        PARSE_JSON(CLIENT_ENVIRONMENT):OS = 'Windows Server 2022'
    )
ORDER BY CREATED_ON;
