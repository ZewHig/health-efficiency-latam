{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('raw', 'raw_worldbank_countries') }}
),

renamed AS (
    SELECT
        UPPER(TRIM(country_code))::TEXT AS country_code,
        TRIM(country_name)::TEXT AS country_name,
        UPPER(TRIM(iso2_code))::TEXT AS iso2_code,
        TRIM(region)::TEXT AS region,
        TRIM(income_group)::TEXT AS income_group,
        TRIM(lending_type)::TEXT AS lending_type,
        TRIM(capital_city)::TEXT AS capital_city,
        longitude::NUMERIC AS longitude,
        latitude::NUMERIC AS latitude,
        loaded_at::TIMESTAMPTZ AS loaded_at
    FROM source
    WHERE country_code IS NOT NULL
)

SELECT *
FROM renamed
