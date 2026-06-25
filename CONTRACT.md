# CONTRACT.md — Langflow Windows Installer Specification

## 1. Purpose

Provide a single-click (or double-click) solution for Windows users to install, run, and uninstall Langflow (`==1.9.6`) using `uv` as the package manager, with no administrative privileges required.

## 2. Credits & Attribution

Every script invocation **must** display a banner with the author's handles before any user prompt or action.

```
╔══════════════════════════════════════════════════╗
║            Langflow Installer for Windows        ║
║──────────────────────────────────────────────────║
║  GitHub:  https://github.com/NikkiSatmaka/       ║
║  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ║
╚══════════════════════════════════════════════════╝
```

- ANSI color support is optional but preferred for terminals that support it.
- The banner must use box-drawing characters (Unicode U+2554–255D) as shown.

## 3. Entry Point Behaviour

The script **must** clear the screen, print the banner, then present a simple menu:

```
[I]nstall Langflow
[U]ninstall Langflow
[Q]uit
```

- Input is case-insensitive.
- Any other input re-prompts.
- `[Q]` exits immediately with code 0.

## 4. Install Flow

Run when the user selects `[I]`.

### 4.1 uv Installation

1. Check if `uv` is on `$env:PATH`.
2. If not found:
   - Run the bundled `uv-install.ps1` via `& "$PSScriptRoot\uv-install.ps1"`.
   - After the installer completes, add `%USERPROFILE%\.local\bin` to the **permanent user PATH** via `[Environment]::SetEnvironmentVariable('Path', ..., 'User')`.
3. Refresh the in-session `$env:PATH` to include the new entry immediately.
4. Verify `uv --version` succeeds. If it fails, print a clear error and abort install.

### 4.2 Python 3.12

1. Run `uv python install 3.12` (downloads prebuilt CPython, no admin needed).
2. Run `uv python pin 3.12` inside the working directory (see 4.3).
3. If 3.12 is already installed, the command is a no-op (uv handles this).

### 4.3 Virtual Environment & Langflow

1. Create `%USERPROFILE%\langflow\` directory if it does not exist.
2. `cd %USERPROFILE%\langflow`
3. Create venv: `uv venv` (creates `.venv`).
4. Install Langflow: `uv pip install langflow==1.9.6`.
   - If the pin fails (e.g., version yanked), catch the error and suggest `uv pip install langflow` without the pin as a fallback.

### 4.4 Desktop Shortcut

1. Resolve the desktop path via `[Environment]::GetFolderPath('Desktop')`.
2. Create a `.lnk` file named `Langflow.lnk` using `WScript.Shell` COM:
   - **Target**: The `run-langflow.bat` launcher created in `%USERPROFILE%\langflow\`.
   - **Target (actual)**: `TargetPath` points to `%USERPROFILE%\langflow\run-langflow.bat`, which runs `uv run langflow run` and opens the browser.
   - **Working directory**: `%USERPROFILE%\langflow`
   - **Window style**: Normal (1)
   - **Description**: `Langflow AI Platform (http://127.0.0.1:7860)`
3. If `WScript.Shell` is unavailable (stripped Windows N/KN), catch and print the shortcut path so the user can create it manually.

### 4.5 Completion

Print a success summary:

```
✓ Langflow 1.9.6 installed
✓ Desktop shortcut created: %USERPROFILE%\Desktop\Langflow.lnk
➜ Double-click the shortcut to start Langflow
➜ Browser opens automatically at http://127.0.0.1:7860
```

## 5. Uninstall Flow

Run when the user selects `[U]`.

1. Confirm: `Are you sure? [y/N]`
   - Defaults to `N` on empty input.
2. Remove `%USERPROFILE%\langflow\` (recursive, if it exists).
3. Remove `%USERPROFILE%\Desktop\Langflow.lnk` (if it exists).
4. Ask: `Remove Python 3.12 installed by uv? [y/N]`
   - If `Y`, run `uv python uninstall 3.12`.
5. **Do not** remove `uv` or `%USERPROFILE%\.local\bin\` — uv may be used for other projects.
6. Print: `✓ Langflow uninstalled`

## 6. Non-Functional Requirements

| Requirement | Specification |
|-------------|---------------|
| Admin privileges | None required at any step |
| Idempotency | Re-running the installer overwrites nothing unexpectedly; re-checks every dependency |
| Error resilience | Non-fatal errors (e.g., shortcut creation) print a warning and continue. Fatal errors (uv install fail, Python install fail) abort with a clear message |
| Progress visibility | Long operations (`uv pip install langflow`) should print stdout so user sees download progress |
| PATH persistence | The `%USERPROFILE%\.local\bin` PATH entry persists across reboots via `[Environment]::SetEnvironmentVariable` |
| Portability | All operations use `%USERPROFILE%` — works on Windows 10 and 11 regardless of drive letter |
| File encoding | `install-langflow-script.ps1` must be saved as **UTF-8 with BOM** to ensure Windows PowerShell correctly parses non-ASCII characters (box-drawing, em dashes, check marks, etc.) |
| Bundled uv installer | `uv-install.ps1` is shipped in the release zip; the script references it via `$PSScriptRoot` instead of using `irm \| iex` |
| Minimal release assets | GitHub release `.zip` must contain exactly `Install Langflow.bat` and `LICENSE` at zip root, with `install-langflow-script.ps1` and `uv-install.ps1` under a `src/` subdirectory. No other repository files. |
| Landing page download | Each release also uploads `langflow-installer-win.zip` (same contents as versioned zip, consistent name). Download link on the landing page never needs updating across versions. |

## 7. Known Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| PowerShell execution policy blocks `.ps1` | Ship `Install Langflow.bat` that calls the script with `-ExecutionPolicy Bypass` |
| PATH not refreshed after uv install | Read permanent PATH from registry into current session explicitly |
| Langflow download is large (~300MB) | Stream uv pip output; print "This may take a few minutes..." beforehand |
| Port 7860 conflict | Document in completion message; user can configure via `.env` |
| langflow==1.9.6 yanked on PyPI | Catch the pip error and suggest removing the version pin |
| WScript.Shell missing on N/KN editions | Catch COM error and print manual shortcut instructions |
| Antivirus flags `irm \| iex` pattern | Bundle `uv-install.ps1` in the release zip; invoke via `& "$PSScriptRoot\uv-install.ps1"` instead of downloading at runtime |
| uv binary not on PATH after install | Explicitly add `%USERPROFILE%\.local\bin` to permanent PATH in script |

## 8. Out of Scope

- Upgrading Langflow (user runs `uv pip install langflow -U` manually)
- Installing system-wide Python or modifying system PATH
- Docker-based Langflow deployment
- Langflow Desktop (standalone GUI app) — this installs the OSS Python package only
- Creating a Start Menu entry or taskbar pinning
