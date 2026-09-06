# 0005: Install from a bundled requirements.txt for docker parity

**Status:** Accepted.

## Context

The installer installed Langflow with `uv pip install "langflow==<version>"`. That created a visible gap versus the official `langflowai/langflow` Docker image: system-minted `pip freeze` lists from a 1.11.x installer install were missing several `langchain-*` packages the image ships (`langchain-google-genai`, `langchain-google-community`, `langchain-ollama`, `langchain-azure-ai`) and the PostgreSQL drivers (`psycopg`, `psycopg2-binary`).

The Docker image is built from the langflow monorepo with `uv sync --extra postgresql`, where the google, ollama, and azure integrations (`lfx-google`, `lfx-ollama`, `lfx-azure`) are default workspace dependencies. The PyPI wheels the installer consumes are different:

- `langchain-google-genai~=4.1` and `langchain-google-community~=3.0` live only under the **`google` extra** of `langflow-base`. They were dropped from the `complete`/`all` extras when langflow-base moved to 0.11.5 (the 1.11 line); langflow 1.11.5 and 1.11.6 both constrain `langflow-base[complete]>=0.11.6`, resolving to a base whose `complete` extra no longer includes them.
- `langchain-ollama~=0.3.10` lives only under the **`ollama` extra** of `langflow-base`.
- `langchain-azure-ai` is not in the langflow 1.11.x dependency tree at all and has no extra to activate.
- `psycopg` and `psycopg2-binary` come from langflow's **`postgresql` extra**, which the installer never enabled.

A `uv pip install` with no extras therefore silently omits integrations the Docker image includes.

## Decision

Switch the installers from a direct package argument to a bundled, versioned requirements file:

- `src/requirements.txt` (new, shipped in every zip):
  ```
  langflow[postgresql]==1.11.6
  langflow-base[google,ollama]
  langchain-azure-ai
  ```
- Only the langflow line is pinned; the extra lines float so uv resolves whatever satisfies the pinned langflow's range.
- Installers stage `requirements.txt` into the langflow working directory and pass it by its space-free relative name (`-r requirements.txt`), the same mechanism as ADR 0004: uv re-splits `-r` values on whitespace (astral-sh/uv#12639), so the argument value must contain no spaces.
- The `--constraint=constraints.txt` behavior is unchanged.
- The version fallback is preserved: if the pinned install fails, the script strips `==1.11.6` out of the staged file into `requirements-latest.txt` and retries, keeping the same extras.

## Consequences

- The installer now matches the Docker image for the google, ollama, azure, and postgresql integration groups on the pinned Langflow version.
- Requires a release/package step change: `src/requirements.txt` must ship in all three zips (`scripts/package.sh`, `scripts/package.ps1`).
- `scripts/verify.sh` checks `src/requirements.txt` exists, references the pinned version, and is listed in the zip spec; `scripts/verify-install.sh` asserts the staged copy exists after install.
- Bumping the Langflow pin now means editing `src/requirements.txt` in addition to the two install scripts and the docs.
- Keep the file plain and uncommented; the rationale lives here and in AGENTS.md.