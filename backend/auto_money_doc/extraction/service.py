from __future__ import annotations

from pathlib import Path

from auto_money_doc.config import load_settings
from auto_money_doc.extraction.gemini_client import extract_quotation_with_gemini
from auto_money_doc.extraction.schema import ExtractionResponse


SUPPORTED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".pdf"}


def validate_source_files(file_paths: list[str]) -> list[Path]:
    if not file_paths:
        raise ValueError("At least one quotation file is required.")

    paths = [Path(file_path).expanduser() for file_path in file_paths]
    missing = [str(path) for path in paths if not path.exists()]
    if missing:
        raise ValueError(f"File does not exist: {missing[0]}")

    unsupported = [
        path.name for path in paths if path.suffix.lower() not in SUPPORTED_EXTENSIONS
    ]
    if unsupported:
        raise ValueError(f"Unsupported file format: {unsupported[0]}")

    return paths


def extract_quotation(file_paths: list[str]) -> ExtractionResponse:
    paths = validate_source_files(file_paths)
    settings = load_settings()
    payload = extract_quotation_with_gemini(
        paths,
        settings.gemini_api_key,
        settings.site_rules,
    )
    return ExtractionResponse(quotation=payload.quotation, warnings=payload.warnings)
