#!/usr/bin/env bash
# scripts/test.sh — uruchamianie testów
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ── Kolory ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[test]${NC} $*"; }
error() { echo -e "${RED}[test]${NC} $*" >&2; }

# ── Domyślne opcje ─────────────────────────────────────────────────────────────
VERBOSE=0
COVERAGE=0
FAILFAST=0
EXTRA_ARGS=()

usage() {
    cat <<EOF
Użycie: $(basename "$0") [OPCJE] [-- PYTEST_ARGS]

Opcje:
  -v, --verbose     Szczegółowe wyjście pytest (-v)
  -c, --coverage    Raport pokrycia kodu (wymaga pytest-cov)
  -f, --failfast    Zatrzymaj po pierwszym błędzie (-x)
  -h, --help        Pokaż tę pomoc

Przykłady:
  $(basename "$0")                        # uruchom wszystkie testy
  $(basename "$0") -v -f                  # verbose + zatrzymaj przy błędzie
  $(basename "$0") -c                     # z raportem pokrycia
  $(basename "$0") -- tests/test_cli.py   # tylko wybrany plik
EOF
}

# ── Parsuj argumenty ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose)  VERBOSE=1;  shift ;;
        -c|--coverage) COVERAGE=1; shift ;;
        -f|--failfast) FAILFAST=1; shift ;;
        -h|--help)     usage; exit 0 ;;
        --)            shift; EXTRA_ARGS=("$@"); break ;;
        *)             EXTRA_ARGS+=("$1"); shift ;;
    esac
done

# ── Zbuduj polecenie pytest ────────────────────────────────────────────────────
PYTEST_CMD=(python -m pytest)

[[ $VERBOSE  -eq 1 ]] && PYTEST_CMD+=(-v)
[[ $FAILFAST -eq 1 ]] && PYTEST_CMD+=(-x)

if [[ $COVERAGE -eq 1 ]]; then
    if ! python -c "import pytest_cov" &>/dev/null; then
        echo -e "${RED}[test]${NC} Brak pytest-cov. Zainstaluj: pip install pytest-cov" >&2
        exit 1
    fi
    PYTEST_CMD+=(--cov=. --cov-report=term-missing --cov-report=html:htmlcov)
fi

PYTEST_CMD+=("${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}")

# ── Uruchom ────────────────────────────────────────────────────────────────────
info "Uruchamiam: ${PYTEST_CMD[*]}"
echo ""

if "${PYTEST_CMD[@]}"; then
    echo ""
    info "Wszystkie testy przeszły ✓"
    if [[ $COVERAGE -eq 1 ]]; then info "Raport HTML: htmlcov/index.html"; fi
else
    echo ""
    error "Testy nie przeszły ✗"
    exit 1
fi