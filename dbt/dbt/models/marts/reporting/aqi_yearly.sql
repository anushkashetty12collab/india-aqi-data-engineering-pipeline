SELECT  
  EXTRACT(YEAR FROM datetime) AS year,
  city,
  parameter,  
  AVG(value) AS avg_value  
FROM {{ ref('aqi_enriched') }}  
GROUP BY year, city, parameter
ORDER BY year, city, parameter