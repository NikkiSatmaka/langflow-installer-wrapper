# 0003: Install-script smoke test in CI

**Status:** Accepted.

## Context

ADR 0002 introduced constraint-test CI: a 3-OS matrix job that removed build tools and ran `uv pip install langflow --constraint=src/constraints.txt` to validate that binary wheels exist for every dependency. It never executed the installer scripts themselves.

In v1.9.1, the Windows installer regressed: `install-langflow-script.ps1` built `uv pip install ... --constraint C:\...\constraints.txt` as a single token, which clap rejected, so every Windows install failed and bounced back to the menu. The constraint test passed because it invoked uv with correctly separated bash arguments. The test that would have caught this — running the actual installer — did not exist.

## Decision

Fold the installer scripts into the existing 3-OS matrix job (renamed `install-test.yml`):

- Replace the manual `uv venv` + `uv pip install` step with running the real installer end-to-end, driving the menu non-interactively by piping `I` (install path) into `src/install-langflow.sh` on macOS/Linux and `src/install-langflow-script.ps1` (via `powershell.exe`, matching the `.bat` launcher) on Windows.
- Keep build-tool removal before the script run, so the wheel-only guarantee from ADR 0002 still holds.
- Keep the installed-version-equals-pin assertion. The script's "try latest" fallback would otherwise mask a broken pin by succeeding with a newer Langflow; the post-run version check catches that.
- Add `scripts/verify-install.sh` to assert the venv exists, the installed version matches the pin, and the launcher/stop artifacts were created. Desktop shortcuts are warn-only on Windows (headless runners can lack a Desktop folder) and fatal on macOS/Linux where the runner's Desktop is pre-created.

This is deliberately folded into one workflow rather than a separate one: the script test is a strict superset of the manual-install step it replaces, so CI cost is unchanged.

## Consequences

- The weekly schedule, PR/push triggers, and tag-triggered release gating now exercise the real installer code paths on all three platforms.
- A regression in the Windows PowerShell argument handling (or any installer logic) fails CI on the next PR instead of shipping to users.
- `verify-install.sh` is added to the bash lint/syntax check lists in `verify.sh` and `mise.toml`.
- Manual smoke testing (AGENTS.md "Smoke Testing") still covers what CI cannot: real desktop shortcut launching, browser open, idempotency, and uninstall.
