from auto_money_doc.extraction.site_profiles import format_site_profiles


BASE_EXTRACTION_PROMPT = """
You extract structured purchase quotation data for a Korean school office workflow.

Return only valid JSON. Do not include markdown fences or commentary.

JSON schema:
{
  "quotation": {
    "vendor_name": "",
    "vendor_business_number": "",
    "vendor_phone_number": "",
    "quotation_date": "",
    "validity_period": "",
    "contact_person": "",
    "supply_amount": null,
    "tax_amount": null,
    "total_amount": null,
    "notes": "",
    "items": [
      {
        "item_name": "",
        "specification": "",
        "quantity": null,
        "unit": "",
        "unit_price": null,
        "supply_amount": null,
        "tax_amount": null,
        "total_amount": null,
        "notes": ""
      }
    ]
  },
  "warnings": []
}

Rules:
- Preserve Korean names exactly.
- Use numbers only for money and quantity values.
- The final Excel columns are 내용, 규격, 수량, 단위, 예상단가, 예상금액.
- Map 내용 to item_name, 규격 to specification, 수량 to quantity, 단위 to unit, 예상단가 to unit_price, and 예상금액 to total_amount.
- If the quotation does not clearly specify a unit, use "개" for unit.
- Put only the base product name in item_name.
- In shopping-mall quotation rows, the first/main product line is usually item_name, and the smaller line below it is usually specification.
- Put required options, selected options, additional configuration, color, size, capacity, model details, delivery/package details, and other variants in specification.
- Example: "프린텍 애니라벨 물류관리 바코드 분류표기 우편발송 택배 A4 라벨지 100매" is item_name, and "B. 우편발송라벨 +13)V3340-100(24칸/100매)" is specification.
- If a field is missing or uncertain, use an empty string or null and add a warning.
- If the document has multiple pages, combine item rows into one quotation.
- If VAT is included but not separately shown, set tax_amount to null and add a warning.
""".strip()


def build_extraction_prompt(site_rules: str = "") -> str:
    return "\n\n".join(
        [
            BASE_EXTRACTION_PROMPT,
            "Site profile rules:\n"
            "1. First identify the purchase site/vendor format from the quotation image or PDF.\n"
            "2. If a site profile matches, apply only that site's profile rules before the general shopping-mall rules.\n"
            "3. If no site profile matches, use the general rules.\n\n"
            f"{format_site_profiles(site_rules)}",
        ]
    )


EXTRACTION_PROMPT = build_extraction_prompt()
