from __future__ import annotations

from fastapi import FastAPI, HTTPException

from auto_money_doc.config import (
    SettingsUpdate,
    load_settings,
    to_public_settings,
    update_settings,
)
from auto_money_doc.excel.generator import generate_excel
from auto_money_doc.excel.template_mapper import infer_template_mapping
from auto_money_doc.extraction.schema import (
    ExtractionRequest,
    ExtractionResponse,
    GenerateExcelRequest,
    GenerateExcelResponse,
    InferTemplateMappingRequest,
    InferTemplateMappingResponse,
)
from auto_money_doc.extraction.service import extract_quotation


app = FastAPI(title="Auto Money Doc Make API", version="0.1.0")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/settings")
def get_settings():
    return to_public_settings(load_settings())


@app.put("/settings")
def put_settings(update: SettingsUpdate):
    return to_public_settings(update_settings(update))


@app.post("/extract", response_model=ExtractionResponse)
def post_extract(request: ExtractionRequest) -> ExtractionResponse:
    try:
        return extract_quotation(request.file_paths)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@app.post("/infer-template-mapping", response_model=InferTemplateMappingResponse)
def post_infer_template_mapping(
    request: InferTemplateMappingRequest,
) -> InferTemplateMappingResponse:
    try:
        return infer_template_mapping(request.template_path)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@app.post("/generate-excel", response_model=GenerateExcelResponse)
def post_generate_excel(request: GenerateExcelRequest) -> GenerateExcelResponse:
    try:
        output = generate_excel(
            quotation=request.quotation,
            approval_metadata=request.approval_metadata,
            template_path=request.template_path,
            output_path=request.output_path,
            template_mapping=request.template_mapping,
        )
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return GenerateExcelResponse(output_path=str(output))
