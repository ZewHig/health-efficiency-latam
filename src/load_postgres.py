from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

from config import DATABASE_URL
from utils import get_project_root


def run_sql_file(engine, sql_file: Path) -> None:
    sql = sql_file.read_text(encoding="utf-8")
    with engine.begin() as connection:
        connection.execute(text(sql))


def prepare_dataframe_for_postgres(df: pd.DataFrame) -> pd.DataFrame:
    """
    Ajusta tipos lidos do CSV antes de carregar no PostgreSQL.
    CSV não guarda tipos reais, então datas e números precisam ser convertidos.
    """

    if "year" in df.columns:
        df["year"] = pd.to_numeric(df["year"], errors="coerce").astype("Int64")

    if "value" in df.columns:
        df["value"] = pd.to_numeric(df["value"], errors="coerce")

    if "longitude" in df.columns:
        df["longitude"] = pd.to_numeric(df["longitude"], errors="coerce")

    if "latitude" in df.columns:
        df["latitude"] = pd.to_numeric(df["latitude"], errors="coerce")

    if "loaded_at" in df.columns:
        df["loaded_at"] = pd.to_datetime(df["loaded_at"], errors="coerce", utc=True)

    return df


def load_csv_to_table(
    engine,
    csv_path: Path,
    table_name: str,
    schema: str = "raw",
    replace: bool = False,
) -> None:
    if not csv_path.exists():
        raise FileNotFoundError(f"File not found: {csv_path}")

    df = pd.read_csv(csv_path)
    df = prepare_dataframe_for_postgres(df)

    with engine.begin() as connection:
        connection.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema}"))
        if replace:
            connection.execute(text(f"TRUNCATE TABLE {schema}.{table_name}"))

    df.to_sql(
        name=table_name,
        con=engine,
        schema=schema,
        if_exists="append",
        index=False,
        method="multi",
        chunksize=1000,
    )

    print(f"Loaded {len(df):,} rows into {schema}.{table_name}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Load extracted World Bank CSV files into PostgreSQL.")
    parser.add_argument("--database-url", default=DATABASE_URL)
    parser.add_argument("--raw-dir", type=Path, default=get_project_root() / "data" / "raw")
    parser.add_argument("--create-tables", action="store_true")
    parser.add_argument("--replace", action="store_true", help="Truncate raw tables before loading.")
    args = parser.parse_args()

    engine = create_engine(args.database_url)

    if args.create_tables:
        run_sql_file(engine, get_project_root() / "sql" / "create_tables.sql")
        print("Database schemas and raw tables created.")

    load_csv_to_table(
        engine=engine,
        csv_path=args.raw_dir / "worldbank_health_indicators.csv",
        schema="raw",
        table_name="raw_worldbank_indicators",
        replace=args.replace,
    )

    load_csv_to_table(
        engine=engine,
        csv_path=args.raw_dir / "worldbank_countries.csv",
        schema="raw",
        table_name="raw_worldbank_countries",
        replace=args.replace,
    )


if __name__ == "__main__":
    main()