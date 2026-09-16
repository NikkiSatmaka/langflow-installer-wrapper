# 0005: Install from a bundled requirements.txt

**Status:** Accepted. The provider-set outcome is superseded by ADR 0006; the install-mechanics rationale (bundled, space-free requirements file, constraints, version-pin fallback) remains in force.

## Context

The installer originally invoked `uv pip install "langflow==<version>"` directly. On the 1.11 line that left a gap versus the official `langflowai/langflow` Docker image: several provider integrations (`langchain-google-genai`, `langchain-google-community`, `langchain-ollama`, `langchain-azure-ai`) and the PostgreSQL drivers (`psycopg`, `psycopg2-binary`) were only reachable through extras the installer never enabled:

- `langchain-google-genai~=4.1` and `langchain-google-community~=3.0` lived only under the **`google` extra** of `langflow-base`.
- `langchain-ollama~=0.3.10` lived only under the **`ollama` extra** of `langflow-base`.
- `langchain-azure-ai` was not in the langflow 1.11.x dependency tree at all.
- `psycopg` and `psycopg2-binary` came from langflow's **`postgresql` extra**, which the installer never enabled.

So the 1.11-era `requirements.txt` listed `langflow[postgresql]`, `langflow-base[google,ollama]`, and `langchain-azure-ai` explicitly.

## Change

Langflow 1.12 concludes the extension-bundle transition. The Google, Ollama, and Azure AI provider bundles (`lfx-google`, `lfx-ollama`, `lfx-azure`) are now regular dependencies of `langflow` itself, alongside the rest of the curated `lfx-*` set (openai, anthropic, amazon, cohere, datastax, docling, ibm, oracle, vllm, openai-compatible, toolguard). The `postgresql` extra still adds the PostgreSQL drivers via `langflow-base[postgresql]`.

The `langflow-base[google,ollama]` and `langchain-azure-ai` lines are therefore redundant and were removed.

## Decision

Install from a bundled, versioned requirements file:

- `src/requirements.txt` (shipped in every zip):
  ```
  langflow[postgresql]==1.12.2
  lfx-bundles[composio]==1.1.23
  ```
- The langflow line is pinned; uv resolves whatever satisfies the pinned langflow's range. The `lfx-bundles[composio]` line pins the bundle version paired with that langflow release; its `composio` extra adds the `composio` and `composio-langchain` SDKs that the Composio bundle components need. The Composio bundle is an opt-in `lfx-bundles` extra in 1.12 (not a default langflow dependency), so it is pinned explicitly.
- Installers stage `requirements.txt` into the langflow working directory and pass it by its space-free relative name (`--requirements=requirements.txt`), the same mechanism as ADR 0004: uv re-splits `--requirements`/`-r` values on whitespace (astral-sh/uv#12639), so the argument value must contain no spaces.
- The `--constraints=constraints.txt` behavior is unchanged.
- The version fallback is preserved: if the pinned install fails, the script strips `==1.12.2` out of the staged file into `requirements-latest.txt` and retries, keeping the same extra.

## Consequences

- The installer matches the langflow 1.12 curated provider set (Google GenAI, Ollama, Azure AI, PostgreSQL, plus the other built-in bundles) and adds the opt-in Composio bundle.
- Requires a release/package step change: `src/requirements.txt` must ship in all three zips (`scripts/package.sh`, `scripts/package.ps1`).
- `scripts/verify.sh` checks `src/requirements.txt` exists, references the pinned version, and is listed in the zip spec; `scripts/verify-install.sh` asserts the staged copy exists after install.
- Bumping the Langflow pin now means editing `src/requirements.txt` in addition to the two install scripts and the docs.
- Keep the file plain and uncommented; the rationale lives here and in AGENTS.md.