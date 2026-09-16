# Changelog

## v1.11.1 (2026-09-16)

- feat: upgrade Langflow to 1.12.2 (patch release: dependency upgrades for the provider bundles and LangChain Community integrations, plus DB/migration, MCP, assistant, graph, and lfx fixes)
- docs: note that 1.12.2 resolves the identical transitive set as 1.12.1 (floor pins already pull `langflow-base==1.12.2`, `lfx==1.12.2`, `lfx-bundles==1.1.26`), so the pin bump only swaps the installer's `langflow` meta-package wheel

## v1.11.0 (2026-09-12)

- feat: bundle every non-PyTorch provider via `langflow[bundles,postgresql]==1.12.1`, collapsing `src/requirements.txt` to a single line (Composio is included inside `lfx-bundles[all-no-torch]`, so its separate pin was dropped; torch-requiring providers stay opt-in)
- docs: add ADR 0006 documenting the desktop/batteries-included intent that supersedes the docker-parity curated set

## v1.10.2 (2026-09-12)

- docs: document the bundled Composio integration (`lfx-bundles[composio]==1.1.23`, shipping `composio==0.16.0` and `composio-langchain==0.16.0`) in `src/requirements.txt`
- docs: update README, CONTRACT, AGENTS, ADR 0005, and landing page to reflect the bundled Composio bundle

## v1.10.1 (2026-09-11)

- feat: upgrade Langflow to 1.12.1 (Google GenAI, Ollama, Azure AI, and the rest of the curated `lfx-*` provider bundles are now default `langflow` dependencies, fixing missing Google GenAI components on fresh installs)
- refactor: collapse `src/requirements.txt` to just the pinned `langflow[postgresql]==1.12.1` line; the `langflow-base[google,ollama]` and `langchain-azure-ai` extras are redundant in 1.12 and were removed
- docs: update ADR 0005 to document the 1.12 bundle transition

## v1.10.0 (2026-09-06)

- feat: upgrade Langflow to 1.11.6
- feat: install the Google, Ollama, Azure AI, and PostgreSQL integrations from the official langflow Docker image via a new bundled `src/requirements.txt` (only the langflow line is pinned)
- feat: install from a versioned requirements file instead of a direct package argument; the version-pin fallback now strips the pin in place and keeps the same integrations
- refactor: use uv's canonical `--requirements=`/`--constraints=` flag names for consistency
- docs: add ADR 0005 documenting docker-parity requirements

## v1.9.8 (2026-08-31)

- feat: upgrade Langflow to 1.11.5 (security backports for SSRF, MCP hardening, code execution boundaries; bug fixes for memory, frontend, and CI)

## v1.9.7 (2026-08-22)

- feat: upgrade Langflow to 1.11.4 (MCP SDK backport pin, FastAPI range restore, dependency security floors)
- fix: friendlier first-launch wait messages in server launchers (varied progress updates every minute with elapsed time instead of identical lines every 5 seconds)
- fix: realistic wait expectations for slow machines (intro box states up to 10-15 minutes; manual-URL hint removed from mid-wait messages, one-time log pointer after 15 minutes)
- docs: friendlier landing page copy (hero star ask, first-start expectations in run steps, timing tips per OS tab)
- docs: surface the troubleshooting guide prominently (always-visible Need-help button plus common-issues cards deep-linking each symptom)
- docs: open troubleshooting links in a new tab
- chore: bump uv to 0.12.5

## v1.9.6 (2026-08-13)

- feat: upgrade Langflow to 1.11.3
- chore: drop litellm wheel build and constraint (litellm 1.96.2 ships pre-built wheels on all platforms)

## v1.9.5 (2026-08-07)

