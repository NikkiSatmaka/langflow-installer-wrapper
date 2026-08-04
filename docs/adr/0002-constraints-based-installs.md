# 0002: Constraints-based installs with constraint test CI

**Status:** Accepted — supersedes ADR 0001.

## Context

ADR 0001 chose a pylock-based approach (`uv pip sync pylock.toml`) for deterministic, hash-pinned installs. This was never wired into the actual installer scripts — they continued to use `uv pip install langflow==X.Y.Z` with inline version pins for specific transitive dependencies.

The pylock approach has drawbacks for this project:

1. **Brittle against yanked deps:** If any transitive dep gets yanked from PyPI, the install fails with no fallback.
2. **Maintenance burden:** Every Langflow version bump requires regenerating the pylock, committing it, and shipping it in the zip.
3. **Never actually used:** The installer scripts never referenced `pylock.toml`. The file only existed for CI.

Meanwhile, the de facto approach of pinning only the Langflow version and a handful of known-breaking transitive deps was working. The real problem is not determinism — it's catching breakage when a transitive dep ships a source-only release without wheels.

## Decision

Replace the pylock approach with:

- **`constraints.txt`:** A flat file pinning only the transitive dependencies known to ship source-only releases without pre-built wheels on our target platforms (win-amd64, macos-arm64, linux-x64).
- **Constraint test CI** — a scheduled weekly workflow and a tag-triggered release workflow that run `uv pip install langflow --constraint=src/constraints.txt` on all 3 OS platforms. If it fails or requires source compilation, the constraints file needs updating.

The installer script pins `langflow==X.Y.Z` and applies `--constraint=constraints.txt`. Users still run `uv pip install langflow` (with the pin and constraint), and resolution happens at install time — but within the bounds set by the constraints file.

## Consequences

- **No more pylock.toml** — remove `pylock.toml`, `uv.lock`, and the pylock-specific `[tool.uv]` section from `pyproject.toml`.
- **No more prerelease workflow** — replace with a combined constraint-test workflow (weekly) and tag-triggered release workflow.
- **Still need to update constraints.txt** when a transitive dep breaks, but the change is a one-line edit in a single file, not a full lock regeneration.
- **Loss of full determinism** — the same zip run on different days may resolve slightly different dependency trees. The conservative constraints (upper bounds on known breakers) mitigate this without the full overhead of a lock.
- **Constraint test CI catches breakage before users hit it** — the weekly schedule means at most a week of exposure to a bad transitive dep update.
