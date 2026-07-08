#!/usr/bin/env bash
#
# Install or uninstall Langflow on macOS/Linux using uv.
# Bootstraps uv, installs Python 3.12, creates a virtual environment,
# installs Langflow 1.10.2, and creates a desktop shortcut.
# Also supports clean uninstall of all components.
#
# Author: Nikki Satmaka
# GitHub:  https://github.com/NikkiSatmaka/
# LinkedIn: https://linkedin.com/in/nikkisatmaka/
set -euo pipefail

OS="$(uname -s)"
SCRIPT_VERSION="1.0.0"
LANGFLOW_VERSION="1.10.2"
LANGFLOW_DIR="$HOME/langflow"
UV_BIN_DIR="$HOME/.local/bin"

# ── Colors ──────────────────────────────────────────────────────────────────

if [ -t 1 ]; then
    G='\033[0;32m'; C='\033[0;36m'; B='\033[1m'
    R='\033[0;31m'; Y='\033[0;33m'; N='\033[0m'
else
    G=''; C=''; B=''; R=''; Y=''; N=''
fi

# ── Helpers ─────────────────────────────────────────────────────────────────

info()  { printf "${C} %s${N}\n" "$*"; }
ok()    { printf "${G} ✓ %s${N}\n" "$*"; }
fail()  { printf "${R} ✗ %s${N}\n" "$*"; }
warn()  { printf "${Y} ⚠ %s${N}\n" "$*"; }

# ── Banner ──────────────────────────────────────────────────────────────────

show_banner() {
    clear 2>/dev/null || printf "\033c"
    printf "${G}╔══════════════════════════════════════════════════╗${N}\n"
    printf "${G}║${C}${B}           Langflow Installer for Unix           ${G}║${N}\n"
    printf "${G}║──────────────────────────────────────────────────║${N}\n"
    printf "${G}║${N}  GitHub:  https://github.com/NikkiSatmaka/       ${G}║${N}\n"
    printf "${G}║${N}  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ${G}║${N}\n"
    printf "${G}╚══════════════════════════════════════════════════╝${N}\n"
    printf "\n"
}

# ── Menu ────────────────────────────────────────────────────────────────────

show_menu() {
    printf "${Y} [I] Install Langflow ${LANGFLOW_VERSION}${N}\n"
    printf "${Y} [U] Uninstall Langflow${N}\n"
    printf "${Y} [Q] Quit${N}\n"
    printf "\n"
    read -r -p "$(printf "${C}Type I, U, or Q and press Enter: ${N}")" choice
    printf "\n"
    printf "%s" "$choice" | tr '[:lower:]' '[:upper:]'
}

# ── uv ──────────────────────────────────────────────────────────────────────

install_uv() {
    if command -v uv &>/dev/null; then
        ok "uv already installed ($(uv --version))"
        return 0
    fi

    info "Installing uv..."
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
        fail "Failed to install uv."
        return 1
    fi

    export PATH="$UV_BIN_DIR:$PATH"

    if ! grep -qs "$UV_BIN_DIR" "$HOME/.profile" 2>/dev/null; then
        printf '\nexport PATH="%s:$PATH"\n' "$UV_BIN_DIR" >> "$HOME/.profile"
        info "Added $UV_BIN_DIR to ~/.profile"
    fi

    if command -v uv &>/dev/null; then
        ok "uv installed ($(uv --version))"
    else
        fail "uv installed but not found on PATH."
        info "Restart your terminal or run: source ~/.profile"
        return 1
    fi
    return 0
}

# ── Python ──────────────────────────────────────────────────────────────────

install_python() {
    info "Installing Python 3.12..."
    if ! uv python install 3.12 >/dev/null 2>&1; then
        fail "Failed to install Python 3.12."
        return 1
    fi

    mkdir -p "$LANGFLOW_DIR"
    pushd "$LANGFLOW_DIR" >/dev/null || return 1
    uv python pin 3.12 >/dev/null 2>&1
    popd >/dev/null || true

    ok "Python 3.12 ready"
    return 0
}

# ── Langflow ────────────────────────────────────────────────────────────────

install_langflow_package() {
    mkdir -p "$LANGFLOW_DIR"
    pushd "$LANGFLOW_DIR" >/dev/null || return 1

    if [ ! -f ".venv/pyvenv.cfg" ]; then
        info "Creating virtual environment..."
        uv venv >/dev/null 2>&1
        ok "Virtual environment created"
    else
        ok "Virtual environment already exists"
    fi

    info "Installing Langflow ${LANGFLOW_VERSION} (this may take a few minutes)..."

    install_ok=false
    if uv pip install "langflow==${LANGFLOW_VERSION}" 2>&1; then
        install_ok=true
    else
        warn "Version ${LANGFLOW_VERSION} failed -- trying latest..."
        if uv pip install langflow 2>&1; then
            install_ok=true
        fi
    fi

    if [ "$install_ok" = false ]; then
        fail "Langflow installation failed. Check your internet connection and try again."
        popd >/dev/null || true
        return 1
    fi

    ok "Langflow installed"
    popd >/dev/null || true
    return 0
}

