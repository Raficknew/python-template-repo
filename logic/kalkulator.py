"""Moduł z logiką kalkulatora."""


class BladDzieleniaPrzezZero(Exception):
    """Wyjątek rzucany przy próbie dzielenia przez zero."""


class BladNieznanejOperacji(Exception):
    """Wyjątek rzucany przy nieznanej operacji."""


def dodaj(a: float, b: float) -> float:
    """Zwraca sumę a i b."""
    return a + b


def odejmij(a: float, b: float) -> float:
    """Zwraca różnicę a i b."""
    return a - b


def mnoz(a: float, b: float) -> float:
    """Zwraca iloczyn a i b."""
    return a * b


def dziel(a: float, b: float) -> float:
    """Zwraca iloraz a i b. Rzuca BladDzieleniaPrzezZero gdy b == 0."""
    if b == 0:
        raise BladDzieleniaPrzezZero("Nie można dzielić przez zero!")
    return a / b


OPERACJE = {
    "+": dodaj,
    "-": odejmij,
    "*": mnoz,
    "/": dziel,
}


def oblicz(a: float, operacja: str, b: float) -> float:
    """
    Wykonuje operację na liczbach a i b.

    Args:
        a: pierwsza liczba
        operacja: znak operacji (+, -, *, /)
        b: druga liczba

    Returns:
        Wynik operacji.

    Raises:
        BladNieznanejOperacji: gdy operacja jest nieznana
        BladDzieleniaPrzezZero: gdy dzielnik wynosi 0
    """
    if operacja not in OPERACJE:
        raise BladNieznanejOperacji(
            f"Nieznana operacja: '{operacja}'. "
            f"Dostępne: {', '.join(OPERACJE.keys())}"
        )
    return OPERACJE[operacja](a, b)