#!/usr/bin/env bash
# scripts/lint.sh — analiza statyczna kodu (pylint)
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ── Kolory ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[lint]${NC} $*"; }
warning() { echo -e "${YELLOW}[lint]${NC} $*"; }
error()   { echo -e "${RED}[lint]${NC} $*" >&2; }

# ── Domyślne opcje ─────────────────────────────────────────────────────────────
MIN_SCORE="8.0"
TARGETS=(main.py logic/ tests/)

usage() {
    cat <<EOF
Użycie: $(basename "$0") [OPCJE] [ŚCIEŻKI...]

Opcje:
  --min-score OCENA  Minimalna ocena pylint (domyślnie: $MIN_SCORE)
                     Kod wyjścia 1 jeśli ocena jest niższa
  -h, --help         Pokaż tę pomoc

Przykłady:
  $(basename "$0")                   # analiza całego projektu
  $(basename "$0") --min-score 9.0   # wymagaj oceny >= 9.0
  $(basename "$0") logic/            # analizuj tylko logikę
EOF
}

# ── Parsuj argumenty ───────────────────────────────────────────────────────────
CUSTOM_TARGETS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --min-score) MIN_SCORE="$2"; shift 2 ;;
        -h|--help)   usage; exit 0 ;;
        *)           CUSTOM_TARGETS+=("$1"); shift ;;
    esac
done

[[ ${#CUSTOM_TARGETS[@]} -gt 0 ]] && TARGETS=("${CUSTOM_TARGETS[@]}")

# ── Sprawdź dostępność pylint ──────────────────────────────────────────────────
if ! command -v pylint &>/dev/null && ! python -m pylint --version &>/dev/null 2>&1; then
    error "Nie znaleziono pylint. Zainstaluj: pip install pylint"
    exit 1
fi

# ── Uruchom pylint ─────────────────────────────────────────────────────────────
info "Analizuję: ${TARGETS[*]}"
info "Wymagana minimalna ocena: $MIN_SCORE"
echo ""

PYLINT_OUTPUT=$(python -m pylint "${TARGETS[@]}" 2>&1) || true
echo "$PYLINT_OUTPUT"

# ── Wyciągnij ocenę końcową ────────────────────────────────────────────────────
SCORE=$(echo "$PYLINT_OUTPUT" | grep -oP 'rated at \K[0-9]+\.[0-9]+' | tail -1)

if [[ -z "$SCORE" ]]; then
    warning "Nie udało się odczytać oceny pylint."
    exit 0
fi

echo ""

# ── Porównaj z progiem (bash nie ma bc, używamy pythona) ──────────────────────
PASSED=$(python3 -c "print('1' if float('$SCORE') >= float('$MIN_SCORE') else '0')")

if [[ "$PASSED" == "1" ]]; then
    info "Ocena pylint: $SCORE / 10.00  ✓  (próg: $MIN_SCORE)"
else
    error "Ocena pylint: $SCORE / 10.00  ✗  (próg: $MIN_SCORE — zbyt niska)"
    exit 1
fi