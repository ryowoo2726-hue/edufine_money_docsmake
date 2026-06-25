# Function Spec For Gemini Design

## Project Purpose

This app helps school staff convert quotation PDF/image files into a purchase approval Excel document. The first target user is a Korean school employee who needs to reduce repetitive paperwork from vendor quotations.

## Product Boundaries

- Final distribution target: Windows `.exe`.
- UI technology: Flutter.
- Backend technology: Python.
- AI extraction: Gemini API reads uploaded quotation PDF/image files and returns structured purchase data.
- Output: Excel file with fixed item columns: 내용, 규격, 수량, 단위, 예상단가, 예상금액.
- Design ownership: Gemini should handle visual design. Codex will focus on feature behavior, architecture, data flow, and implementation.

## Primary User Flow

1. User opens the desktop app.
2. User adds one or more quotation PDF/image files through a dropdown-style add control.
3. App shows the selected files and basic validation state.
4. User starts analysis.
5. Python backend sends PDF/image content to Gemini API.
6. Gemini returns structured quotation data.
7. App shows extracted fields for review and correction.
8. User confirms the data.
9. Backend generates one Excel document with fixed columns: 내용, 규격, 수량, 단위, 예상단가, 예상금액.
10. User chooses where to save the `.xlsx` file.
11. App reports success and offers to open the generated file or containing folder.

## Expected Screens

### Main Upload Screen

Functional needs:

- Dropdown-style file add button.
- File picker for PDF and image uploads.
- Drag-and-drop support if practical on Windows.
- List of selected quotation files.
- Remove selected file action.
- Analyze button.
- Clear/reset button.
- API key/config status indicator.

Design notes:

- This should feel like a practical office tool, not a marketing page.
- Prioritize clarity, repeated use, and low cognitive load.

### Extraction Review Screen

Functional needs:

- Display extracted vendor, date, item rows, amounts, tax, and total.
- Allow editing extracted values before Excel generation.
- Show confidence or warning state for uncertain fields when available.
- Show original quotation PDF/image preview beside or near extracted data.
- Generate Excel button.
- Back to upload button.

### Result Screen Or Modal

Functional needs:

- Success/failure message.
- Generated file path.
- Open file button.
- Open containing folder button.
- Start another document button.

### Settings Screen

Functional needs:

- Gemini API key input.
- Save/test API key action.
- Default output folder setting.
- Optional school/user default metadata settings.

## Core Data Fields

Quotation-level fields:

- Vendor name
- Vendor business number
- Vendor phone number
- Quotation date
- Validity period
- 담당자/contact person
- Supply amount
- VAT/tax
- Total amount
- Notes

Item row fields:

- Item name
- Specification/model
- Quantity
- Unit
- Unit price
- Supply amount
- Tax amount
- Total amount
- Notes

Approval document fields:

- School name
- Department
- Drafter/requester
- Budget category
- Purchase purpose
- Purchase date/request date
- Vendor
- Item summary
- Detailed item rows
- Total amount

## Backend Responsibilities

- Validate input PDF/image paths and supported formats.
- Call Gemini API with a prompt that requests strict JSON output.
- Parse and validate Gemini's response.
- Normalize money values, dates, and item rows.
- Return structured data to Flutter.
- Generate Excel with fixed columns without requiring an uploaded template.
- Save output file to the selected path. If the user chooses only a folder, follow the source quotation file name and append `_품의서.xlsx`.
- Return user-friendly errors.

## Frontend Responsibilities

- Provide Windows-friendly file selection and review screens.
- Send requests to the Python backend.
- Render extracted data in editable form controls.
- Let the user choose save location.
- Display progress and error states.

## Recommended Architecture

- `apps/flutter_ui/`: Flutter desktop app.
- `backend/`: Python package for OCR/AI extraction and Excel generation.
- `docs/`: Functional specs, API contracts, design handoff notes.
- `templates/`: Excel templates.
- `samples/`: Local test quotations and generated outputs. Do not commit private school data.

Suggested backend modules:

- `backend/config.py`: settings, environment variables, paths.
- `backend/gemini_client.py`: Gemini API wrapper.
- `backend/extraction/schema.py`: Pydantic models for extracted quotation data.
- `backend/extraction/service.py`: extraction orchestration.
- `backend/excel/generator.py`: Excel creation.
- `backend/api/server.py`: local HTTP API or IPC bridge for Flutter.

## Flutter-Python Integration Options

Preferred first version:

- Run Python as a local backend service on `127.0.0.1` using FastAPI.
- Flutter calls local HTTP endpoints.
- Package both Flutter app and Python runtime/service for Windows distribution.

Alternative:

- Flutter starts Python executable as a subprocess and communicates over stdin/stdout or local HTTP.

## Initial API Contract Draft

### `POST /extract`

Input:

```json
{
  "file_paths": ["C:/path/quote1.pdf"]
}
```

Output:

```json
{
  "quotation": {
    "vendor_name": "",
    "quotation_date": "",
    "supply_amount": 0,
    "tax_amount": 0,
    "total_amount": 0,
    "items": []
  },
  "warnings": []
}
```

### `POST /generate-excel`

Input:

```json
{
  "quotation": {},
  "approval_metadata": {},
  "template_path": "",
  "output_path": ""
}
```

Output:

```json
{
  "output_path": "C:/path/generated.xlsx"
}
```

## Error States To Design

- Missing Gemini API key.
- Unsupported file format.
- Gemini API failure.
- Extraction result is incomplete.
- Output file is open or cannot be overwritten.
- Network unavailable.

## Open Questions

See `docs/PRODUCT_QUESTIONS.md`.

## Confirmed Product Decisions

- Quotation inputs are expected to be PDF files, sometimes with multiple pages, while image files should also be accepted.
- The upload control should use a dropdown-style add action.
- The app includes a review/edit step before Excel generation.
- Gemini API key is entered in the app and saved locally for reuse.
- Generated file names should follow the source quotation file name when possible.
- Multiple PDFs selected together produce one Excel file.
- Excel template upload is not required for the default workflow.
- Generated Excel columns are 내용, 규격, 수량, 단위, 예상단가, 예상금액.
- Local plain settings-file storage is sufficient for the Gemini API key in the first version.
