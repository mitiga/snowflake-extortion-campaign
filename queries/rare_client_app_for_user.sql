%sql
WITH query_history_enhanced AS (
  SELECT *, TO_DATE(START_TIME) AS unique_date 
  FROM query_history
),

client_app_total_count AS (
  SELECT USER_NAME8, CLIENT_APPLICATION_ID, COUNT(*) AS client_app_total_count
  FROM query_history_enhanced
  GROUP BY USER_NAME8, CLIENT_APPLICATION_ID
),

total_queries AS (
  SELECT USER_NAME8, COUNT(*) AS total_queries
  FROM query_history_enhanced
  GROUP BY USER_NAME8
),

final_counts AS (
  SELECT c.USER_NAME8, c.CLIENT_APPLICATION_ID, c.client_app_total_count, t.total_queries,
         (c.client_app_total_count / t.total_queries) * 100 AS client_app_usage_pct
  FROM client_app_total_count c
  JOIN total_queries t ON c.USER_NAME8 = t.USER_NAME8
),

anomaly AS (
  SELECT *
  FROM final_counts
  WHERE client_app_usage_pct < 5
),

anomaly_apps AS (
  SELECT q.USER_NAME8, q.CLIENT_APPLICATION_ID, COLLECT_SET(q.unique_date) AS anomalous_dates, AVG(a.client_app_usage_pct) AS avg_usage_pct
  FROM query_history_enhanced q
  JOIN anomaly a ON q.USER_NAME8 = a.USER_NAME8 AND q.CLIENT_APPLICATION_ID = a.CLIENT_APPLICATION_ID
  GROUP BY q.USER_NAME8, q.CLIENT_APPLICATION_ID
)

SELECT *
FROM anomaly_apps