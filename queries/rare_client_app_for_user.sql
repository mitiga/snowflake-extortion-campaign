WITH sessions_enriched AS (
SELECT *, 
        TO_DATE(CREATED_ON) AS unique_date,
        PARSE_JSON(client_environment) :APPLICATION :: STRING AS client_application,
FROM
    snowflake.account_usage.sessions
WHERE client_application is not null 
),

app_total_count AS (
  SELECT USER_NAME,client_application, COUNT(*) AS app_total_count
  FROM sessions_enriched
  GROUP BY USER_NAME,client_application
),

total_usage AS (
  SELECT USER_NAME, COUNT(*) AS total_usage
  FROM sessions_enriched
  GROUP BY USER_NAME
),

final_counts AS (
  SELECT c.USER_NAME, c.client_application ,c.app_total_count, t.total_usage,
         (c.app_total_count / t.total_usage) * 100 AS app_usage_pct
  FROM app_total_count c
  JOIN total_usage t ON c.USER_NAME = t.USER_NAME
),

anomaly AS (
  SELECT *
  FROM final_counts
  WHERE app_usage_pct < 5
),

anomaly_apps AS (
  SELECT q.USER_NAME, q.client_application,ARRAY_AGG(DISTINCT q.unique_date) AS anomalous_dates, AVG(a.app_usage_pct) AS avg_usage_pct
  FROM sessions_enriched q
  JOIN anomaly a ON q.USER_NAME = a.USER_NAME AND q.client_application = a.client_application 
  GROUP BY q.USER_NAME, q.client_application
)

SELECT *
FROM anomaly_apps
