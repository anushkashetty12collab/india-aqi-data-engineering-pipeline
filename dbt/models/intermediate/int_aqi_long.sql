SELECT station_code, datetime, 'PM2.5' AS parameter, pm25 AS value FROM {{ ref('stg_aqi') }}
UNION ALL
SELECT station_code, datetime, 'PM10', pm10 FROM {{ ref('stg_aqi') }}
UNION ALL
SELECT station_code, datetime, 'NO2', no2 FROM {{ ref('stg_aqi') }}
UNION ALL
SELECT station_code, datetime, 'SO2', so2 FROM {{ ref('stg_aqi') }}
UNION ALL
SELECT station_code, datetime, 'CO', co FROM {{ ref('stg_aqi') }}
UNION ALL
SELECT station_code, datetime, 'Ozone', ozone FROM {{ ref('stg_aqi') }}