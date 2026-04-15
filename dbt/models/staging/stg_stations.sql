SELECT *
FROM {{ source('aqi_source', 'stations_ext') }}