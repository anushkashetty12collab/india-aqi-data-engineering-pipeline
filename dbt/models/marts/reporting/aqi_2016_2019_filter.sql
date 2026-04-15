SELECT
  city,
  EXTRACT(YEAR FROM datetime) AS year,
  parameter,
  ROUND(AVG(value), 2) AS avg_value,
  CASE
    WHEN AVG(value) <= 50 THEN 'Good'
    WHEN AVG(value) <= 100 THEN 'Moderate'
    WHEN AVG(value) <= 200 THEN 'Poor'
    ELSE 'Very Poor'
  END AS aqi_category
FROM {{ ref('aqi_enriched') }}
WHERE 
  EXTRACT(YEAR FROM datetime) BETWEEN 2010 AND 2023
  AND city IN (
    'Delhi','Mumbai','Bengaluru','Chennai',
    'Kolkata','Hyderabad','Pune','Ahmedabad'
  )
GROUP BY city, year, parameter
ORDER BY city, year, parameter
