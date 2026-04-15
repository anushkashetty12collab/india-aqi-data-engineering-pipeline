SELECT
  f.*,
  s.city,
  s.state,
  s.agency
FROM {{ ref('fact_aqi') }} f
LEFT JOIN {{ ref('dim_stations') }} s
ON f.station_code = s.file_name