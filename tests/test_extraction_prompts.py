from auto_money_doc.extraction.prompts import build_extraction_prompt


def test_prompt_contains_builtin_and_custom_site_rules():
    prompt = build_extraction_prompt("11번가: 옵션 줄은 규격으로 추출한다.")

    assert "First identify the purchase site" in prompt
    assert "[Gmarket]" in prompt
    assert "one line" in prompt
    assert "[User configured rules]" in prompt
    assert "11번가" in prompt
