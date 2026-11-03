"""Conversion of the single German storefront price format used in this test."""
import re
from decimal import Decimal


def parse_euro_price(text: str) -> Decimal:
    match = re.fullmatch(r"\s*€\s*([0-9]+),([0-9]{2})\s*", text)
    if not match:
        raise ValueError(f"Expected one EUR price like '€ 4,99'; got {text!r}")
    return Decimal(f"{match.group(1)}.{match.group(2)}")
