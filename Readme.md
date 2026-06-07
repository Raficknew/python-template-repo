# Kalkulator CLI

Prosty kalkulator działający z linii poleceń. Obsługuje cztery podstawowe
operacje arytmetyczne i zgłasza czytelne błędy (np. dzielenie przez zero).

## Struktura projektu

```
projekt/
├── main.py                   # moduł CLI — punkt wejścia programu
├── pyproject.toml            # konfiguracja pytest / black / pylint
├── requirements-dev.txt      # zależności developerskie
├── logic/
│   └── kalkulator.py         # logika biznesowa (dodaj, odejmij, mnoz, dziel)
├── tests/
│   ├── test_kalkulator.py    # testy jednostkowe logiki
│   └── test_cli.py           # testy jednostkowe CLI
└── scripts/
    ├── init.sh               # inicjalizacja środowiska (lokalnie)
    ├── create_venv.sh        # inicjalizacja środowiska (CI)
    ├── test.sh               # uruchamianie testów
    ├── format.sh             # formatowanie kodu (black)
    ├── format_check.sh       # sprawdzanie formatowania bez zmian (CI)
    ├── lint.sh               # analiza statyczna (pylint)
    └── clean.sh              # czyszczenie repozytorium
```

---

## Quick Start

```bash
# 1. Sklonuj repozytorium
git clone <url-repozytorium>
cd projekt

# 2. Nadaj skryptom uprawnienia (tylko przy pierwszym pobraniu)
chmod +x scripts/*.sh

# 3. Utwórz środowisko wirtualne i zainstaluj zależności
./scripts/init.sh

# 4. Aktywuj środowisko wirtualne
source .venv/bin/activate

# 5. Uruchom program
python main.py 10 + 5
```

### Użycie programu

```bash
python main.py <liczba> <operacja> <liczba>

python main.py 10 + 5    # → 10.0 + 5.0 = 15
python main.py 10 / 3    # → 10.0 / 3.0 = 3.33333
python main.py 6 \* 7    # → 6.0 * 7.0 = 42
python main.py 5 / 0     # → Błąd: Nie można dzielić przez zero!
```

> **Uwaga:** znak `*` w shellu wymaga ucieczki (`\*`) lub cudzysłowów (`'*'`).

---

## Uruchamianie testów

```bash
./scripts/test.sh              # wszystkie testy
./scripts/test.sh -v           # tryb verbose
./scripts/test.sh -f           # zatrzymaj po pierwszym błędzie
./scripts/test.sh -c           # z raportem pokrycia kodu (wymaga pytest-cov)
./scripts/test.sh -- tests/test_cli.py   # tylko wybrany plik
```

Raport HTML pokrycia (po `./scripts/test.sh -c`) jest dostępny w `htmlcov/index.html`.

---

## Formatowanie i linting

### Sprawdzenie formatowania (bez zmian)

```bash
./scripts/format.sh --check
```

Kończy się kodem wyjścia `1` jeśli którykolwiek plik wymaga formatowania.

### Automatyczne formatowanie

```bash
./scripts/format.sh            # cały projekt
./scripts/format.sh main.py    # pojedynczy plik
```

### Analiza statyczna (pylint)

```bash
./scripts/lint.sh                    # próg domyślny: 8.0 / 10
./scripts/lint.sh --min-score 9.5    # wyższy próg
./scripts/lint.sh logic/             # tylko wybrany katalog
```

Kończy się kodem wyjścia `1` jeśli ocena pylint jest poniżej progu.

---

## Pipeline CI (GitHub Actions)

Pipeline jest zdefiniowany w `.github/workflows/python-app.yml` i uruchamia
się automatycznie przy każdym pushu lub pull requeście do gałęzi
`main`, `master` lub `develop`.

### Co sprawdza pipeline

```
push / pull_request
        │
        ▼
┌───────────────────┐
│ Setup Python 3.12 │
└────────┬──────────┘
         │
         ▼
┌─────────────────────────────┐
│ create_venv.sh              │  tworzy .venv i instaluje requirements-dev.txt
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ format_check.sh             │  black --check: błąd jeśli kod nie jest sformatowany
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ lint.sh                     │  pylint: błąd jeśli ocena < 8.0 / 10
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ test.sh                     │  pytest: błąd jeśli jakikolwiek test nie przejdzie
└─────────────────────────────┘
```

Każdy krok musi zakończyć się kodem `0` — w przeciwnym razie pipeline
oznacza build jako **failed** i blokuje merge pull requestu.

### Jak naprawić błędy CI lokalnie

| Błąd CI | Polecenie naprawcze |
|---|---|
| Formatowanie (`format_check.sh`) | `./scripts/format.sh` |
| Linting (`lint.sh`) | sprawdź wyjście pylint i popraw kod |
| Testy (`test.sh`) | `./scripts/test.sh -v` po szczegóły |

---

## Czyszczenie repozytorium

```bash
./scripts/clean.sh             # usuń __pycache__, .pytest_cache, htmlcov itp.
./scripts/clean.sh --dry-run   # podgląd bez usuwania
./scripts/clean.sh --venv      # usuń również .venv/
```