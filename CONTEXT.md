# Context: Langflow Installer Wrapper

This repository provides single-click installers for Langflow on Windows, macOS, and Linux. The installer uses `uv pip install langflow` with a `constraints.txt` that pins known-breaking transitive dependencies (those that occasionally ship source-only releases without pre-built wheels).

## Language

**Constraints file**:
A `constraints.txt` shipped alongside the installer scripts that constrains only the transitive dependencies known to break on certain platforms by shipping source-only releases without pre-built wheels (e.g., litellm, fastapi, cryptography, pypdfium2). Applied via `--constraint` at install time.

**Smoke test**:
A scheduled weekly CI workflow that runs the actual installer scripts (`install-langflow.sh` / `install-langflow-script.ps1`) on all 3 OS platforms (win-amd64, macos-arm64, linux-x64) without build tools, then verifies the installed Langflow version and installer artifacts. If it fails, the constraints file needs updating before the next stable release.

**Stable release**:
A tag `v<LangflowVersion>` (e.g., `v1.11.1`) that pins that exact Langflow version in the installer scripts. The tag-triggered CI runs the full OS-matrix install test with the pinned version before packaging and publishing.

**Constraint-fix release**:
A `v<LangflowVersion>-N` postfix when constraints need updating between Langflow versions (e.g., `v1.11.1-1`).

**Langflow version**:
The upstream Langflow package version pinned in the installer scripts (e.g., `1.11.1`). Changed manually when a new Langflow version is tested and released.

**Installer wrapper version**:
The version of this repository's releases (e.g., `v1.9.0`), tracked in the CHANGELOG and used for GitHub Releases and zip filenames. Distinct from the upstream Langflow version.
