# CONTRACT.md — Langflow Windows/macOS/Linux Installer Specification

## 1. Purpose

Provide a single-click (or double-click) solution for users to install, run, and uninstall Langflow (`==1.10.2`) using `uv` as the package manager on Windows, macOS, and Linux — with no administrative privileges required on any platform.

## 2. Credits & Attribution

Every script invocation **must** display a banner with the author's handles before any user prompt or action.

```
╔══════════════════════════════════════════════════╗
║                Langflow Installer                ║
║──────────────────────────────────────────────────║
║  GitHub:  https://github.com/NikkiSatmaka/       ║
║  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ║
╚══════════════════════════════════════════════════╝
```

The banner text is the same across all platforms: `Langflow Installer`.

- ANSI color support is optional but preferred for terminals that support it.
- The banner must use box-drawing characters (Unicode U+2554–255D) as shown.

## 3. Entry Point Behaviour (all platforms)

The script **must** clear the screen, print the banner, then present a simple menu:

```
[I]nstall Langflow
[U]ninstall Langflow
[Q]uit
```

- Input is case-insensitive.
- Any other input re-prompts.
- `[Q]` exits immediately with code 0.

## 4. Platform Entry Points

| Platform | Launcher file | Main script | Mechanism |
|----------|--------------|-------------|-----------|
| Windows | `Install Langflow.bat` | `src/install-langflow-script.ps1` | Batch calls PowerShell with `-ExecutionPolicy Bypass` |
| macOS | `Install Langflow.command` | `src/install-langflow.sh` | `.command` file opens Terminal, runs bash script |
| Linux | `Install Langflow.sh` | `src/install-langflow.sh` | Run via terminal: `bash Install Langflow.sh` |

## 5. Install Flow (all platforms)

Run when the user selects `[I]`.

### 5.1 uv Installation

1. Check if `uv` is on PATH.
2. If not found:
   - **Windows**: Run the bundled `uv-install.ps1` via `& "$PSScriptRoot\uv-install.ps1"`. After the installer completes, add `%USERPROFILE%\.local\bin` to the **permanent user PATH** via `[Environment]::SetEnvironmentVariable('Path', ..., 'User')`.
   - **macOS/Linux**: Run `curl -LsSf https://astral.sh/uv/install.sh | sh`. Add `~/.local/bin` to `~/.profile`.
3. Refresh the in-session PATH to include the new entry immediately.
4. Verify `uv --version` succeeds. If it fails, print a clear error and abort install.

### 5.2 Python 3.12

1. Run `uv python install 3.12` (downloads prebuilt CPython, no admin needed).
2. Run `uv python pin 3.12` inside the working directory (see 5.3).
3. If 3.12 is already installed, the command is a no-op (uv handles this).

### 5.3 Virtual Environment & Langflow

