from __future__ import annotations

import argparse
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd
import requests

from config import COUNTRIES, DEFAULT_END_YEAR, DEFAULT_START_YEAR, INDICATORS, WORLD_BANK_API_BASE_URL
from utils import ensure_directory, get_project_root


class WorldBankAPIError(RuntimeError):
    """Raised when the World Bank API returns an unexpected response."""


def _get_json(session: requests.Session, url: str, params: dict[str, Any]) -> list[Any]:
    response = session.get(url, params=params, timeout=30)
    response.raise_for_status()
    payload = response.json()

    if not isinstance(payload, list) or len(payload) < 2:
        raise WorldBankAPIError(f"Unexpected response format from World Bank API: {payload}")

    return payload


def fetch_indicator(
    session: requests.Session,
    indicator_code: str,
    countries: list[str],
    start_year: int,
    end_year: int,
    per_page: int = 2000,
) -> pd.DataFrame:
    """Fetch one World Bank indicator for multiple countries and return normalized rows."""
    country_param = ";".join(countries)
    url = f"{WORLD_BANK_API_BASE_URL}/country/{country_param}/indicator/{indicator_code}"

    rows: list[dict[str, Any]] = []
    page = 1
    loaded_at = datetime.now(timezone.utc).isoformat()

    while True:
        payload = _get_json(
            session=session,
            url=url,
            params={
                "format": "json",
                "per_page": per_page,
                "page": page,
                "date": f"{start_year}:{end_year}",
            },
        )

        metadata = payload[0] or {}
        records = payload[1] or []

        for record in records:
            country = record.get("country") or {}
            indicator = record.get("indicator") or {}

            rows.append(
                {
                    "country_code": record.get("countryiso3code"),
                    "country_name": country.get("value"),
                    "indicator_code": indicator_code,
                    "indicator_name": indicator.get("value"),
                    "year": int(record["date"]) if record.get("date") else None,
                    "value": record.get("value"),
                    "loaded_at": loaded_at,
                }
            )

        total_pages = int(metadata.get("pages", 1))
        if page >= total_pages:
            break
        page += 1

    return pd.DataFrame(rows)


def fetch_countries_metadata(session: requests.Session, countries: list[str], per_page: int = 300) -> pd.DataFrame:
    """Fetch country metadata such as region and income group from World Bank."""
    country_param = ";".join(countries)
    url = f"{WORLD_BANK_API_BASE_URL}/country/{country_param}"
    payload = _get_json(session, url, {"format": "json", "per_page": per_page})
    records = payload[1] or []
    loaded_at = datetime.now(timezone.utc).isoformat()

    rows = []
    for record in records:
        rows.append(
            {
                "country_code": record.get("id"),
                "country_name": record.get("name"),
                "iso2_code": record.get("iso2Code"),
                "region": (record.get("region") or {}).get("value"),
                "income_group": (record.get("incomeLevel") or {}).get("value"),
                "lending_type": (record.get("lendingType") or {}).get("value"),
                "capital_city": record.get("capitalCity"),
                "longitude": record.get("longitude"),
                "latitude": record.get("latitude"),
                "loaded_at": loaded_at,
            }
        )

    return pd.DataFrame(rows)


def extract_all_indicators(start_year: int, end_year: int) -> pd.DataFrame:
    countries = list(COUNTRIES.keys())
    frames = []

    with requests.Session() as session:
        for indicator in INDICATORS:
            print(f"Extracting {indicator.code} - {indicator.name}")
            df_indicator = fetch_indicator(
                session=session,
                indicator_code=indicator.code,
                countries=countries,
                start_year=start_year,
                end_year=end_year,
            )
            frames.append(df_indicator)

    if not frames:
        return pd.DataFrame()

    df = pd.concat(frames, ignore_index=True)
    df = df.sort_values(["country_code", "indicator_code", "year"]).reset_index(drop=True)
    return df


def main() -> None:
    parser = argparse.ArgumentParser(description="Extract World Bank health indicators for LATAM countries.")
    parser.add_argument("--start-year", type=int, default=DEFAULT_START_YEAR)
    parser.add_argument("--end-year", type=int, default=DEFAULT_END_YEAR)
    parser.add_argument("--output-dir", type=Path, default=get_project_root() / "data" / "raw")
    args = parser.parse_args()

    ensure_directory(args.output_dir)

    indicators_df = extract_all_indicators(args.start_year, args.end_year)
    indicators_path = args.output_dir / "worldbank_health_indicators.csv"
    indicators_df.to_csv(indicators_path, index=False)

    with requests.Session() as session:
        countries_df = fetch_countries_metadata(session, list(COUNTRIES.keys()))
    countries_path = args.output_dir / "worldbank_countries.csv"
    countries_df.to_csv(countries_path, index=False)

    print(f"Saved {len(indicators_df):,} indicator rows to {indicators_path}")
    print(f"Saved {len(countries_df):,} country rows to {countries_path}")


if __name__ == "__main__":
    main()
