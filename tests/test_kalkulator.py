"""Testy jednostkowe modułu logiki kalkulatora."""

import pytest

from logic.kalkulator import (
    dodaj,
    odejmij,
    mnoz,
    dziel,
    oblicz,
    BladDzieleniaPrzezZero,
    BladNieznanejOperacji,
)


class TestDodawanie:
    def test_dodaje_liczby_dodatnie(self):
        assert dodaj(2, 3) == 5

    def test_dodaje_liczby_ujemne(self):
        assert dodaj(-4, -6) == -10

    def test_dodaje_zero(self):
        assert dodaj(7, 0) == 7

    def test_dodaje_ulamki(self):
        assert dodaj(0.1, 0.2) == pytest.approx(0.3)


class TestOdejmowanie:
    def test_odejmuje_liczby_dodatnie(self):
        assert odejmij(10, 4) == 6

    def test_odejmuje_dajac_wynik_ujemny(self):
        assert odejmij(3, 8) == -5

    def test_odejmuje_zero(self):
        assert odejmij(5, 0) == 5


class TestMnozenie:
    def test_mnozy_liczby_dodatnie(self):
        assert mnoz(3, 4) == 12

    def test_mnozy_przez_zero(self):
        assert mnoz(999, 0) == 0

    def test_mnozy_liczby_ujemne(self):
        assert mnoz(-3, -4) == 12

    def test_mnozy_liczby_roznych_znakow(self):
        assert mnoz(-3, 4) == -12

    def test_mnozy_ulamki(self):
        assert mnoz(0.5, 4) == pytest.approx(2.0)


class TestDzielenie:
    def test_dzielic_liczby_dodatnie(self):
        assert dziel(10, 2) == 5

    def test_dzielic_z_reszta(self):
        assert dziel(7, 2) == pytest.approx(3.5)

    def test_dzielic_przez_jeden(self):
        assert dziel(42, 1) == 42

    def test_rzuca_blad_przy_dzieleniu_przez_zero(self):
        with pytest.raises(BladDzieleniaPrzezZero):
            dziel(5, 0)

    def test_komunikat_bledu_przy_dzieleniu_przez_zero(self):
        with pytest.raises(BladDzieleniaPrzezZero, match="zero"):
            dziel(1, 0)


class TestOblicz:
    @pytest.mark.parametrize(
        "a, op, b, oczekiwany",
        [
            (2, "+", 3, 5),
            (10, "-", 4, 6),
            (3, "*", 4, 12),
            (10, "/", 2, 5),
        ],
    )
    def test_wszystkie_operacje(self, a, op, b, oczekiwany):
        assert oblicz(a, op, b) == pytest.approx(oczekiwany)

    def test_nieznana_operacja_rzuca_blad(self):
        with pytest.raises(BladNieznanejOperacji):
            oblicz(1, "^", 2)

    def test_komunikat_bledu_zawiera_operacje(self):
        with pytest.raises(BladNieznanejOperacji, match=r"\^"):
            oblicz(1, "^", 2)

    def test_dzielenie_przez_zero_przez_oblicz(self):
        with pytest.raises(BladDzieleniaPrzezZero):
            oblicz(5, "/", 0)
