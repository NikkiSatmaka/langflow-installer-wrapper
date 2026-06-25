# AGENTS.md — IBM Hacktiv8 / Langflow Installer for Windows

## Project Overview

This repository provides a PowerShell wrapper script (`install-langflow-script.ps1`) and companion batch launcher (`Install Langflow.bat`) to install Langflow on Windows using `uv` as the package manager. Python 3.12 is pinned. Langflow is pinned to version **1.9.6**.

**Author**: Nikki Satmaka
- GitHub: https://github.com/NikkiSatmaka/
- LinkedIn: https://linkedin.com/in/nikkisatmaka/

## Repository Structure (root only)

| File | Purpose |
|------|---------|
| `AGENTS.md` | This file — agent guidance |
| `CONTRACT.md` | Formal requirements specification |
| `Install Langflow.bat` | Double-click launcher that bypasses execution policy |
| `README.md` | This file — for humans |
| `CHANGELOG.md` | Release history |
| `src/install-langflow-script.ps1` | Main PowerShell installer/uninstaller script |
| `src/uv-install.ps1` | Bundled uv bootstrapper (official script from astral.sh) — eliminates `irm \| iex` AV trigger |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes |

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
| Bundled `uv-install.ps1` | Eliminates `irm \| iex` pattern that heuristic AV triggers on; uses `$PSScriptRoot` to reference local file |
| Release zip structure | `Install Langflow.bat` and `LICENSE` at zip root; `install-langflow-script.ps1` and `uv-install.ps1` under `src/` — mirrors repo layout |

## Conventions

- **PowerShell style**: Verb-Noun naming, `$true`/`$false`, `-ErrorAction Stop`, `Write-Host` for user output
- **Error handling**: try/catch with clear messages; non-fatal errors allow script to continue
- **Banner**: box-drawing characters with ANSI colors (if available), preserved as-is
- **Documentation**: markdown (this file and CONTRACT.md)

## Security Rules

- Never hardcode API keys, tokens, or secrets
- Avoid `Invoke-Expression` on user-controlled or untrusted input
- The `irm ... | iex` pattern is **not used** — the uv bootstrapper is bundled as `uv-install.ps1` and invoked via `& "$PSScriptRoot\uv-install.ps1"`

## Commit Rules

- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`
- **Atomic commits**: Each commit must represent one logical change. Do not bundle unrelated changes together.
- Reference CONTRACT.md sections when implementing requirements

## Git Workflow

- Do **not push** to remote until explicitly instructed by the user
- Do **not create a release** or tag until explicitly instructed by the user

## Version Bumping

| Commit type | Version bump |
|-------------|-------------|
| `fix:` | patch (v1.1.8 → v1.1.9) |
| `feat:` | minor (v1.1.8 → v1.2.0) |
| `docs:` / `chore:` | no release |
| `fix!:` or `feat!:` | major (v1.1.8 → v2.0.0) |

## Verification

Before committing, run these checks:
- **Braces balanced**: `rg -F '{' install-langflow-script.ps1 | wc -l` equals `rg -F '}' install-langflow-script.ps1 | wc -l`
- **No irm | iex**: confirm the pattern does not exist in the .ps1 file
- **Docs up to date**: AGENTS.md and CONTRACT.md reflect any behavior changes
- **No secrets or absolute paths** in the diff
- **Encoding correct**: batch files use ASCII; .ps1 files are UTF-8 with BOM