# ── Shortcut (platform-specific) ────────────────────────────────────────────

create_launcher() {
    local launcher_path="$LANGFLOW_DIR/start-langflow.sh"

    cat > "$launcher_path" << 'LAUNCHER'
#!/usr/bin/env bash
cd "$HOME/langflow" || exit 1
echo ""
echo " +==================================================+"
echo " +            Langflow Server Launcher              +"
echo " +--------------------------------------------------+"
echo " +  GitHub:  https://github.com/NikkiSatmaka/       +"
echo " +  LinkedIn: https://linkedin.com/in/nikkisatmaka/ +"
echo " +==================================================+"
echo ""
echo "Starting Langflow server..."
nohup uv run langflow run > /tmp/langflow-server.log 2>&1 &
L_PID=$!
echo "Server PID: $L_PID"
echo ""
echo "Waiting for Langflow to start..."
echo "The browser will open automatically when the server is ready."
echo "You can also manually visit http://127.0.0.1:7860 at any time."
echo ""
while true; do
    if curl -s -o /dev/null --max-time 2 "http://127.0.0.1:7860/health_check" 2>/dev/null; then
        break
    fi
    sleep 3
done
echo ""
echo " +==================================================+"
echo " +  Langflow server is ready!                       +"
echo " +  Opening browser...                              +"
echo " +==================================================+"
case "$(uname -s)" in
    Darwin) open "http://127.0.0.1:7860" ;;
    *)      xdg-open "http://127.0.0.1:7860" 2>/dev/null || true ;;
esac
echo ""
echo "Press Enter to close this terminal..."
read -r
LAUNCHER
    chmod +x "$launcher_path"
    echo "$launcher_path"
}

create_macos_shortcut() {
    local launcher_path="$1"
    local shortcut_path="$HOME/Desktop/Langflow.command"

    cat > "$shortcut_path" << EOF
#!/usr/bin/env bash
exec "${launcher_path}"
EOF
    chmod +x "$shortcut_path"
    printf "%s\n" "$shortcut_path"
}

create_linux_shortcut() {
    local launcher_path="$1"

    local desktop_path="$HOME/.local/share/applications/langflow.desktop"
    mkdir -p "$HOME/.local/share/applications"
    cat > "$desktop_path" << EOF
[Desktop Entry]
Name=Langflow
Comment=Langflow AI Platform (http://127.0.0.1:7860)
Exec=${launcher_path}
Terminal=true
Type=Application
Categories=Development;
EOF
    chmod +x "$desktop_path"

    if [ -d "$HOME/Desktop" ]; then
        local desktop_shortcut="$HOME/Desktop/langflow.desktop"
        cp "$desktop_path" "$desktop_shortcut"
        chmod +x "$desktop_shortcut"
        if command -v gio &>/dev/null; then
            gio set "$desktop_shortcut" metadata::trusted true 2>/dev/null || true
        fi
        printf "%s\n" "$desktop_shortcut"
    else
        printf "%s\n" "$desktop_path (no Desktop directory found)"
    fi
}

create_stop_shortcut() {
    local launcher_path="$LANGFLOW_DIR/stop-langflow.sh"
    local script_dir
    script_dir=$(cd "$(dirname "$0")" && pwd)

    cp "$script_dir/stop-langflow.sh" "$launcher_path"
    chmod +x "$launcher_path"

    local shortcut_path
    case "$OS" in
        Darwin)
            shortcut_path="$HOME/Desktop/Stop Langflow.command"
            cat > "$shortcut_path" << EOF
#!/usr/bin/env bash
exec "${launcher_path}"
EOF
            chmod +x "$shortcut_path"
            ;;
        *)
            local desktop_path="$HOME/.local/share/applications/stop-langflow.desktop"
            mkdir -p "$HOME/.local/share/applications"
            cat > "$desktop_path" << EOF
[Desktop Entry]
Name=Stop Langflow
Comment=Stop the Langflow server
Exec=${launcher_path}
Terminal=true
Type=Application
Categories=Development;
EOF
            chmod +x "$desktop_path"
            if [ -d "$HOME/Desktop" ]; then
                shortcut_path="$HOME/Desktop/stop-langflow.desktop"
                cp "$desktop_path" "$shortcut_path"
                chmod +x "$shortcut_path"
                if command -v gio &>/dev/null; then
                    gio set "$shortcut_path" metadata::trusted true 2>/dev/null || true
                fi
            else
                shortcut_path="$desktop_path (no Desktop directory found)"
            fi
            ;;
    esac

    ok "Stop shortcut created: ${shortcut_path}"
}

