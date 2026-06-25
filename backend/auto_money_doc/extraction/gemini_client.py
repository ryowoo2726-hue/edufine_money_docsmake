from __future__ import annotations

import json
import mimetypes
from pathlib import Path
from typing import Any

from pydantic import ValidationError

from auto_money_doc.extraction.prompts import build_extraction_prompt
from auto_money_doc.extraction.schema import GeminiQuotationPayload, QuotationData


class GeminiExtractionError(RuntimeError):
    pass


def _load_genai_client(api_key: str):
    try:
        from google import genai
        from google.genai import types
    except ImportError as exc:
        raise GeminiExtractionError(
            "google-genai is not installed. Install project dependencies first."
        ) from exc

    return genai.Client(api_key=api_key), types


def _clean_json_text(text: str) -> str:
    cleaned = text.strip()
    if cleaned.startswith("```"):
        lines = cleaned.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        cleaned = "\n".join(lines).strip()
    return cleaned


def _file_part(path: Path, types: Any):
    mime_type = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    return types.Part.from_bytes(data=path.read_bytes(), mime_type=mime_type)


def extract_quotation_with_gemini(
    file_paths: list[Path],
    api_key: str,
    site_rules: str = "",
    model: str = "gemini-2.5-flash",
) -> GeminiQuotationPayload:
    if not api_key.strip():
        raise GeminiExtractionError("Gemini API key is missing.")

    client, types = _load_genai_client(api_key)
    parts: list[Any] = [build_extraction_prompt(site_rules)]
    parts.extend(_file_part(path, types) for path in file_paths)

    response = client.models.generate_content(model=model, contents=parts)
    text = getattr(response, "text", "") or ""
    if not text.strip():
        raise GeminiExtractionError("Gemini returned an empty response.")

    try:
        raw = json.loads(_clean_json_text(text))
    except json.JSONDecodeError as exc:
        raise GeminiExtractionError("Gemini response was not valid JSON.") from exc

    try:
        quotation = QuotationData.model_validate(raw.get("quotation", raw))
        warnings = list(raw.get("warnings", []))
    except (ValidationError, TypeError) as exc:
        raise GeminiExtractionError("Gemini response did not match quotation schema.") from exc

    for item in quotation.items:
        if not item.unit.strip():
            item.unit = "개"

    quotation.source_file_names = [path.name for path in file_paths]
    return GeminiQuotationPayload(quotation=quotation, warnings=warnings, raw=raw)
