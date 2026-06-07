"""Moduł CLI kalkulatora — punkt wejścia programu."""

from __future__ import annotations

import argparse
import sys

from logic.kalkulator import oblicz, BladDzieleniaPrzezZero, BladNieznanejOperacji

def zbuduj_parser() -> argparse.ArgumentParser:
    """Tworzy i zwraca parser argumentów CLI."""
    parser = argparse.ArgumentParser(
        prog="kalkulator",
        description="Prosty kalkulator działający z linii poleceń.",
        epilog="Przykład: python main.py 10 / 3",
    )
    parser.add_argument(
        "a",
        type=float,
        help="Pierwsza liczba",
    )
    parser.add_argument(
        "operacja",
        choices=["+", "-", "*", "/"],
        help="Operacja do wykonania",
    )
    parser.add_argument(
        "b",
        type=float,
        help="Druga liczba",
    )
    return parser


def uruchom(argv: list[str] | None = None) -> int:
    """
    Główna funkcja CLI.

    Args:
        argv: lista argumentów (None = sys.argv)

    Returns:
        Kod wyjścia (0 = sukces, 1 = błąd).
    """
    parser = zbuduj_parser()
    args = parser.parse_args(argv)

    try:
        wynik = oblicz(args.a, args.operacja, args.b)
    except BladDzieleniaPrzezZero as e:
        print(f"Błąd: {e}", file=sys.stderr)
        return 1
    except BladNieznanejOperacji as e:
        print(f"Błąd: {e}", file=sys.stderr)
        return 1

    # Wypisz wynik — bez zbędnych miejsc po przecinku dla liczb całkowitych
    if wynik == int(wynik):
        print(f"{args.a} {args.operacja} {args.b} = {int(wynik)}")
    else:
        print(f"{args.a} {args.operacja} {args.b} = {wynik:.6g}")

    return 0


if __name__ == "__main__":
    sys.exit(uruchom())