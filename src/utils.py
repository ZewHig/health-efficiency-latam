from __future__ import annotations

from pathlib import Path


def get_project_root() -> Path:
    """Return the repository root based on this file location."""
    return Path(__file__).resolve().parents[1]


def ensure_directory(path: Path) -> None:
    """Create a directory if it does not exist."""
    path.mkdir(parents=True, exist_ok=True)
