SELECT
  city,
  parameter,
  value,
  CASE
    WHEN value <= 50 THEN 'Good'
    WHEN value <= 100 THEN 'Moderate'
    WHEN value <= 200 THEN 'Poor'
    ELSE 'Very Poor'
  END AS aqi_category
FROM {{ ref('aqi_enriched') }}