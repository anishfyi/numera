#!/usr/bin/env bash
# Numera Solo: bring the toolchain up.
#
# Installs the tools Numera leans on, into ITS OWN virtualenv:
#   curl_reap  fetch vendor API docs that block stock HTTP clients
#   terbium    parse bank statements and invoices out of PDF/XLSX/CSV
#   trove      durable memory of your chart of accounts and coding rules
#
# Why a venv and not `pip install`: Homebrew and most distro Pythons are marked
# externally managed (PEP 668), so a plain pip install is refused. The usual
# workaround, --break-system-packages, can genuinely break a Homebrew install.
# A dedicated venv under ~/.numera touches nothing else on the machine.
#
# It announces every install before running it, and does not prompt. Being asked
# four questions before you can do any bookkeeping is worse than being told
# clearly what is happening.
set -uo pipefail

NUMERA_HOME="${NUMERA_HOME:-$HOME/.numera}"
VENV="$NUMERA_HOME/venv"
DOCS_CACHE="$NUMERA_HOME/docs"
BOLD=$'\033[1m'; DIM=$'\033[2m'; OK=$'\033[32m'; WARN=$'\033[33m'; OFF=$'\033[0m'

step() { printf '%s==>%s %s\n' "$BOLD" "$OFF" "$*"; }
note() { printf '    %s%s%s\n' "$DIM" "$*" "$OFF"; }
good() { printf '    %s✓%s %s\n' "$OK" "$OFF" "$*"; }
warn() { printf '    %s!%s %s\n' "$WARN" "$OFF" "$*"; }

pick_python() {
  for p in python3.13 python3.12 python3.11 python3.10 python3; do
    command -v "$p" >/dev/null 2>&1 || continue
    "$p" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)' 2>/dev/null \
      && { printf '%s' "$p"; return 0; }
  done
  return 1
}

PY="$(pick_python)" || {
  warn "No Python 3.10+ found. curl_reap and terbium need one."
  note "macOS:  brew install python@3.13"
  exit 1
}
note "using $($PY --version 2>&1)"

step "Preparing $NUMERA_HOME"
mkdir -p "$DOCS_CACHE"
note "vendor docs cache: $DOCS_CACHE"
note "this cache is yours; nothing vendor-owned is ever committed to this repo"

if [ ! -x "$VENV/bin/python" ]; then
  step "Creating Numera's virtualenv"
  note "$VENV (isolated, so nothing on your system Python changes)"
  "$PY" -m venv "$VENV" || { warn "could not create venv at $VENV"; exit 1; }
  "$VENV/bin/python" -m pip install --quiet --upgrade pip >/dev/null 2>&1
  good "created"
else
  good "virtualenv already present"
fi

install_py() {
  local mod="$1" pkg="$2" why="$3"
  if "$VENV/bin/python" -c "import $mod" >/dev/null 2>&1; then
    good "$pkg already installed"
    return 0
  fi
  step "Installing $pkg"
  note "$why"
  local log; log="$(mktemp)"
  if "$VENV/bin/python" -m pip install --quiet --upgrade "$pkg" >"$log" 2>&1; then
    good "$pkg installed"
  else
    warn "could not install $pkg. Numera still works, with less:"
    note "$why"
    note "reason: $(tail -3 "$log" | tr '\n' ' ' | cut -c1-160)"
  fi
  rm -f "$log"
}

install_py curl_reap curl-reap "fetches vendor API docs that block ordinary HTTP clients"
install_py terbium   terbium-parse "parses bank statements and invoices out of PDF, XLSX and CSV"

step "Checking trove (durable memory)"
TROVE_FOUND=""
for p in "$HOME/.claude/trove" "$HOME/.claude/skills/trove" \
         "$HOME/.claude-work/skills/trove" "$HOME/.claude-work/plugins/cache/anishfyi-trove"; do
  [ -e "$p" ] && { TROVE_FOUND="$p"; break; }
done
if [ -n "$TROVE_FOUND" ]; then
  good "trove present ($TROVE_FOUND)"
else
  note "not installed. Without it, Numera forgets your chart of accounts between sessions."
  note "install:  git clone https://github.com/anishfyi/trove ~/.claude/skills/trove"
fi

step "Ready"
echo
echo "  Tools live in: $VENV/bin"
echo "  Docs cache:    $DOCS_CACHE"
echo
echo "  Next: tell Numera which accounting platform your books are on."
echo "  It pulls that vendor's docs into the cache and works from them."
echo
