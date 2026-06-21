-- 1. Cobertura de dados por indicador
SELECT
    indicator_code,
    indicator_name,
    COUNT(*) AS total_rows,
    COUNT(value) AS rows_with_value,
    COUNT(*) - COUNT(value) AS rows_null,
    MIN(year) AS min_year,
    MAX(year) AS max_year
FROM raw.raw_worldbank_indicators
GROUP BY 1, 2
ORDER BY indicator_code;

-- 2. Países com maior gasto per capita no último ano disponível
WITH latest AS (
    SELECT MAX(year) AS latest_year
    FROM analytics.mart_country_health_efficiency
    WHERE health_exp_pc_usd IS NOT NULL
)
SELECT
    country_name,
    year,
    health_exp_pc_usd,
    life_expectancy_years,
    infant_mortality_per_1000,
    simple_efficiency_life_per_usd
FROM analytics.mart_country_health_efficiency
WHERE year = (SELECT latest_year FROM latest)
ORDER BY health_exp_pc_usd DESC;

-- 3. Comparação Brasil vs média dos demais países
WITH base AS (
    SELECT
        year,
        CASE WHEN country_code = 'BRA' THEN 'Brasil' ELSE 'Demais países' END AS group_name,
        AVG(health_exp_pc_usd) AS avg_health_exp_pc_usd,
        AVG(life_expectancy_years) AS avg_life_expectancy_years,
        AVG(infant_mortality_per_1000) AS avg_infant_mortality_per_1000
    FROM analytics.mart_country_health_efficiency
    GROUP BY 1, 2
)
SELECT *
FROM base
ORDER BY year, group_name;

-- 4. Relação gasto x expectativa de vida
SELECT
    country_name,
    year,
    health_exp_pc_usd,
    life_expectancy_years,
    infant_mortality_per_1000
FROM analytics.mart_country_health_efficiency
WHERE health_exp_pc_usd IS NOT NULL
  AND life_expectancy_years IS NOT NULL
ORDER BY year, country_name;

-- 5. Ranking exploratório de eficiência por ano
SELECT
    country_name,
    year,
    simple_efficiency_life_per_usd,
    exploratory_efficiency_score,
    health_exp_pc_usd,
    life_expectancy_years,
    infant_mortality_per_1000
FROM analytics.mart_country_health_efficiency
WHERE exploratory_efficiency_score IS NOT NULL
ORDER BY year DESC, exploratory_efficiency_score DESC;

-- 6. Qualidade dos dados para página do dashboard
SELECT
    country_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE health_exp_pc_usd IS NULL) AS years_without_health_exp_pc,
    COUNT(*) FILTER (WHERE life_expectancy_years IS NULL) AS years_without_life_expectancy,
    COUNT(*) FILTER (WHERE infant_mortality_per_1000 IS NULL) AS years_without_infant_mortality,
    MIN(year) AS first_year,
    MAX(year) AS last_year,
    MAX(last_loaded_at) AS last_loaded_at
FROM analytics.mart_country_health_efficiency
GROUP BY country_name
ORDER BY country_name;
