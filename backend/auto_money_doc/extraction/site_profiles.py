SITE_PROFILES = {
    "Gmarket": """
Detect this profile when the quotation is from G마켓, Gmarket, or 지마켓.
For Gmarket quotations, if an item cell has two text lines, the top line is item_name and the bottom line is specification.
If it has only one line, put that line in item_name and leave specification as an empty string.
Never copy a one-line Gmarket item into specification.
If Gmarket shipping fee exists, add one item row with item_name "배송비", empty specification, quantity 1, unit "개", unit_price equal to the total shipping fee, and total_amount equal to the total shipping fee.
""".strip(),
}


def format_site_profiles(extra_rules: str = "") -> str:
    blocks = [
        f"[{site_name}]\n{rules}" for site_name, rules in SITE_PROFILES.items()
    ]
    if extra_rules.strip():
        blocks.append(f"[User configured rules]\n{extra_rules.strip()}")
    return "\n\n".join(blocks)
