# Changelog

## v1.3.0 (2026-06-25)
- feat: add GitHub Pages landing page (`docs/index.html`) for non-technical users
- feat: replace fixed 30s timeout with server-ready polling in launcher
- feat: redesign credits banner to match landing page theme
- docs: add landing page, consistent zip name, and launcher changes to docs
- chore: push and release v1.3.0

## v1.2.0 (2026-06-25)
- refactor: reorganize repo into `src/` and `docs/` directories
- chore: move `CHANGELOG.md` back to repo root
- docs: fix release zip structure to mirror repo layout (`src/` subdirectory)

## v1.1.11 (2026-06-24)
- feat: make menu prompt explicitly say to type I/U/Q and press Enter
- feat: add pre-launch notice about new minimized terminal window in launcher
- feat: start Langflow Server window minimized to avoid accidental close

## v1.1.10 (2026-06-24)
- fix: replace pipe `|` with `+` in launcher box borders to avoid batch parse error

## v1.1.9 (2026-06-24)
- fix: replace Unicode box-drawing with ASCII-compatible `+-|` characters in launcher

## v1.1.8 (2026-06-24)
- fix: add `chcp 65001` and restore box-drawing characters in launcher (reverted in v1.1.9)

## v1.1.7 (2026-06-24)
- fix: detect `uv pip install` failure via `$LASTEXITCODE` instead of broken `try/catch`

## v1.1.6 (2026-06-24)
- fix: replace Unicode box-drawing characters with ASCII in launcher to avoid codepage corruption

## v1.1.5 (2026-06-24)
- feat: add credits banner and keep-window warning to server launcher

## v1.1.4 (2026-06-24)
- feat: bundle `uv-install.ps1` (eliminates `irm | iex` AV trigger)
- feat: rename `.ps1` and `.bat` for clarity (`Install Langflow.bat`, `install-langflow-script.ps1`)

## v1.1.3 (2026-06-23)
- feat: increase launcher timeout from 10s to 30s
- docs: add usage notes to README (keep terminal open, wait and refresh)

## v1.1.2 (2026-06-23)
- fix: replace direct `uv.exe` shortcut with launcher batch file that opens browser automatically

## v1.1.1 (2026-06-23)
- fix: add UTF-8 BOM for Windows PowerShell encoding compatibility

## v1.1.0 (2026-06-22)
- chore: pin Python 3.12 instead of 3.13

## v1.0.0 (2026-06-22)
- feat: initial release — Langflow 1.9.6 Windows installer via `uv`
