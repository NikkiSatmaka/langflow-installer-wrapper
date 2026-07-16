#!/usr/bin/env bash
#
# Stop the Langflow server on macOS/Linux.
# Finds the server process via port 7860 or process name and terminates it.
#
# Author: Nikki Satmaka
# GitHub:  https://github.com/NikkiSatmaka/
# LinkedIn: https://linkedin.com/in/nikkisatmaka/
set -euo pipefail

PORT=7860

# ── Colors ──
if [ -t 1 ]; then
    G='\033[0;32m'
    C='\033[0;36m'
    R='\033[0;31m'
    Y='\033[0;33m'
    N='\033[0m'
else
    G=''
    C=''
    R=''
    Y=''
    N=''
fi

# ── Banner ──
echo ""
echo -e "${G}╔══════════════════════════════════════════════════╗${N}"
echo -e "${G}║${C}           Stop Langflow Server                  ${G}║${N}"
echo -e "${G}║──────────────────────────────────────────────────║${N}"
echo -e "${G}║${N}  GitHub:  https://github.com/NikkiSatmaka/       ${G}║${N}"
echo -e "${G}║${N}  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ${G}║${N}"
echo -e "${G}╚══════════════════════════════════════════════════╝${N}"
echo ""

# ── Helpers ──
info() { echo -e "${C} $*${N}"; }
ok() { echo -e "${G} ✓ $*${N}"; }
fail() { echo -e "${R} ✗ $*${N}"; }
warn() { echo -e "${Y} ⚠ $*${N}"; }

# ── Stop Logic ──

stop_server() {
    local pid=""

    # Method 1: Find by port via lsof
    if command -v lsof &>/dev/null; then
        pid=$(lsof -ti:"$PORT" 2>/dev/null || true)
    fi

    # Method 2: Find by process name
    if [ -z "$pid" ]; then
        pid=$(pgrep -f "uv run langflow run" 2>/dev/null || true)
    fi
    if [ -z "$pid" ]; then
        pid=$(pgrep -f "langflow run" 2>/dev/null || true)
    fi

    if [ -n "$pid" ]; then
        info "Found Langflow process (PID: $pid). Stopping..."
        kill -9 "$pid" 2>/dev/null || true
        ok "Langflow server stopped."
    else
        warn "No running Langflow server found."
    fi
}

stop_server

echo ""
read -r -p "$(echo -e "${C}Press Enter to close this window...${N}")"
