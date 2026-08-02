# 0001: Pylock-based deterministic installs

**Status:** Superseded by ADR 0002.

We switched from `uv pip install langflow==X.Y.Z` (resolves at install time) to `uv pip sync --preview-features=pylock pylock.toml` (pre-resolved, hash-pinned dependency tree).

**Why:** `uv pip install` resolves the full dependency tree on the user's machine at install time. This means the same installer zip can produce different environments depending on when it runs, which PyPI state is available, and which transitive deps happen to resolve. A pylock file pins every package at a specific version with its hash, making the install deterministic and reproducible across machines.

**Tradeoff:** If any transitive dependency gets yanked from PyPI, the install will fail with no fallback path. We accept this. The mitigation is to regenerate the pylock and ship a patch release. This is the same model used by npm/yarn lockfiles: the lock is the source of truth, and breakage is fixed by shipping a new lock.

**Alternatives considered:**
- **Two-phase install (try sync, fallback to pip install):** Keeps both paths forever, increases script complexity, and hides failures behind a fallback that may silently pick a different version. Rejected because it undermines the determinism we're buying.
- **Bundle pyproject.toml + uv.lock, run `uv sync`:** More files to ship, and the installer needs to copy the project into the user's machine. Rejected because it couples the installer to the project structure.
- **Ship pylock only for speed, manual fallback on error:** Bad UX — the user gets an error with no clear fix path.

The pylock is generated in CI (prerelease workflow), committed to the branch tree, and shipped inside `src/` in every release zip. The installer scripts reference it via `$PSScriptRoot/pylock.toml` (PowerShell) or `$SCRIPT_DIR/pylock.toml` (bash), resolved before `cd` into the langflow directory.
