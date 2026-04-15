SELECT
  city,
  parameter,
  AVG(value) AS avg_value
FROM {{ ref('aqi_enriched') }}
GROUP BY city, parameter