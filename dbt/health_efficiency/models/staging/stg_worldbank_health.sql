{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('raw', 'raw_worldbank_indicators') }}
),

renamed AS (
    SELECT
        UPPER(TRIM(country_code))::TEXT AS country_code,
        TRIM(country_name)::TEXT AS country_name,
        TRIM(indicator_code)::TEXT AS indicator_code,
        TRIM(indicator_name)::TEXT AS indicator_name,
        year::INTEGER AS year,
        value::NUMERIC AS value,
        loaded_at::TIMESTAMPTZ AS loaded_at
    FROM source
    WHERE country_code IS NOT NULL
      AND indicator_code IS NOT NULL
      AND year IS NOT NULL
)

SELECT *
FROM renamed
