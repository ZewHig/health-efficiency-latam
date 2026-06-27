{{ config(materialized='table') }}

WITH base AS (
    SELECT
        p.country_code,
        COALESCE(c.country_name, p.country_name) AS country_name,
        c.region,
        c.income_group,
        p.year,
        p.health_exp_pc_usd,
        p.health_exp_pct_gdp,
        p.hospital_beds_per_1000,
        p.physicians_per_1000,
        p.life_expectancy_years,
        p.infant_mortality_per_1000,
        p.premature_ncd_mortality_pct,
        p.population_total,
        p.population_total / 1000000.0 AS population_millions,

        CASE
            WHEN p.health_exp_pc_usd IS NOT NULL
             AND p.population_total IS NOT NULL
                THEN p.health_exp_pc_usd * p.population_total
        END AS estimated_total_health_exp_usd,

        CASE
            WHEN p.health_exp_pc_usd IS NOT NULL
             AND p.population_total IS NOT NULL
                THEN (p.health_exp_pc_usd * p.population_total) / 1000000000.0
        END AS estimated_total_health_exp_billion_usd,

        p.last_loaded_at
    FROM {{ ref('int_health_indicators_pivoted') }} p
    LEFT JOIN {{ ref('dim_country') }} c
        ON p.country_code = c.country_code
),

scored AS (
    SELECT
        base.*,

        CASE
            WHEN health_exp_pc_usd > 0 AND life_expectancy_years IS NOT NULL
                THEN life_expectancy_years / health_exp_pc_usd
        END AS simple_efficiency_life_per_usd,

        CASE
            WHEN MAX(life_expectancy_years) OVER (PARTITION BY year) = MIN(life_expectancy_years) OVER (PARTITION BY year)
                THEN NULL
            ELSE
                (life_expectancy_years - MIN(life_expectancy_years) OVER (PARTITION BY year))
                / NULLIF(MAX(life_expectancy_years) OVER (PARTITION BY year) - MIN(life_expectancy_years) OVER (PARTITION BY year), 0)
        END AS life_expectancy_score,

        CASE
            WHEN MAX(infant_mortality_per_1000) OVER (PARTITION BY year) = MIN(infant_mortality_per_1000) OVER (PARTITION BY year)
                THEN NULL
            ELSE
                (MAX(infant_mortality_per_1000) OVER (PARTITION BY year) - infant_mortality_per_1000)
                / NULLIF(MAX(infant_mortality_per_1000) OVER (PARTITION BY year) - MIN(infant_mortality_per_1000) OVER (PARTITION BY year), 0)
        END AS infant_mortality_score,

        CASE
            WHEN MAX(premature_ncd_mortality_pct) OVER (PARTITION BY year) = MIN(premature_ncd_mortality_pct) OVER (PARTITION BY year)
                THEN NULL
            ELSE
                (MAX(premature_ncd_mortality_pct) OVER (PARTITION BY year) - premature_ncd_mortality_pct)
                / NULLIF(MAX(premature_ncd_mortality_pct) OVER (PARTITION BY year) - MIN(premature_ncd_mortality_pct) OVER (PARTITION BY year), 0)
        END AS premature_ncd_mortality_score,

        CASE
            WHEN MAX(health_exp_pc_usd) OVER (PARTITION BY year) = MIN(health_exp_pc_usd) OVER (PARTITION BY year)
                THEN NULL
            ELSE
                (MAX(health_exp_pc_usd) OVER (PARTITION BY year) - health_exp_pc_usd)
                / NULLIF(MAX(health_exp_pc_usd) OVER (PARTITION BY year) - MIN(health_exp_pc_usd) OVER (PARTITION BY year), 0)
        END AS health_exp_cost_score
    FROM base
),

final AS (
    SELECT
        *,
        (
            COALESCE(life_expectancy_score, 0)
            + COALESCE(infant_mortality_score, 0)
            + COALESCE(premature_ncd_mortality_score, 0)
        )
        / NULLIF(
            (life_expectancy_score IS NOT NULL)::INTEGER
            + (infant_mortality_score IS NOT NULL)::INTEGER
            + (premature_ncd_mortality_score IS NOT NULL)::INTEGER,
            0
        ) AS health_result_score,

        (
            COALESCE(life_expectancy_score, 0)
            + COALESCE(infant_mortality_score, 0)
            + COALESCE(premature_ncd_mortality_score, 0)
            + COALESCE(health_exp_cost_score, 0)
        )
        / NULLIF(
            (life_expectancy_score IS NOT NULL)::INTEGER
            + (infant_mortality_score IS NOT NULL)::INTEGER
            + (premature_ncd_mortality_score IS NOT NULL)::INTEGER
            + (health_exp_cost_score IS NOT NULL)::INTEGER,
            0
        ) AS exploratory_efficiency_score
    FROM scored
)

SELECT *
FROM final
