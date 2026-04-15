SELECT *
FROM {{ ref('int_aqi_long') }}
WHERE value IS NOT NULL