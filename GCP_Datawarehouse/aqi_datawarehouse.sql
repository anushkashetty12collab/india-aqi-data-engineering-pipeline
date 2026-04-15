-- =========================================================
-- AQI DATA PIPELINE — BIGQUERY WAREHOUSE LAYER
-- =========================================================


-- =========================================================
-- 📂 STEP 1: EXTERNAL TABLE (RAW AQI DATA)
-- =========================================================
CREATE OR REPLACE EXTERNAL TABLE `aqi-data-pipeline.aqi_dataset.aqi_ext`
OPTIONS (
  format = 'CSV',
  uris = ['gs://aqi-data-lake-bucket/aqi_data/*.csv'],
  skip_leading_rows = 1,
  allow_quoted_newlines = TRUE,
  allow_jagged_rows = TRUE,
  ignore_unknown_values = TRUE
);


-- =========================================================
-- 🏗️ STEP 2: FACT TABLE
-- =========================================================
CREATE OR REPLACE TABLE `aqi-data-pipeline.aqi_dataset.aqi_fact`
PARTITION BY TIMESTAMP_TRUNC(datetime, MONTH)
CLUSTER BY parameter
AS

-- PM2.5
SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv') AS station_code,
  TIMESTAMP(From_Date) AS datetime,
  'PM2.5' AS parameter,
  SAFE_CAST(PM2_5__ug_m3_ AS FLOAT64) AS value,
  'ug/m3' AS unit
FROM `aqi-data-pipeline.aqi_dataset.aqi_ext`

UNION ALL

-- PM10
SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv'),
  TIMESTAMP(From_Date),
  'PM10',
  SAFE_CAST(PM10__ug_m3_ AS FLOAT64),
  'ug/m3'
FROM `aqi-data-pipeline.aqi_dataset.aqi_ext`

UNION ALL

-- NO2
SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv'),
  TIMESTAMP(From_Date),
  'NO2',
  SAFE_CAST(NO2__ug_m3_ AS FLOAT64),
  'ug/m3'
FROM `aqi-data-pipeline.aqi_dataset.aqi_ext`

UNION ALL

-- SO2
SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv'),
  TIMESTAMP(From_Date),
  'SO2',
  SAFE_CAST(SO2__ug_m3_ AS FLOAT64),
  'ug/m3'
FROM `aqi-data-pipeline.aqi_dataset.aqi_ext`

UNION ALL

-- CO
SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv'),
  TIMESTAMP(From_Date),
  'CO',
  SAFE_CAST(CO__mg_m3_ AS FLOAT64),
  'mg/m3'
FROM `aqi-data-pipeline.aqi_dataset.aqi_ext`

UNION ALL

-- Ozone
SELECT
  REGEXP_EXTRACT(_FILE_NAME, r'-([A-Z0-9]+)\.csv'),
  TIMESTAMP(From_Date),
  'Ozone',
  SAFE_CAST(Ozone__ug_m3_ AS FLOAT64),
  'ug/m3'
FROM `aqi-data-pipeline.aqi_dataset.aqi_ext`;


-- =========================================================
-- 📍 STATIONS METADATA
-- =========================================================
CREATE OR REPLACE EXTERNAL TABLE `aqi-data-pipeline.aqi_dataset.stations_ext`
OPTIONS (
  format = 'CSV',
  uris = ['gs://aqi-data-lake-bucket/metadata/*.csv'],
  skip_leading_rows = 1
);

CREATE OR REPLACE TABLE `aqi-data-pipeline.aqi_dataset.stations_info`
AS
SELECT *
FROM `aqi-data-pipeline.aqi_dataset.stations_ext`;


-- =========================================================
-- 🔗 ENRICHED TABLE
-- =========================================================
CREATE OR REPLACE TABLE `aqi-data-pipeline.aqi_dataset.aqi_enriched`
AS
SELECT
  f.*,
  s.city,
  s.state,
  s.agency
FROM `aqi-data-pipeline.aqi_dataset.aqi_fact` f
LEFT JOIN `aqi-data-pipeline.aqi_dataset.stations_info` s
ON f.station_code = s.file_name;