create_shortcut() {
    local launcher_path
    launcher_path=$(create_launcher)
    local shortcut_path

    case "$OS" in
        Darwin)
            shortcut_path=$(create_macos_shortcut "$launcher_path")
            ;;
        *)
            shortcut_path=$(create_linux_shortcut "$launcher_path")
            ;;
    esac

    ok "Desktop shortcut created: ${shortcut_path}"
}

# ── Install ─────────────────────────────────────────────────────────────────

start_install() {
    info "Starting installation..."
    printf "\n"

    install_uv || return
    install_python || return
    install_langflow_package || return
    create_shortcut
    create_stop_shortcut

    printf "\n"
    printf "${G}══════════════════════════════════════════════════${N}\n"
    ok "Langflow ${LANGFLOW_VERSION} installed"
    ok "Desktop shortcuts created"
    printf "${C} ➜  Double-click the Langflow shortcut to start${N}\n"
    printf "${C} ➜  Browser will open automatically at http://127.0.0.1:7860${N}\n"
    printf "${G}══════════════════════════════════════════════════${N}\n"
    printf "\n"
    read -r -p "$(printf "${C}Press Enter to continue...${N}")"
}

# ── Uninstall ───────────────────────────────────────────────────────────────

start_uninstall() {
    read -r -p "Remove Langflow and its virtual environment? [y/N] " confirm
    confirm=$(printf "%s" "$confirm" | tr '[:lower:]' '[:upper:]')
    if [ "$confirm" != "Y" ]; then
        info "Uninstall cancelled."
        read -r -p "$(printf "${C}Press Enter to continue...${N}")"
        return
    fi

    if [ -d "$LANGFLOW_DIR" ]; then
        info "Removing ${LANGFLOW_DIR}..."
        rm -rf "$LANGFLOW_DIR"
        ok "Langflow directory removed"
    else
        ok "Langflow directory not found -- nothing to remove"
    fi

    case "$OS" in
        Darwin)
            if [ -f "$HOME/Desktop/Langflow.command" ]; then
                rm -f "$HOME/Desktop/Langflow.command"
                ok "Desktop shortcut removed"
            fi
            if [ -f "$HOME/Desktop/Stop Langflow.command" ]; then
                rm -f "$HOME/Desktop/Stop Langflow.command"
                ok "Stop shortcut removed"
            fi
            ;;
        *)
            if [ -f "$HOME/.local/share/applications/langflow.desktop" ]; then
                rm -f "$HOME/.local/share/applications/langflow.desktop"
                ok "App menu entry removed"
            fi
            if [ -f "$HOME/.local/share/applications/stop-langflow.desktop" ]; then
                rm -f "$HOME/.local/share/applications/stop-langflow.desktop"
                ok "Stop app entry removed"
            fi
            if [ -f "$HOME/Desktop/langflow.desktop" ]; then
                rm -f "$HOME/Desktop/langflow.desktop"
                ok "Desktop shortcut removed"
            fi
            if [ -f "$HOME/Desktop/stop-langflow.desktop" ]; then
                rm -f "$HOME/Desktop/stop-langflow.desktop"
                ok "Stop desktop shortcut removed"
            fi
            ;;
    esac

    read -r -p "Remove Python 3.12 installed by uv? [y/N] " remove_py
    remove_py=$(printf "%s" "$remove_py" | tr '[:lower:]' '[:upper:]')
    if [ "$remove_py" = "Y" ]; then
        uv python uninstall 3.12 2>/dev/null || true
        ok "Python 3.12 removed"
    fi

    printf "\n"
    printf "${G}══════════════════════════════════════════════════${N}\n"
    ok "Langflow uninstalled"
    info "  uv was kept -- remove manually if desired:"
    info "    rm -rf ${UV_BIN_DIR}"
    printf "${G}══════════════════════════════════════════════════${N}\n"
    printf "\n"
    read -r -p "$(printf "${C}Press Enter to continue...${N}")"
}

# ── Main ────────────────────────────────────────────────────────────────────

main() {
    show_banner
    while true; do
        choice=$(show_menu)
        case "$choice" in
            I) start_install; show_banner ;;
            U) start_uninstall; show_banner ;;
            Q) exit 0 ;;
            *)
                warn "Invalid choice. Press [I], [U], or [Q]."
                printf "\n"
                ;;
        esac
    done
}

main
