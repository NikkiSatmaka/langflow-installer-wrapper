#!/usr/bin/env bash
#
# Verify a real installer run in CI: checks the virtual environment, the
# installed Langflow version, and the launcher/stop artifacts created by
# src/install-langflow.sh or src/install-langflow-script.ps1.
# Run from repo root: bash scripts/verify-install.sh <os> <expected-version>
#   os: Linux | macOS | Windows (matches $RUNNER_OS)
set -euo pipefail

OS="$1"
EXPECTED="$2"
LANGFLOW_DIR="$HOME/langflow"
FAILED=0

check() {
    if [ ! -e "$1" ]; then
        echo "FAIL: missing $1"
        FAILED=1
    fi
}

warn_check() {
    if [ ! -e "$1" ]; then
        echo "WARN: $1 not found (headless runner may lack a Desktop)"
    fi
}

if [ ! -f "$LANGFLOW_DIR/.venv/pyvenv.cfg" ]; then
    echo "FAIL: virtual environment not created at $LANGFLOW_DIR/.venv"
    exit 1
fi

INSTALLED=$(cd "$LANGFLOW_DIR" && uv run langflow --version 2>/dev/null | awk '/^langflow /{print $2; exit}') || INSTALLED=""
echo "Installed: $INSTALLED, Expected: $EXPECTED"
if [ -z "$INSTALLED" ] || [ "$INSTALLED" != "$EXPECTED" ]; then
    echo "FAIL: installed version '$INSTALLED' does not match pin '$EXPECTED'"
    exit 1
fi

case "$OS" in
    Windows)
        check "$LANGFLOW_DIR/run-langflow.bat"
        check "$LANGFLOW_DIR/stop-langflow.ps1"
        warn_check "$HOME/Desktop/Langflow Web.lnk"
        warn_check "$HOME/Desktop/Stop Langflow.lnk"
        ;;
    macOS)
        check "$LANGFLOW_DIR/start-langflow.sh"
        check "$LANGFLOW_DIR/stop-langflow.sh"
        check "$HOME/Desktop/Langflow Web.command"
        check "$HOME/Desktop/Stop Langflow.command"
        ;;
    Linux)
        check "$LANGFLOW_DIR/start-langflow.sh"
        check "$LANGFLOW_DIR/stop-langflow.sh"
        check "$HOME/.local/share/applications/langflow.desktop"
        ;;
    *)
        echo "FAIL: unknown OS '$OS' (expected Linux, macOS, or Windows)"
        exit 1
        ;;
esac

if [ "$FAILED" -ne 0 ]; then
    exit 1
fi
echo "OK: install verified (langflow $INSTALLED)"
