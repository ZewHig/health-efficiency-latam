from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Literal

from dotenv import load_dotenv

load_dotenv()

WORLD_BANK_API_BASE_URL = "https://api.worldbank.org/v2"

COUNTRIES: dict[str, str] = {
    "BRA": "Brasil",
    "ARG": "Argentina",
    "CHL": "Chile",
    "COL": "Colômbia",
    "MEX": "México",
    "PER": "Peru",
    "URY": "Uruguai",
}

Polarity = Literal["higher_is_better", "lower_is_better", "context", "cost"]


@dataclass(frozen=True)
class Indicator:
    code: str
    name: str
    category: str
    unit: str
    polarity: Polarity


INDICATORS: list[Indicator] = [
    Indicator(
        code="SH.XPD.CHEX.PC.CD",
        name="Current health expenditure per capita",
        category="spending",
        unit="current US$",
        polarity="cost",
    ),
    Indicator(
        code="SH.XPD.CHEX.GD.ZS",
        name="Current health expenditure (% of GDP)",
        category="spending",
        unit="% of GDP",
        polarity="context",
    ),
    Indicator(
        code="SH.MED.BEDS.ZS",
        name="Hospital beds per 1,000 people",
        category="infrastructure",
        unit="per 1,000 people",
        polarity="context",
    ),
    Indicator(
        code="SH.MED.PHYS.ZS",
        name="Physicians per 1,000 people",
        category="infrastructure",
        unit="per 1,000 people",
        polarity="context",
    ),
    Indicator(
        code="SP.DYN.LE00.IN",
        name="Life expectancy at birth",
        category="outcome",
        unit="years",
        polarity="higher_is_better",
    ),
    Indicator(
        code="SP.DYN.IMRT.IN",
        name="Infant mortality rate",
        category="outcome",
        unit="per 1,000 live births",
        polarity="lower_is_better",
    ),
    Indicator(
        code="SH.DYN.NCOM.ZS",
        name="Premature mortality from noncommunicable diseases",
        category="outcome",
        unit="% probability between ages 30 and 70",
        polarity="lower_is_better",
    ),
]

DEFAULT_START_YEAR = int(os.getenv("START_YEAR", "2000"))
DEFAULT_END_YEAR = int(os.getenv("END_YEAR", "2024"))
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg2://postgres:postgres@localhost:5432/health_efficiency",
)
