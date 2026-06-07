#!/usr/bin/env bash
# scripts/init.sh — inicjalizacja środowiska i instalacja zależności
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$PROJECT_ROOT/.venv"
PYTHON="${PYTHON:-python3}"

# ── Kolory ─────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[init]${NC} $*"; }
warning() { echo -e "${YELLOW}[init]${NC} $*"; }
error()   { echo -e "${RED}[init]${NC} $*" >&2; exit 1; }

# ── Sprawdź Pythona ────────────────────────────────────────────────────────────
command -v "$PYTHON" &>/dev/null || error "Nie znaleziono '$PYTHON'. Zainstaluj Python 3.9+."

PY_VERSION=$("$PYTHON" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
PY_MAJOR=$("$PYTHON" -c "import sys; print(sys.version_info.major)")
PY_MINOR=$("$PYTHON" -c "import sys; print(sys.version_info.minor)")

if [[ "$PY_MAJOR" -lt 3 || ( "$PY_MAJOR" -eq 3 && "$PY_MINOR" -lt 9 ) ]]; then
    error "Wymagany Python 3.9+. Znaleziono: $PY_VERSION"
fi
info "Używam Pythona $PY_VERSION ($("$PYTHON" -c "import sys; print(sys.executable)"))"

# ── Utwórz lub odśwież venv ────────────────────────────────────────────────────
if [[ -d "$VENV_DIR" && "${CI:-}" != "true" ]]; then
    warning "Środowisko wirtualne już istnieje: $VENV_DIR"
    read -rp "        Odtworzyć od zera? [t/N] " answer
    if [[ "${answer,,}" == "t" ]]; then
        info "Usuwam stare środowisko..."
        rm -rf "$VENV_DIR"
    else
        info "Pomijam tworzenie venv."
    fi
fi

if [[ ! -d "$VENV_DIR" ]]; then
    info "Tworzę środowisko wirtualne w $VENV_DIR ..."
    "$PYTHON" -m venv "$VENV_DIR"
fi

# ── Aktywuj venv ───────────────────────────────────────────────────────────────
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

# ── Aktualizuj pip ─────────────────────────────────────────────────────────────
info "Aktualizuję pip..."
pip install --quiet --upgrade pip

# ── Zainstaluj zależności ──────────────────────────────────────────────────────
REQUIREMENTS="$PROJECT_ROOT/requirements-dev.txt"

if [[ -f "$REQUIREMENTS" ]]; then
    info "Instaluję zależności z $REQUIREMENTS ..."
    pip install --quiet -r "$REQUIREMENTS"
else
    warning "Brak $REQUIREMENTS — instaluję domyślne narzędzia developerskie."
    pip install --quiet pytest black pylint
fi

info "Gotowe! Aktywuj środowisko poleceniem:"
echo -e "        ${YELLOW}source .venv/bin/activate${NC}"