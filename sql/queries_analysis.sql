/*
Exploratory Analysis - Health Efficiency LATAM

This file contains exploratory SQL queries to understand:
- data volume
- indicator coverage
- null values
- country comparisons
- Brazil vs selected LATAM countries
- possible Power BI dashboard insights
*/

-- ============================================================
-- 01. General overview of the final analytical mart
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT country_code) AS total_countries,
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    COUNT(*) FILTER (WHERE health_exp_pc_usd IS NOT NULL) AS rows_with_health_exp_pc,
    COUNT(*) FILTER (WHERE life_expectancy_years IS NOT NULL) AS rows_with_life_expectancy,
    COUNT(*) FILTER (WHERE infant_mortality_per_1000 IS NOT NULL) AS rows_with_infant_mortality,
    COUNT(*) FILTER (WHERE population_total IS NOT NULL) AS rows_with_population
FROM analytics.mart_country_health_efficiency;


-- ============================================================
-- 02. Raw data coverage by indicator
-- Shows which indicators are strong and which have more nulls
-- ============================================================

SELECT
    indicator_code,
    indicator_name,
    COUNT(*) AS total_rows,
    COUNT(value) AS rows_with_value,
    COUNT(*) - COUNT(value) AS null_rows,
    ROUND((COUNT(value)::NUMERIC / COUNT(*)::NUMERIC) * 100, 2) AS coverage_pct,
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM raw.raw_worldbank_indicators
GROUP BY
    indicator_code,
    indicator_name
ORDER BY
    coverage_pct DESC,
    indicator_code;


-- ============================================================
-- 03. Data coverage by country in the final mart
-- ============================================================

SELECT
    country_code,
    country_name,
    COUNT(*) AS total_rows,
    COUNT(health_exp_pc_usd) AS health_exp_pc_rows,
    COUNT(life_expectancy_years) AS life_expectancy_rows,
    COUNT(infant_mortality_per_1000) AS infant_mortality_rows,
    COUNT(population_total) AS population_rows,
    ROUND((COUNT(health_exp_pc_usd)::NUMERIC / COUNT(*)::NUMERIC) * 100, 2) AS health_exp_pc_coverage_pct
FROM analytics.mart_country_health_efficiency
GROUP BY
    country_code,
    country_name
ORDER BY
    health_exp_pc_coverage_pct DESC,
    country_name;


-- ============================================================
-- 04. Latest available values by country
-- Main comparison year: 2023
-- 2024 can be incomplete for some indicators
-- ============================================================

SELECT
    country_name,
    year,
    ROUND(health_exp_pc_usd::NUMERIC, 2) AS health_exp_pc_usd,
    ROUND(health_exp_pct_gdp::NUMERIC, 2) AS health_exp_pct_gdp,
    ROUND(life_expectancy_years::NUMERIC, 2) AS life_expectancy_years,
    ROUND(infant_mortality_per_1000::NUMERIC, 2) AS infant_mortality_per_1000,
    ROUND(population_millions::NUMERIC, 2) AS population_millions,
    ROUND(estimated_total_health_exp_billion_usd::NUMERIC, 2) AS estimated_total_health_exp_billion_usd
FROM analytics.mart_country_health_efficiency
WHERE year = 2023
ORDER BY
    health_exp_pc_usd DESC NULLS LAST;


-- ============================================================
-- 05. Ranking: highest health expenditure per capita in 2023
-- ============================================================

SELECT
    country_name,
    year,
    ROUND(health_exp_pc_usd::NUMERIC, 2) AS health_exp_pc_usd,
    ROUND(health_exp_pct_gdp::NUMERIC, 2) AS health_exp_pct_gdp,
    ROUND(population_millions::NUMERIC, 2) AS population_millions
FROM analytics.mart_country_health_efficiency
WHERE year = 2023
ORDER BY
    health_exp_pc_usd DESC NULLS LAST;


-- ============================================================
-- 06. Ranking: highest life expectancy in 2023
-- ============================================================

SELECT
    country_name,
    year,
    ROUND(life_expectancy_years::NUMERIC, 2) AS life_expectancy_years,
    ROUND(health_exp_pc_usd::NUMERIC, 2) AS health_exp_pc_usd,
    ROUND(infant_mortality_per_1000::NUMERIC, 2) AS infant_mortality_per_1000
FROM analytics.mart_country_health_efficiency
WHERE year = 2023
ORDER BY
    life_expectancy_years DESC NULLS LAST;


-- ============================================================
-- 07. Ranking: lowest infant mortality in 2023
-- Lower is better
-- ============================================================

