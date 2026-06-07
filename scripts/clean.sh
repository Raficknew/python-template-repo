#!/usr/bin/env bash
# scripts/clean.sh — czyszczenie repozytorium ze zbędnych plików
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ── Kolory ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[clean]${NC} $*"; }
warning() { echo -e "${YELLOW}[clean]${NC} $*"; }
error()   { echo -e "${RED}[clean]${NC} $*" >&2; }

# ── Domyślne opcje ─────────────────────────────────────────────────────────────
CLEAN_VENV=0
DRY_RUN=0

usage() {
    cat <<EOF
Użycie: $(basename "$0") [OPCJE]

Usuwa pliki tymczasowe i artefakty budowania z repozytorium.

Opcje:
  --venv      Usuń również środowisko wirtualne (.venv/)
  --dry-run   Pokaż co zostałoby usunięte, bez wykonywania zmian
  -h, --help  Pokaż tę pomoc

Co jest usuwane (domyślnie):
  __pycache__/      katalogi z bytecode Pythona
  *.pyc, *.pyo      skompilowane pliki Pythona
  .pytest_cache/    cache pytest
  .coverage         plik pokrycia kodu
  htmlcov/          raport HTML pokrycia
  *.egg-info/       metadane pakietu
  dist/, build/     artefakty budowania
  .mypy_cache/      cache mypy
  .ruff_cache/      cache ruff
EOF
}

# ── Parsuj argumenty ───────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --venv)     CLEAN_VENV=1; shift ;;
        --dry-run)  DRY_RUN=1;    shift ;;
        -h|--help)  usage; exit 0 ;;
        *) error "Nieznana opcja: $1"; usage; exit 1 ;;
    esac
done

# ── Funkcja usuwania ───────────────────────────────────────────────────────────
removed=0

remove() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            echo "  [dry-run] usunąłby: $target"
        else
            rm -rf "$target"
            echo "  usunięto: $target"
        fi
        ((removed++)) || true
    fi
}

find_and_remove() {
    local pattern="$1"
    local type_flag="${2:--name}"   # domyślnie -name
    while IFS= read -r -d '' match; do
        remove "$match"
    done < <(find . \
        -not -path "./.venv/*" \
        -not -path "./.git/*" \
        "$type_flag" "$pattern" \
        -print0 2>/dev/null)
}

# ── Czyszczenie ────────────────────────────────────────────────────────────────
[[ $DRY_RUN -eq 1 ]] && warning "Tryb dry-run — żadne pliki nie zostaną usunięte."
echo ""

info "Usuwam cache Pythona i artefakty..."
find_and_remove "__pycache__"   -name
find_and_remove "*.pyc"         -name
find_and_remove "*.pyo"         -name
find_and_remove "*.pyd"         -name

info "Usuwam cache narzędzi..."
remove ".pytest_cache"
remove ".mypy_cache"
remove ".ruff_cache"

info "Usuwam raporty pokrycia..."
remove ".coverage"
remove "htmlcov"

info "Usuwam artefakty budowania..."
find_and_remove "*.egg-info"    -name
remove "dist"
remove "build"

if [[ $CLEAN_VENV -eq 1 ]]; then
    warning "Usuwam środowisko wirtualne..."
    remove ".venv"
fi

# ── Podsumowanie ───────────────────────────────────────────────────────────────
echo ""
if [[ $removed -eq 0 ]]; then
    info "Nic do usunięcia — repozytorium jest czyste ✓"
elif [[ $DRY_RUN -eq 1 ]]; then
    info "Dry-run: znaleziono $removed elementów do usunięcia."
else
    info "Usunięto $removed elementów ✓"
fi