from __future__ import annotations

from decimal import Decimal
from typing import Any

from pydantic import BaseModel, Field


class QuotationItem(BaseModel):
    item_name: str = ""
    specification: str = ""
    quantity: Decimal | None = None
    unit: str = ""
    unit_price: Decimal | None = None
    supply_amount: Decimal | None = None
    tax_amount: Decimal | None = None
    total_amount: Decimal | None = None
    notes: str = ""


class QuotationData(BaseModel):
    source_file_names: list[str] = Field(default_factory=list)
    vendor_name: str = ""
    vendor_business_number: str = ""
    vendor_phone_number: str = ""
    quotation_date: str = ""
    validity_period: str = ""
    contact_person: str = ""
    supply_amount: Decimal | None = None
    tax_amount: Decimal | None = None
    total_amount: Decimal | None = None
    notes: str = ""
    items: list[QuotationItem] = Field(default_factory=list)


class ApprovalMetadata(BaseModel):
    school_name: str = ""
    department: str = ""
    requester: str = ""
    budget_category: str = ""
    project_name: str = ""
    purchase_purpose: str = ""
    request_date: str = ""


class ExtractionRequest(BaseModel):
    file_paths: list[str]


class ExtractionResponse(BaseModel):
    quotation: QuotationData
    warnings: list[str] = Field(default_factory=list)


class GenerateExcelRequest(BaseModel):
    quotation: QuotationData
    approval_metadata: ApprovalMetadata = Field(default_factory=ApprovalMetadata)
    template_path: str = ""
    output_path: str = ""
    template_mapping: "TemplateMapping | None" = None


class GenerateExcelResponse(BaseModel):
    output_path: str


class CellMapping(BaseModel):
    field_key: str
    sheet_name: str
    cell: str
    confidence: float = 0.0
    source_label: str = ""


class ItemTableMapping(BaseModel):
    sheet_name: str = ""
    start_row: int = 0
    columns: dict[str, str] = Field(default_factory=dict)
    confidence: float = 0.0


class TemplateMapping(BaseModel):
    scalar_fields: list[CellMapping] = Field(default_factory=list)
    item_table: ItemTableMapping | None = None
    warnings: list[str] = Field(default_factory=list)


class InferTemplateMappingRequest(BaseModel):
    template_path: str


class InferTemplateMappingResponse(BaseModel):
    template_mapping: TemplateMapping


class GeminiQuotationPayload(BaseModel):
    quotation: QuotationData
    warnings: list[str] = Field(default_factory=list)
    raw: dict[str, Any] = Field(default_factory=dict)