SELECT
    country_name,
    year,
    ROUND(infant_mortality_per_1000::NUMERIC, 2) AS infant_mortality_per_1000,
    ROUND(life_expectancy_years::NUMERIC, 2) AS life_expectancy_years,
    ROUND(health_exp_pc_usd::NUMERIC, 2) AS health_exp_pc_usd
FROM analytics.mart_country_health_efficiency
WHERE year = 2023
ORDER BY
    infant_mortality_per_1000 ASC NULLS LAST;


-- ============================================================
-- 08. Brazil vs selected countries over time
-- Useful for line charts in Power BI
-- ============================================================

SELECT
    country_name,
    year,
    ROUND(health_exp_pc_usd::NUMERIC, 2) AS health_exp_pc_usd,
    ROUND(life_expectancy_years::NUMERIC, 2) AS life_expectancy_years,
    ROUND(infant_mortality_per_1000::NUMERIC, 2) AS infant_mortality_per_1000,
    ROUND(population_millions::NUMERIC, 2) AS population_millions
FROM analytics.mart_country_health_efficiency
WHERE year BETWEEN 2000 AND 2023
ORDER BY
    country_name,
    year;


-- ============================================================
-- 09. Brazil vs average of other selected countries
-- This is useful for a dashboard page focused on Brazil
-- ============================================================

WITH yearly_comparison AS (
    SELECT
        year,

        AVG(health_exp_pc_usd) FILTER (WHERE country_code = 'BRA') AS brazil_health_exp_pc_usd,
        AVG(health_exp_pc_usd) FILTER (WHERE country_code <> 'BRA') AS others_avg_health_exp_pc_usd,

        AVG(life_expectancy_years) FILTER (WHERE country_code = 'BRA') AS brazil_life_expectancy_years,
        AVG(life_expectancy_years) FILTER (WHERE country_code <> 'BRA') AS others_avg_life_expectancy_years,

        AVG(infant_mortality_per_1000) FILTER (WHERE country_code = 'BRA') AS brazil_infant_mortality_per_1000,
        AVG(infant_mortality_per_1000) FILTER (WHERE country_code <> 'BRA') AS others_avg_infant_mortality_per_1000
    FROM analytics.mart_country_health_efficiency
    WHERE year BETWEEN 2000 AND 2023
    GROUP BY year
)

SELECT
    year,
    ROUND(brazil_health_exp_pc_usd::NUMERIC, 2) AS brazil_health_exp_pc_usd,
    ROUND(others_avg_health_exp_pc_usd::NUMERIC, 2) AS others_avg_health_exp_pc_usd,
    ROUND((brazil_health_exp_pc_usd - others_avg_health_exp_pc_usd)::NUMERIC, 2) AS diff_health_exp_pc_usd,

    ROUND(brazil_life_expectancy_years::NUMERIC, 2) AS brazil_life_expectancy_years,
    ROUND(others_avg_life_expectancy_years::NUMERIC, 2) AS others_avg_life_expectancy_years,
    ROUND((brazil_life_expectancy_years - others_avg_life_expectancy_years)::NUMERIC, 2) AS diff_life_expectancy_years,

    ROUND(brazil_infant_mortality_per_1000::NUMERIC, 2) AS brazil_infant_mortality_per_1000,
    ROUND(others_avg_infant_mortality_per_1000::NUMERIC, 2) AS others_avg_infant_mortality_per_1000,
    ROUND((brazil_infant_mortality_per_1000 - others_avg_infant_mortality_per_1000)::NUMERIC, 2) AS diff_infant_mortality_per_1000
FROM yearly_comparison
ORDER BY year;


-- ============================================================
-- 10. Evolution from 2000 to 2023
-- Shows which countries improved the most
-- ============================================================

WITH base_years AS (
    SELECT
        country_code,
        country_name,

        MAX(CASE WHEN year = 2000 THEN health_exp_pc_usd END) AS health_exp_pc_2000,
        MAX(CASE WHEN year = 2023 THEN health_exp_pc_usd END) AS health_exp_pc_2023,

        MAX(CASE WHEN year = 2000 THEN life_expectancy_years END) AS life_expectancy_2000,
        MAX(CASE WHEN year = 2023 THEN life_expectancy_years END) AS life_expectancy_2023,

        MAX(CASE WHEN year = 2000 THEN infant_mortality_per_1000 END) AS infant_mortality_2000,
        MAX(CASE WHEN year = 2023 THEN infant_mortality_per_1000 END) AS infant_mortality_2023
    FROM analytics.mart_country_health_efficiency
    GROUP BY
        country_code,
        country_name
)

