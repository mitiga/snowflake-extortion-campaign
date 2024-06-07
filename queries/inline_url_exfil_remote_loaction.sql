WITH copy_into AS (
  SELECT
    *,
    LOWER(QUERY_TEXT) AS query_text_lower,
  FROM
    snowflake.account_usage.query_history
  WHERE
    LOWER(QUERY_TEXT) LIKE '%copy into%'
    and QUERY_TYPE = 'UNLOAD'
),
final AS (
  SELECT
    *,
    REGEXP_SUBSTR (
      query_text_lower,
      '(s3://[^\\s]+|gcs://[^\\s]+|azure://[^\\s]+)', 1) AS extracted_url
  FROM
    copy_into
  WHERE
    extracted_url IS NOT NULL
)
SELECT
  *
FROM
  final;
