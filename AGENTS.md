# AGENTS.md — IBM Hacktiv8 / Langflow Installer for Windows

## Project Overview

This repository provides a PowerShell wrapper script (`install-langflow.ps1`) and companion batch launcher (`install-langflow.bat`) to install Langflow on Windows using `uv` as the package manager. Python 3.12 is pinned. Langflow is pinned to version **1.9.6**.

**Author**: Nikki Satmaka
- GitHub: https://github.com/NikkiSatmaka/
- LinkedIn: https://linkedin.com/in/nikkisatmaka/

## Repository Structure (root only)

| File | Purpose |
|------|---------|
| `AGENTS.md` | This file — agent guidance |
| `CONTRACT.md` | Formal requirements specification |
| `install-langflow.ps1` | Main PowerShell installer/uninstaller script |
| `install-langflow.bat` | Double-click launcher that bypasses execution policy |

## Design Constraints

- **No admin rights required** — everything installs under `%USERPROFILE%`
- **Idempotent** — safe to re-run; checks before acting
- **User-prompted** — script asks Install / Uninstall / Quit at startup
- **Credits banner** — GitHub + LinkedIn displayed on every run (Chris Titus style)
- **Version pinned** — Langflow `==1.9.6`; do not change without updating CONTRACT.md
- **Python pinned** — 3.12 via `uv python install 3.12`

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| `uv` over `pip` | Faster, self-bootstrapping, no pre-installed Python needed |
| `%USERPROFILE%\.local\bin` added to permanent PATH | uv installer puts binaries there; script ensures it persists |
| `WScript.Shell` COM for shortcut | Standard Windows method, no external deps |
| Desktop shortcut targets `uv run langflow run` | Works regardless of active venv state |
| Uninstall keeps `uv` | uv may be used for other projects |
| UTF-8 BOM required on `.ps1` | Windows PowerShell requires UTF-8 with BOM; without it, non-ASCII characters cause parser errors |
| Release zip contains only 3 files | `install-langflow.ps1` (UTF-8 with BOM), `install-langflow.bat`, `LICENSE` — no other repo files |

## Conventions

- **PowerShell style**: Verb-Noun naming, `$true`/`$false`, `-ErrorAction Stop`, `Write-Host` for user output
- **Error handling**: try/catch with clear messages; non-fatal errors allow script to continue
- **Banner**: box-drawing characters with ANSI colors (if available), preserved as-is
- **Documentation**: markdown (this file and CONTRACT.md)

## Security Rules

- Never hardcode API keys, tokens, or secrets
- Avoid `Invoke-Expression` on user-controlled or untrusted input
- The `irm ... | iex` pattern is only used for the official `astral.sh/uv/install.ps1` script

## Commit Rules

- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`
- Keep commits scoped to one logical change
- Reference CONTRACT.md sections when implementing requirements
