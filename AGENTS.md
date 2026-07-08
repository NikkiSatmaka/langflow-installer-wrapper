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
| `Stop Langflow.bat` | Double-click to stop the running Langflow server (Windows) |
| `Stop Langflow.command` | Double-click to stop the running Langflow server (macOS) |
| `Stop Langflow.sh` | Double-click to stop the running Langflow server (Linux) |
| `README.md` | This file — for humans |
| `CHANGELOG.md` | Release history |
| `src/install-langflow-script.ps1` | Main PowerShell installer/uninstaller script (Windows) |
| `src/install-langflow.sh` | Main bash installer/uninstaller script (macOS/Linux) |
| `src/stop-langflow-script.ps1` | PowerShell stop script (Windows) |
| `src/stop-langflow.sh` | Bash stop script (macOS/Linux) |
| `src/uv-install.ps1` | Bundled uv bootstrapper (official script from astral.sh) — eliminates `irm \| iex` AV trigger (Windows only) |
| `src/stop-langflow-script.ps1` | PowerShell stop script (Windows) |
| `src/stop-langflow.sh` | Bash stop script (macOS/Linux) |
| `scripts/verify.sh` | Pre-commit verification checks (10 checks, POSIX-safe for CI) |
| `scripts/package.sh` | Cross-platform zip packaging (bash) |
| `scripts/package.ps1` | Cross-platform zip packaging (PowerShell) |
| `.github/workflows/verify.yml` | CI: PR verification (runs `scripts/verify.sh`) |
| `.github/workflows/release.yml` | CI: Automated release on tag push (verify + package + publish) |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes |
| `docs/GATEKEEPER.md` | macOS Gatekeeper bypass guide |
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

## Version Bumping

| Commit type | Version bump |
|-------------|-------------|
| `fix:` | patch (v1.1.8 → v1.1.9) |
| `feat:` | minor (v1.1.8 → v1.2.0) |
| `docs:` / `chore:` | no release |
| `fix!:` or `feat!:` | major (v1.1.8 → v2.0.0) |

## Release Process

### Automated (CI/CD)

Tagging triggers the release workflow automatically:

1. Ensure `main` has the changes merged and verified.
2. Update `$ScriptVersion` / `SCRIPT_VERSION` in the install scripts if they changed.
3. Update `CHANGELOG.md` with the new version, date, and entries.
4. Update `README.md` and `docs/index.html` if the hero message or version number changed.
5. Run `bash scripts/verify.sh` to confirm everything passes.
6. Commit with message: `docs: update changelog for vX.Y.Z`.
7. Tag the commit: `git tag vX.Y.Z`.
8. Push tag: `git push origin vX.Y.Z`.
9. The CI workflow (`.github/workflows/release.yml`):
   - Runs verify checks
   - Packages all 3 platform zips (both versioned and unversioned names)
   - Creates a GitHub Release with auto-generated notes
   - Uploads all 6 zips to the release

**Do not delete and re-push the same tag name** — the CI workflow will create a new release or fail. If you need to fix a release, bump the version.

### Zip contents

Each zip contains platform-specific files only:

**`langflow-installer-win.zip` / `langflow-installer-vX.Y.Z.zip`:**
- `Install Langflow.bat` (root)
- `Stop Langflow.bat` (root)
- `LICENSE` (root)
- `src/install-langflow-script.ps1`
- `src/stop-langflow-script.ps1`
- `src/uv-install.ps1`

**`langflow-installer-macos.zip`:**
- `Install Langflow.command` (root)
- `Stop Langflow.command` (root)
- `LICENSE` (root)
- `src/install-langflow.sh`
- `src/stop-langflow.sh`

**`langflow-installer-linux.zip`:**
- `Install Langflow.sh` (root)
- `Stop Langflow.sh` (root)
- `LICENSE` (root)
- `src/install-langflow.sh`
- `src/stop-langflow.sh`

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

## Verification

Before committing (or before merging a PR), run `bash scripts/verify.sh` — it checks all the following automatically:

- **Braces balanced**: confirm `{` and `}` counts match in the PowerShell script (AVOID: `irm | iex` injection via unbalanced blocks)
- **No irm | iex**: the pattern must not exist in `src/install-langflow-script.ps1`
- **Docs up to date**: AGENTS.md and CONTRACT.md reflect any behavior changes
- **No secrets or absolute paths** in the diff
- **Consistent zip uploaded**: confirm `langflow-installer-win.zip` is attached to the release alongside the versioned zip
- **Encoding correct**: batch files use ASCII; .ps1 files are UTF-8 with BOM
- **Version consistency**: all files reference the same `$LangflowVersion`
- **No stale version refs**: after bumping, confirm no outdated version strings remain (CHANGELOG history excluded)
- **Bash script**: has `set -euo pipefail` and POSIX-friendly syntax

The CI workflow (`.github/workflows/verify.yml`) runs `scripts/verify.sh` on every PR to `main`.
