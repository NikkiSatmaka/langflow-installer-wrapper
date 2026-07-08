# AGENTS.md — IBM Hacktiv8 / Langflow Installer for Windows, macOS, and Linux

## Project Overview

This repository provides single-click installers for Langflow on Windows, macOS, and Linux using `uv` as the package manager. Python 3.12 is pinned. Langflow is pinned to version **1.10.2**.

**Author**: Nikki Satmaka
- GitHub: https://github.com/NikkiSatmaka/
- LinkedIn: https://linkedin.com/in/nikkisatmaka/

## Repository Structure (root only)

| File | Purpose |
|------|---------|
| `AGENTS.md` | This file — agent guidance |
| `CONTRACT.md` | Formal requirements specification |
| `Install Langflow.bat` | Double-click launcher that bypasses execution policy (Windows) |
| `Install Langflow.command` | Double-click launcher (macOS) |
| `Install Langflow.sh` | Launcher (Linux) |
| `README.md` | This file — for humans |
| `CHANGELOG.md` | Release history |
| `src/install-langflow-script.ps1` | Main PowerShell installer/uninstaller script (Windows) |
| `src/install-langflow.sh` | Main bash installer/uninstaller script (macOS/Linux) |
| `src/uv-install.ps1` | Bundled uv bootstrapper (official script from astral.sh) — eliminates `irm \| iex` AV trigger (Windows only) |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes |
| `docs/index.html` | Landing page for non-GitHub users (GitHub Pages) — published at `https://nikkisatmaka.github.io/langflow-installer-wrapper/` |

## Design Constraints

- **No admin rights required** — everything installs under `%USERPROFILE%`
- **Idempotent** — safe to re-run; checks before acting
- **User-prompted** — script asks Install / Uninstall / Quit at startup
- **Credits banner** — GitHub + LinkedIn displayed on every run (Chris Titus style)
- **Version pinned** — Langflow `==1.10.2`; do not change without updating CONTRACT.md
- **Cross-platform** — Windows (PowerShell), macOS, and Linux (bash); platform-specific logic with shared installer flow
- **Python pinned** — 3.12 via `uv python install 3.12` (only version with pre-built wheels for all C-extensions on Windows; 3.13+ requires MSVC not available to most users)

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
| Consistent zip name for landing page | `langflow-installer-win.zip` uploaded alongside each versioned zip; landing page download link never needs updating |

## Conventions

- **PowerShell style**: Verb-Noun naming, `$true`/`$false`, `-ErrorAction Stop`, `Write-Host` for user output
- **Error handling**: try/catch with clear messages; non-fatal errors allow script to continue
- **Banner**: box-drawing characters with ANSI colors (if available), preserved as-is
- **Documentation**: markdown (this file and CONTRACT.md)
- **Bash style**: `set -euo pipefail`, `command -v` for existence checks, POSIX-friendly where feasible

## Security Rules

- Never hardcode API keys, tokens, or secrets
- Avoid `Invoke-Expression` on user-controlled or untrusted input
- The `irm ... | iex` pattern is **not used** — the uv bootstrapper is bundled as `uv-install.ps1` and invoked via `& "$PSScriptRoot\uv-install.ps1"`

## Commit Rules

- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`
- **Atomic commits**: Each commit must represent one logical change. Do not bundle unrelated changes together.
- Reference CONTRACT.md sections when implementing requirements
- PR titles follow the same `<type>: <description>` format as commits

## Git Workflow

This project uses **GitHub Flow**:

- `main` — always deployable, reflects the latest released state
- Feature branches off `main` — short-lived, deleted after merge
- All changes land via Pull Request — no direct commits to `main`
- The agent may push feature branches and open (draft) PRs freely
- The user reviews, approves, and squash-merges the PR
- The agent must never push to `main` or create releases/tags without explicit instruction

## Branch Naming

Use semantic prefixes with kebab-case descriptions:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New feature or upgrade | `feat/upgrade-langflow-1-10-2` |
| `fix/` | Bug fix | `fix/utf8-bom-regression` |
| `docs/` | Documentation only | `docs/add-troubleshooting-section` |
| `refactor/` | Code restructuring | `refactor/extract-shortcut-logic` |
| `chore/` | Maintenance, tooling | `chore/update-verification-commands` |

Branch from `main`, open a PR, squash merge, delete branch. Keep branches short-lived (days, not weeks).

## Pull Request Workflow

1. Create a feature branch from `main` with a semantic name.
2. Make atomic commits with conventional commit messages.
3. Open a PR against `main`. Use a draft PR if the work is in progress.
4. PR title format: `<type>: <short description>` (e.g., `feat: upgrade Langflow to 1.10.2`).
5. PR description should explain **what** and **why**, not **how**.
6. Self-review the diff before marking the PR ready.
7. The user reviews, approves, and **squash merges** into `main` — this keeps main history linear and atomic.
8. Delete the feature branch after merge.
9. Update `CHANGELOG.md` as part of the PR (not a separate commit).

## Release Process

### Step-by-step

1. Ensure `main` has the changes merged and verified.
2. Update `$ScriptVersion` in `src/install-langflow-script.ps1` if the script itself changed.
3. Update `CHANGELOG.md` with the new version, date, and entries.
4. Update `README.md` and `docs/index.html` if the hero message or version number changed.
5. Run all verification checks (see Verification section).
6. Commit with message: `docs: update changelog for vX.Y.Z`.
7. Tag the commit: `git tag vX.Y.Z`.
8. Push tag and main: `git push origin main --tags`.
9. Create a GitHub Release from the tag.
10. Upload **three** zips to the release:
    - `langflow-installer-vX.Y.Z.zip` — versioned, for release history (contains all three platform zips, or pick one representative zip)
    - `langflow-installer-win.zip` — consistent name (replaces previous), used by the landing page download link
    - `langflow-installer-macos.zip` — macOS installer
    - `langflow-installer-linux.zip` — Linux installer
11. Confirm `langflow-installer-win.zip` is attached (landing page download link).

### Zip contents

Each zip contains platform-specific files only:

**`langflow-installer-win.zip` / `langflow-installer-vX.Y.Z.zip`:**
- `Install Langflow.bat` (root)
- `LICENSE` (root)
- `src/install-langflow-script.ps1`
- `src/uv-install.ps1`

**`langflow-installer-macos.zip`:**
- `Install Langflow.command` (root)
- `LICENSE` (root)
- `src/install-langflow.sh`

**`langflow-installer-linux.zip`:**
- `Install Langflow.sh` (root)
- `LICENSE` (root)
- `src/install-langflow.sh`

Landing page download URLs (never changes across versions):
- Windows: `https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip`
- macOS: `https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip`
- Linux: `https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-linux.zip`

## How to Bump Langflow Version

Update files in this order:

1. **Single source of truth**: change `$LangflowVersion` in `src/install-langflow-script.ps1`.
   - Update `LANGFLOW_VERSION` in `src/install-langflow.sh` to match.
2. Update plain-text references in these files to match:
2. Update plain-text references in these files to match:
   - `README.md` (hero line + what-it-does list)
   - `CONTRACT.md` (purpose + install step)
   - `AGENTS.md` (project overview + design constraints)
   - `docs/index.html` (hero + what-it-does list)
3. Run verification checks to confirm all references are consistent.
4. If the new Langflow version has pre-built wheels for Python 3.12, no Python version change needed. Otherwise reassess the Python pin in `CONTRACT.md` section 6.

## Smoke Testing

This project has no automated tests. Before releasing, manually verify:

- Run the script in a Windows VM or clean environment (no pre-installed Python).
- Test all 3 menu paths: Install, Uninstall, Quit.
- Confirm Install is idempotent (re-running detects existing components).
- Confirm the desktop shortcut launches Langflow and the browser opens.
- Confirm `uv pip install langflow==<new version>` succeeds on the pinned Python 3.12.
- Confirm Uninstall removes `%USERPROFILE%\langflow\` and the shortcut, and optionally Python 3.12.

## Skills

These existing skills are useful for this project. Load them via the `skill()` tool when the task matches:

| Skill | When to use |
|-------|-------------|
| `code-review` | Before merging a PR — reviews changes against AGENTS.md conventions and CONTRACT.md spec |
| `research` | Investigating platform porting (macOS/Linux), Langflow dependency changes, or uv behaviour |
| `implement` | Building the macOS/Linux installer port |
| `diagnosing-bugs` | Investigating user-reported issues, AV false positives, or runtime failures |

## Version Bumping

| Commit type | Version bump |
|-------------|-------------|
| `fix:` | patch (v1.1.8 → v1.1.9) |
| `feat:` | minor (v1.1.8 → v1.2.0) |
| `docs:` / `chore:` | no release |
| `fix!:` or `feat!:` | major (v1.1.8 → v2.0.0) |

## Verification

Before committing (or before merging a PR), run these checks:

- **Braces balanced**: `rg -F '{' src/install-langflow-script.ps1 | wc -l` equals `rg -F '}' src/install-langflow-script.ps1 | wc -l`
- **No irm | iex**: confirm the pattern does not exist in `src/install-langflow-script.ps1`
- **Docs up to date**: AGENTS.md and CONTRACT.md reflect any behavior changes
- **No secrets or absolute paths** in the diff
- **Consistent zip uploaded**: confirm `langflow-installer-win.zip` is attached to the release alongside the versioned zip
- **Encoding correct**: batch files use ASCII; .ps1 files are UTF-8 with BOM
- **Version consistency**: extract `$LangflowVersion` from `src/install-langflow-script.ps1` and confirm it appears in `README.md`, `CONTRACT.md`, `AGENTS.md`, and `docs/index.html`. Run: `rg -F "$(rg '^\$LangflowVersion\s*=\s*"([^"]+)"' src/install-langflow-script.ps1 -r '$1')" README.md CONTRACT.md AGENTS.md docs/index.html`
- **No stale version refs**: after bumping, confirm no outdated version strings remain: `rg '\d+\.\d+\.\d+' . --include '*.ps1' --include '*.sh' --include '*.md' --include '*.html'` and check each match is intentional (CHANGELOG history excluded)
- **Bash script**: confirm `src/install-langflow.sh` has `set -euo pipefail` and uses POSIX-friendly syntax
