from decimal import Decimal

import pytest

from libraries.prices import parse_euro_price


def test_ordinary_price():
    assert parse_euro_price("€ 4,99") == Decimal("4.99")


def test_non_breaking_space():
    assert parse_euro_price("€\u00a04,99") == Decimal("4.99")


def test_two_prices_are_ambiguous():
    with pytest.raises(ValueError, match="Expected one EUR price"):
        parse_euro_price("€ 4,99 € 49,90 / 1 l")