1. Create the langflow directory:
   - **Windows**: `%USERPROFILE%\langflow\`
   - **macOS/Linux**: `~/langflow/`
2. `cd` into the langflow directory.
3. Create venv: `uv venv` (creates `.venv`).
4. Install Langflow: `uv pip install langflow==1.10.2`.
   - If the pin fails (e.g., version yanked), catch the error and suggest `uv pip install langflow` without the pin as a fallback.

### 5.4 Desktop Shortcuts

Two shortcuts are created: one to start Langflow, one to stop it.

**Start shortcut:**
- **Windows**: Create `Langflow Web.lnk` using `WScript.Shell` COM pointing to `run-langflow.bat`. Set `IconLocation` to the bundled `langflow.ico`. If COM is unavailable, print the shortcut path for manual creation.
- **macOS**: Create `~/Desktop/Langflow Web.command` that executes the launcher script. Make it executable with `chmod +x`. The `.command` keeps the default Finder icon by design.
- **Linux**: Create `langflow.desktop` at `~/.local/share/applications/` (with `Name=Langflow Web` and `Icon=` pointing at the bundled `langflow.png`) and copy to `~/Desktop/`. On GNOME, mark as trusted via `gio set metadata::trusted true`.

**Stop shortcut:**
- **Windows**: Create `Stop Langflow.lnk` pointing to `stop-langflow-script.ps1`.
- **macOS**: Create `~/Desktop/Stop Langflow.command` that executes the stop script. Make it executable with `chmod +x`.
- **Linux**: Create `stop-langflow.desktop` at `~/.local/share/applications/` and copy to `~/Desktop/`. Mark as trusted on GNOME.

All platforms also create a launcher script in the langflow directory:
- **Windows**: `%USERPROFILE%\langflow\run-langflow.bat`
- **macOS/Linux**: `~/langflow/start-langflow.sh`

### 5.5 Completion

Print a platform-appropriate success summary:

```
✓ Langflow 1.10.2 installed
✓ Desktop shortcut created: <path>
➜ Double-click the shortcut to start Langflow
➜ Browser opens automatically at http://127.0.0.1:7860
```

## 6. Uninstall Flow (all platforms)

Run when the user selects `[U]`.

1. Confirm: `Are you sure? [y/N]`
   - Defaults to `N` on empty input.
2. Remove the langflow directory:
   - **Windows**: `%USERPROFILE%\langflow\` (recursive)
   - **macOS/Linux**: `~/langflow/` (recursive)
3. Remove desktop shortcuts (start and stop):
   - **Windows**: `%USERPROFILE%\Desktop\Langflow Web.lnk` and `%USERPROFILE%\Desktop\Stop Langflow.lnk`
   - **macOS**: `~/Desktop/Langflow Web.command` and `~/Desktop/Stop Langflow.command`
   - **Linux**: `~/.local/share/applications/langflow.desktop`, `~/Desktop/langflow.desktop`, `~/.local/share/applications/stop-langflow.desktop`, and `~/Desktop/stop-langflow.desktop`
4. Ask: `Remove Python 3.12 installed by uv? [y/N]`
   - If `Y`, run `uv python uninstall 3.12`.
5. **Do not** remove `uv` or its bin directory — uv may be used for other projects.
6. Print: `✓ Langflow uninstalled`

## 7. Non-Functional Requirements

| Requirement | Specification |
|-------------|---------------|
| Admin privileges | None required at any step on any platform |
| Idempotency | Re-running the installer overwrites nothing unexpectedly; re-checks every dependency |
| Error resilience | Non-fatal errors (e.g., shortcut creation) print a warning and continue. Fatal errors (uv install fail, Python install fail) abort with a clear message |
| Progress visibility | Long operations (`uv pip install langflow`) should print stdout so user sees download progress |
| PATH persistence | Windows: Registry via `[Environment]::SetEnvironmentVariable`. macOS/Linux: `~/.profile` |
| Portability | All operations use `%USERPROFILE%` (Windows) or `$HOME` (macOS/Linux) |
| File encoding (Windows) | `install-langflow-script.ps1` must be saved as **UTF-8 with BOM** to ensure Windows PowerShell correctly parses non-ASCII characters |
| Bundled uv installer | Windows bundles `uv-install.ps1` to avoid `irm \| iex` AV triggers. macOS/Linux use `curl \| sh` from the official astral.sh URL |
| Release assets | Three per-platform zips: `langflow-installer-win.zip`, `langflow-installer-macos.zip`, `langflow-installer-linux.zip`. Each contains only the files needed for that platform |
| Landing page download | `langflow-installer-win.zip` URL stays consistent. macOS and Linux zips have their own URLs |
| Python version rationale | Pin 3.12 — the latest version with pre-built wheels for all C-extension dependencies. 3.13+ requires building from source |

## 8. Known Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| PowerShell execution policy blocks `.ps1` (Windows) | Ship `Install Langflow.bat` that calls the script with `-ExecutionPolicy Bypass` |
| PATH not refreshed after uv install | Read permanent PATH explicitly; on macOS/Linux add to `~/.profile` and re-source |
| Langflow download is large (~300MB) | Stream uv pip output; print "This may take a few minutes..." beforehand |
| Port 7860 conflict | Document in completion message; user can configure via `.env` |
| langflow==1.10.2 yanked on PyPI | Catch the pip error and suggest removing the version pin |
| WScript.Shell missing on N/KN editions (Windows) | Catch COM error and print manual shortcut instructions |
| Antivirus flags `irm \| iex` pattern (Windows) | Bundle `uv-install.ps1` in the release zip; invoke via `& "$PSScriptRoot\uv-install.ps1"` instead of downloading at runtime |
| uv binary not on PATH after install | Explicitly add to PATH in script |
| macOS quarantine warning for `.command` files | Document System Settings > Privacy & Security > Open Anyway flow, with a dedicated guide at `docs/GATEKEEPER.md` |
| Linux desktop shortcut not trusted | Use `gio set metadata::trusted true` for GNOME |

## 9. Out of Scope

- Upgrading Langflow (user runs `uv pip install langflow -U` manually)
- Installing system-wide Python or modifying system PATH
- Docker-based Langflow deployment
- Langflow Desktop (standalone GUI app) — this installs the OSS Python package only
- Platform-specific packaging (`.msi`, `.dmg`, `.deb`, `.rpm`)
- Creating signed macOS `.app` bundles or Windows code signing
