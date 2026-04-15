SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv') AS station_code,
  TIMESTAMP(From_Date) AS datetime,
  SAFE_CAST(PM2_5__ug_m3_ AS FLOAT64) AS pm25,
  SAFE_CAST(PM10__ug_m3_ AS FLOAT64) AS pm10,
  SAFE_CAST(NO2__ug_m3_ AS FLOAT64) AS no2,
  SAFE_CAST(SO2__ug_m3_ AS FLOAT64) AS so2,
  SAFE_CAST(CO__mg_m3_ AS FLOAT64) AS co,
  SAFE_CAST(Ozone__ug_m3_ AS FLOAT64) AS ozone
FROM {{ source('aqi_source', 'aqi_ext') }}