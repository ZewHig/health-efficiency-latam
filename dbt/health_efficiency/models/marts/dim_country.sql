{{ config(materialized='table') }}

SELECT
    country_code,
    country_name,
    iso2_code,
    region,
    income_group,
    lending_type,
    capital_city,
    longitude,
    latitude
FROM {{ ref('stg_worldbank_countries') }}
