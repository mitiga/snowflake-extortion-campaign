WITH filtered AS (
    SELECT *,
        LOWER(QUERY_TEXT) AS query_text_lower,
        CASE 
            WHEN LOWER(QUERY_TEXT) RLIKE 'copy into\\s+(s3://[^\\s]+|gcs://[^\\s]+|azure://[^\\s]+|https?://[^\\s]+)' THEN TRUE
            ELSE FALSE
        END AS url_found
    FROM query_history
    WHERE LOWER(QUERY_TEXT) LIKE '%copy into%'
),
final AS (
    SELECT *,
        REGEXP_EXTRACT(query_text_lower, 'copy into\\s+(s3://[^\\s]+|gcs://[^\\s]+|azure://[^\\s]+|https?://[^\\s]+)', 1) AS extracted_url
    FROM filtered
    WHERE url_found = TRUE
)
SELECT * FROM final