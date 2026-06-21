CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS raw.raw_worldbank_indicators (
    country_code VARCHAR(3),
    country_name TEXT,
    indicator_code TEXT,
    indicator_name TEXT,
    year INTEGER,
    value NUMERIC,
    loaded_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS raw.raw_worldbank_countries (
    country_code VARCHAR(3),
    country_name TEXT,
    iso2_code VARCHAR(2),
    region TEXT,
    income_group TEXT,
    lending_type TEXT,
    capital_city TEXT,
    longitude NUMERIC,
    latitude NUMERIC,
    loaded_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_raw_worldbank_indicators_country_year
    ON raw.raw_worldbank_indicators (country_code, year);

CREATE INDEX IF NOT EXISTS idx_raw_worldbank_indicators_indicator
    ON raw.raw_worldbank_indicators (indicator_code);

CREATE INDEX IF NOT EXISTS idx_raw_worldbank_countries_country
    ON raw.raw_worldbank_countries (country_code);
