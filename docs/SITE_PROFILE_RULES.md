# Site Profile Rules

견적서 사이트별 인식 규칙은 `backend/auto_money_doc/extraction/site_profiles.py`에 추가한다.

## 동작 방식

1. Gemini가 견적서 이미지/PDF에서 구매 사이트 또는 견적서 형식을 먼저 판별한다.
2. `SITE_PROFILES`에 일치하는 사이트가 있으면 해당 규칙을 우선 적용한다.
3. 일치하는 사이트가 없으면 공통 쇼핑몰 견적서 규칙을 적용한다.
4. 앱의 `설정 > 사이트 설정`에 입력한 문장은 `[User configured rules]`로 함께 전달된다.

## 추가 예시

```python
SITE_PROFILES = {
    "Gmarket": "...",
    "NewSite": """
Detect this profile when the quotation is from NewSite.
Put the first option row into specification.
If no option row exists, leave specification empty.
""".strip(),
}
```
