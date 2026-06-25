from __future__ import annotations

import json
import os
from pathlib import Path

from pydantic import BaseModel, Field


APP_NAME = "AutoMoneyDocMake"


class AppSettings(BaseModel):
    gemini_api_key: str = ""
    default_output_dir: str = ""
    template_path: str = ""
    school_name: str = ""
    department: str = ""
    requester: str = ""
    site_rules: str = ""

    @property
    def has_gemini_api_key(self) -> bool:
        return bool(self.gemini_api_key.strip())


class PublicSettings(BaseModel):
    has_gemini_api_key: bool = False
    default_output_dir: str = ""
    template_path: str = ""
    school_name: str = ""
    department: str = ""
    requester: str = ""
    site_rules: str = ""


class SettingsUpdate(BaseModel):
    gemini_api_key: str | None = Field(default=None)
    default_output_dir: str | None = Field(default=None)
    template_path: str | None = Field(default=None)
    school_name: str | None = Field(default=None)
    department: str | None = Field(default=None)
    requester: str | None = Field(default=None)
    site_rules: str | None = Field(default=None)


def get_config_dir() -> Path:
    app_data = os.getenv("APPDATA")
    if app_data:
        return Path(app_data) / APP_NAME
    return Path.home() / f".{APP_NAME.lower()}"


def get_config_path() -> Path:
    return get_config_dir() / "settings.json"


def load_settings() -> AppSettings:
    path = get_config_path()
    if not path.exists():
        return AppSettings()

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return AppSettings()

    return AppSettings.model_validate(data)


def save_settings(settings: AppSettings) -> None:
    config_dir = get_config_dir()
    config_dir.mkdir(parents=True, exist_ok=True)
    get_config_path().write_text(
        settings.model_dump_json(indent=2),
        encoding="utf-8",
    )


def update_settings(update: SettingsUpdate) -> AppSettings:
    current = load_settings()
    data = current.model_dump()
    for key, value in update.model_dump(exclude_unset=True).items():
        if value is not None:
            data[key] = value

    updated = AppSettings.model_validate(data)
    save_settings(updated)
    return updated


def to_public_settings(settings: AppSettings) -> PublicSettings:
    return PublicSettings(
        has_gemini_api_key=settings.has_gemini_api_key,
        default_output_dir=settings.default_output_dir,
        template_path=settings.template_path,
        school_name=settings.school_name,
        department=settings.department,
        requester=settings.requester,
        site_rules=settings.site_rules,
    )
