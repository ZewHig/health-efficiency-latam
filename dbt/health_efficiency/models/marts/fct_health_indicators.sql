{{ config(materialized='table') }}

SELECT
    country_code,
    indicator_code,
    year,
    value,
    loaded_at
FROM {{ ref('stg_worldbank_health') }}
