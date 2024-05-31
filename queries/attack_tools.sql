SELECT *,
       LOWER(get_json_object(CLIENT_ENVIRONMENT, '$.APPLICATION')) AS APPLICATION,
       LOWER(get_json_object(CLIENT_ENVIRONMENT, '$.OS')) AS OS
FROM query_history
WHERE LOWER(get_json_object(CLIENT_ENVIRONMENT, '$.APPLICATION')) LIKE '%rapeflake%'
   OR (LOWER(get_json_object(CLIENT_ENVIRONMENT, '$.APPLICATION')) = 'dbeaver_dbeaverultimate'
       AND LOWER(get_json_object(CLIENT_ENVIRONMENT, '$.OS')) = 'windows server 2022')
