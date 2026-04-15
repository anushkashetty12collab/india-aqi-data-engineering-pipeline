SELECT
  city,
  EXTRACT(YEAR FROM datetime) AS year,
  parameter,
  ROUND(AVG(value), 2) AS avg_value
FROM {{ ref('aqi_enriched') }}
WHERE city IN (
  'Mumbai'
--   'Delhi',
--   'Chennai',
--   'Kolkata'
)
GROUP BY city, year, parameter
ORDER BY city, year, parameter