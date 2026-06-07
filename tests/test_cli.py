"""Testy jednostkowe modułu CLI."""

import pytest

from main import uruchom, zbuduj_parser


class TestParser:
    def test_parser_poprawne_argumenty(self):
        parser = zbuduj_parser()
        args = parser.parse_args(["10", "+", "5"])
        assert args.a == 10.0
        assert args.operacja == "+"
        assert args.b == 5.0

    def test_parser_odrzuca_nieznana_operacje(self):
        parser = zbuduj_parser()
        with pytest.raises(SystemExit):
            parser.parse_args(["10", "^", "5"])

    def test_parser_odrzuca_brak_argumentow(self):
        parser = zbuduj_parser()
        with pytest.raises(SystemExit):
            parser.parse_args([])


class TestUruchom:
    def test_dodawanie(self, capsys):
        kod = uruchom(["3", "+", "4"])
        assert kod == 0
        captured = capsys.readouterr()
        assert "7" in captured.out

    def test_odejmowanie(self, capsys):
        kod = uruchom(["10", "-", "3"])
        assert kod == 0
        captured = capsys.readouterr()
        assert "7" in captured.out

    def test_mnozenie(self, capsys):
        kod = uruchom(["6", "*", "7"])
        assert kod == 0
        captured = capsys.readouterr()
        assert "42" in captured.out

    def test_dzielenie(self, capsys):
        kod = uruchom(["10", "/", "4"])
        assert kod == 0
        captured = capsys.readouterr()
        assert "2.5" in captured.out

    def test_dzielenie_przez_zero_zwraca_blad(self, capsys):
        kod = uruchom(["5", "/", "0"])
        assert kod == 1
        captured = capsys.readouterr()
        assert captured.out == ""
        assert "zero" in captured.err.lower()

    def test_wynik_calkowity_bez_ulamka(self, capsys):
        uruchom(["6", "/", "2"])
        captured = capsys.readouterr()
        assert "3" in captured.out
        assert "3.0" not in captured.out