SELECT
    country_name,

    ROUND(health_exp_pc_2000::NUMERIC, 2) AS health_exp_pc_2000,
    ROUND(health_exp_pc_2023::NUMERIC, 2) AS health_exp_pc_2023,
    ROUND((health_exp_pc_2023 - health_exp_pc_2000)::NUMERIC, 2) AS health_exp_pc_change,

    ROUND(life_expectancy_2000::NUMERIC, 2) AS life_expectancy_2000,
    ROUND(life_expectancy_2023::NUMERIC, 2) AS life_expectancy_2023,
    ROUND((life_expectancy_2023 - life_expectancy_2000)::NUMERIC, 2) AS life_expectancy_change,

    ROUND(infant_mortality_2000::NUMERIC, 2) AS infant_mortality_2000,
    ROUND(infant_mortality_2023::NUMERIC, 2) AS infant_mortality_2023,
    ROUND((infant_mortality_2023 - infant_mortality_2000)::NUMERIC, 2) AS infant_mortality_change
FROM base_years
ORDER BY
    life_expectancy_change DESC NULLS LAST;


-- ============================================================
-- 11. Exploratory efficiency ranking in 2023
-- This is not a definitive health system ranking.
-- It is an analytical index created for this project.
-- ============================================================

SELECT
    country_name,
    year,
    ROUND(exploratory_efficiency_score::NUMERIC, 4) AS exploratory_efficiency_score,
    ROUND(health_result_score::NUMERIC, 4) AS health_result_score,
    ROUND(health_exp_cost_score::NUMERIC, 4) AS health_exp_cost_score,
    ROUND(health_exp_pc_usd::NUMERIC, 2) AS health_exp_pc_usd,
    ROUND(life_expectancy_years::NUMERIC, 2) AS life_expectancy_years,
    ROUND(infant_mortality_per_1000::NUMERIC, 2) AS infant_mortality_per_1000
FROM analytics.mart_country_health_efficiency
WHERE year = 2023
ORDER BY
    exploratory_efficiency_score DESC NULLS LAST;


-- ============================================================
-- 12. Scatter plot base: expenditure vs life expectancy
-- Suggested Power BI visual:
-- X axis: health_exp_pc_usd
-- Y axis: life_expectancy_years
-- Bubble size: population_total
-- Legend: country_name
-- Filter: year
-- ============================================================

SELECT
    country_name,
    year,
    health_exp_pc_usd,
    life_expectancy_years,
    infant_mortality_per_1000,
    population_total,
    population_millions,
    estimated_total_health_exp_billion_usd
FROM analytics.mart_country_health_efficiency
WHERE
    year BETWEEN 2000 AND 2023
    AND health_exp_pc_usd IS NOT NULL
    AND life_expectancy_years IS NOT NULL
    AND population_total IS NOT NULL
ORDER BY
    year,
    country_name;


-- ============================================================
-- 13. Infrastructure indicators coverage
-- These indicators have more nulls and should be used carefully
-- ============================================================

SELECT
    country_name,
    COUNT(*) AS total_years,
    COUNT(hospital_beds_per_1000) AS years_with_hospital_beds,
    COUNT(physicians_per_1000) AS years_with_physicians,
    ROUND((COUNT(hospital_beds_per_1000)::NUMERIC / COUNT(*)::NUMERIC) * 100, 2) AS hospital_beds_coverage_pct,
    ROUND((COUNT(physicians_per_1000)::NUMERIC / COUNT(*)::NUMERIC) * 100, 2) AS physicians_coverage_pct
FROM analytics.mart_country_health_efficiency
GROUP BY country_name
ORDER BY
    physicians_coverage_pct DESC,
    hospital_beds_coverage_pct DESC;


-- ============================================================
-- 14. Latest available year by metric and country
-- Helps explain why some dashboard values may be blank
-- ============================================================

SELECT
    country_name,
    MAX(year) FILTER (WHERE health_exp_pc_usd IS NOT NULL) AS latest_health_exp_pc_year,
    MAX(year) FILTER (WHERE health_exp_pct_gdp IS NOT NULL) AS latest_health_exp_pct_gdp_year,
    MAX(year) FILTER (WHERE life_expectancy_years IS NOT NULL) AS latest_life_expectancy_year,
    MAX(year) FILTER (WHERE infant_mortality_per_1000 IS NOT NULL) AS latest_infant_mortality_year,
    MAX(year) FILTER (WHERE premature_ncd_mortality_pct IS NOT NULL) AS latest_ncd_mortality_year,
    MAX(year) FILTER (WHERE hospital_beds_per_1000 IS NOT NULL) AS latest_hospital_beds_year,
    MAX(year) FILTER (WHERE physicians_per_1000 IS NOT NULL) AS latest_physicians_year,
    MAX(year) FILTER (WHERE population_total IS NOT NULL) AS latest_population_year
FROM analytics.mart_country_health_efficiency
GROUP BY country_name
ORDER BY country_name;