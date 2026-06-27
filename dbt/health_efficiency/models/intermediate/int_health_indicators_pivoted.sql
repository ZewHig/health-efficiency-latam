{{ config(materialized='view') }}

WITH base AS (
    SELECT *
    FROM {{ ref('stg_worldbank_health') }}
),

pivoted AS (
    SELECT
        country_code,
        country_name,
        year,
        MAX(CASE WHEN indicator_code = 'SH.XPD.CHEX.PC.CD' THEN value END) AS health_exp_pc_usd,
        MAX(CASE WHEN indicator_code = 'SH.XPD.CHEX.GD.ZS' THEN value END) AS health_exp_pct_gdp,
        MAX(CASE WHEN indicator_code = 'SH.MED.BEDS.ZS' THEN value END) AS hospital_beds_per_1000,
        MAX(CASE WHEN indicator_code = 'SH.MED.PHYS.ZS' THEN value END) AS physicians_per_1000,
        MAX(CASE WHEN indicator_code = 'SP.DYN.LE00.IN' THEN value END) AS life_expectancy_years,
        MAX(CASE WHEN indicator_code = 'SP.DYN.IMRT.IN' THEN value END) AS infant_mortality_per_1000,
        MAX(CASE WHEN indicator_code = 'SH.DYN.NCOM.ZS' THEN value END) AS premature_ncd_mortality_pct,
        MAX(CASE WHEN indicator_code = 'SP.POP.TOTL' THEN value END) AS population_total,
        MAX(loaded_at) AS last_loaded_at
    FROM base
    GROUP BY 1, 2, 3
)

SELECT *
FROM pivoted
