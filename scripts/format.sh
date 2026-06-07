#!/usr/bin/env bash
# scripts/format.sh — formatowanie kodu (black) i sprawdzanie formatowania
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ── Kolory ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[format]${NC} $*"; }
warning() { echo -e "${YELLOW}[format]${NC} $*"; }
error()   { echo -e "${RED}[format]${NC} $*" >&2; }

# ── Domyślne opcje ─────────────────────────────────────────────────────────────
CHECK_ONLY=0
TARGETS=(.)   # domyślnie cały projekt

usage() {
    cat <<EOF
Użycie: $(basename "$0") [OPCJE] [ŚCIEŻKI...]

Opcje:
  --check   Tylko sprawdź formatowanie, nie modyfikuj plików
            (kod wyjścia 1 jeśli coś wymaga formatowania)
  -h, --help  Pokaż tę pomoc

Przykłady:
  $(basename "$0")               # sformatuj cały projekt
  $(basename "$0") --check       # sprawdź bez zmian (tryb CI)
  $(basename "$0") main.py       # sformatuj pojedynczy plik
EOF
}

# ── Parsuj argumenty ───────────────────────────────────────────────────────────
CUSTOM_TARGETS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --check)    CHECK_ONLY=1; shift ;;
        -h|--help)  usage; exit 0 ;;
        *)          CUSTOM_TARGETS+=("$1"); shift ;;
    esac
done

[[ ${#CUSTOM_TARGETS[@]} -gt 0 ]] && TARGETS=("${CUSTOM_TARGETS[@]}")

# ── Sprawdź dostępność black ───────────────────────────────────────────────────
if ! command -v black &>/dev/null && ! python -m black --version &>/dev/null 2>&1; then
    error "Nie znaleziono black. Zainstaluj: pip install black"
    exit 1
fi

BLACK_CMD=(python -m black)

# ── Uruchom ────────────────────────────────────────────────────────────────────
if [[ $CHECK_ONLY -eq 1 ]]; then
    info "Sprawdzam formatowanie (tryb --check): ${TARGETS[*]}"
    echo ""
    if "${BLACK_CMD[@]}" --check "${TARGETS[@]}"; then
        echo ""
        info "Formatowanie poprawne ✓"
    else
        echo ""
        error "Kod wymaga formatowania. Uruchom: $(basename "$0")"
        exit 1
    fi
else
    info "Formatuję: ${TARGETS[*]}"
    echo ""
    "${BLACK_CMD[@]}" "${TARGETS[@]}"
    echo ""
    info "Formatowanie zakończone ✓"
fi