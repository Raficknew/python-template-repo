# Ćwiczenie: Dobre repozytorium i narzędzia

## Kontekst
Dobrze zorganizowane repozytorium pomaga w sprawnym tworzeniu kodu, pomaga też automatyzować część zadań związanych z kodowaniem, testowanie i review kodu.

## Cel ćwiczenia (efekt uczenia)
Celem ćwiczenia jest utworzenie repozytorium z programem w Pythonie, które będzie uzbrojone w:
- zautomatyzowane ustawianie virtualnego środowiska
- instalację zależności do programu
- formatowanie kodu
- lintowanie kodu
- uruchamianie testów
- workflow w GitHub Actions

## Instrukcja krok po kroku dla studentów

### Krok 1: na koncie GitHub utwóż nowe repozutorium
- zaproś do repozutorium rowadzącego zajęcia (MichalSopniewskiMerito)
- zrób pierwszy pusty commit nam 'main' branchu
- zrób branch develop

### Krok 2: Napisz prosty program z testami
- program powinien mież jeden moduł z CLI i jeden impelemtujący logikę
- moduł z logiką programu powinien znaleść się w osobnym pod katalogu
- moduł z testami w katalogu 'tests'

### Krok 3: Standaryzacja jakości kodu
1. Skonfiguruj `black` i `pylint` w `pyproject.toml`.
2. Ustaw spójny `line-length` dla wszystkich narzędzi.
3. Upewnij się, że konfiguracja nie zawiera sprzecznych reguł.

### Krok 4: Skrypty pomocnicze
1. Utwórz skrypty pomocnicze dla:
- initializaci środowiska i instalowania zależności
- uruchamiania testów
- formatowania kodu i sprawdzania formatowania
- analizy statyczne, (linting)
- czyszczenia repozytorium ze zbędnych plików


### Krok 5: Workflow CI
- w katalogu .github/workflows utwóż workflow zgodnie z dokumentacją github
https://docs.github.com/en/actions/get-started/quickstart

przykładowy workflow

```yaml
name: Python application

on:
  push:
    branches: [ $default-branch, main, master, develop]
  pull_request:
    branches: [ $default-branch, main, master]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python 3.12
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Create virtualenv and install dependencies
        run: bash scripts/create_venv.sh

      - name: Format check
        run: bash scripts/format_check.sh

      - name: Lint
        run: bash scripts/lint.sh

      - name: Test with pytest
        run: bash scripts/test.sh
```

### Krok 6: Uruchom workflow na github


### Krok 7: Dokumentacja
1. Uzupełnij `README.md` o sekcję Quick Start.
2. Dodaj instrukcję uruchamiania lint i testów.
3. Opisz, jak uruchamiany jest pipeline CI i co sprawdza.

### Krok 8: Walidacja przed oddaniem
1. Sprawdź lokalnie:
	- formatowanie,
	- lint,
	- testy.
2. Sprawdź, czy workflow przechodzi na GitHub.

### Krok 9: Oddanie zadania
1. Wypchnij gałąź do repozytorium.
2. Otwórz Pull Request do gałęzi głównej.
3. Zatwierdź PR
4. Spakuj main branch i wyślij do Moodle.
5. Dołącz potwierdzenie zielonego CI (link lub zrzut ekranu).

## Definicja ukończenia (Definition of Done)
Zadanie jest ukończone, jeśli:
1. Projekt uruchamia się lokalnie według dokumentacji.
2. Lint i testy przechodzą lokalnie.
3. Workflow CI przechodzi dla PR.
4. README zawiera komplet instrukcji dla nowej osoby w projekcie.