- fix: pass the uv constraints file by a space-free relative name (uv truncates `--constraint` paths on whitespace, astral-sh/uv#12639; previously broke installs on profiles with spaces in the path)
- ci: run the real installer from a directory containing a space to regression-test constraint handling

## v1.9.4 (2026-08-05)

- feat: upgrade Langflow to 1.11.2
- fix: improve install failure error message to point to issue tracker

## v1.9.3 (2026-08-04)

- fix: handle spaces in paths on Windows

## v1.9.2 (2026-08-04)

- feat: run the actual install scripts in CI (replaces the manual uv install in the constraint test)
- fix: pause on install failure so users can screenshot the error before returning to the menu
- fix: quote Exec= and Icon= paths in Linux .desktop files (supports usernames with spaces)

## v1.9.1 (2026-08-03)

- fix: pass constraints as separate args to uv on Windows

## v1.9.0 (2026-08-02)

- feat: upgrade Langflow to 1.11.1
- feat: fetch `uv-install.ps1` from upstream at package time (no longer committed to repo)
- feat: add constraint-test CI workflow with build-tool removal on all OSes
- fix: bundle a CI-built litellm macOS wheel in the release zip (litellm >=1.93 ships no macOS wheels)
- chore: pin litellm==1.95.0 in constraints.txt
- feat: rename Langflow server window to "Langflow Server - KEEP OPEN" to prevent accidental closes
- feat: highlight post-install next steps and exit the installer after install/uninstall

## v1.8.2 (2026-07-31)

- hotfix: remove constraints for fastapi

## v1.8.1 (2026-07-28)

- fix: add constraints for fastapi, crypotgraphy, pypdfium2

## v1.8.0 (2026-07-23)

- feat: upgrade Langflow from 1.10.2 to 1.10.3

## v1.7.0 (2026-07-17)

- feat: rename desktop launcher to Langflow Web (distinct from other Langflow shortcuts)
- feat: bundle Langflow icon and apply to launch shortcuts (Windows .ico, Linux .desktop Icon=)
- docs: update docs and landing page for Langflow Web shortcut
- docs: add troubleshooting entries for PyTorch/vcredist and Langflow cache

## v1.6.3 (2026-07-15)

- fix: pin litellm<1.92.0 to avoid Rust build requirement on Windows/macOS

## v1.6.2 (2026-07-14)

- fix: use ${PythonVersion} to prevent drive-qualified parse error

## v1.6.1 (2026-07-14)

- fix: use ${_} syntax in PowerShell scripts to prevent parser error

## v1.6.0 (2026-07-08)

- feat: macOS and Linux installer (cross-platform support)
- feat: cross-platform landing page with OS tabs
- feat: double-click stop launchers for all platforms
- feat: desktop stop shortcut created during installation
- feat: Python version variable for easier future migration
- feat: print waiting status every 5s in macOS/Linux launcher
- fix: redirect menu display to stderr so choice capture works
- fix: banner alignment (off-by-1 on the title line)
- fix: kill Langflow immediately in stop script (no grace period)
- fix: add checkout step to release workflow
- fix: produce both versioned and unversioned zips in packaging scripts
- docs: GATEKEEPER.md with detailed macOS bypass guide
- docs: update landing page Gatekeeper tip with correct instructions
- chore: update bundled uv from 0.11.23 to 0.11.28
- chore: add CI/CD workflows (verify + release automation)
- chore: add packaging scripts under scripts/
- chore: add verify.sh pre-commit verification (10 checks)

## v1.5.0 (2026-07-08)
- feat: update Langflow from 1.10.1 to 1.10.2

## v1.4.0 (2026-06-25)
- feat: update Langflow from 1.9.6 to 1.10.1
- docs: replace ASCII banner with badges in README, update docs for v1.4.0

## v1.3.0 (2026-06-25)
- feat: add GitHub Pages landing page (`docs/index.html`) for non-technical users
- feat: replace fixed 30s timeout with server-ready polling in launcher
- feat: redesign credits banner to match landing page theme
- fix: use `/health_check` endpoint with variable-free PowerShell command (fixes server detection bug)
- fix: replace upload arrow with download arrow in landing page button
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
