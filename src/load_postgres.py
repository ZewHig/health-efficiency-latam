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
