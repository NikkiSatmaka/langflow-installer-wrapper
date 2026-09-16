# 0006: Bundle the full non-PyTorch provider set for desktop parity

**Status:** Accepted. Supersedes the provider-set decision in ADR 0005.

## Context

ADR 0005 matched the installer to the official `langflowai/langflow` Docker image: the curated `langflow` provider set plus the opt-in Composio bundle. The Docker image has since been slimmed down, and this installer targets desktop users, not servers.

In Langflow 1.12, provider bundles that are not installed still render in the visual editor, but the flow fails at run time with an error naming the missing package. For non-technical desktop users experimenting with Langflow, that "install `<package>`" wall is the main friction: a fresh install covered only the curated set (openai, anthropic, azure, cohere, google, ollama, and the other default `lfx-*` bundles). Model providers like DeepSeek, Groq, NVIDIA, OpenRouter, Perplexity, and Mistral, plus vector stores like Pinecone, Qdrant, and Weaviate, were broken on first use.

## Change

Switch `src/requirements.txt` from two lines:

```
langflow[postgresql]==1.12.2
lfx-bundles[composio]==1.1.23
```

to one line:

```
langflow[bundles,postgresql]==1.12.2
```

Langflow 1.12.2 ships a `bundles` extra that installs every non-PyTorch provider from `lfx-bundles[all-no-torch]` plus the opt-in standalone packages (arxiv, confluent, duckduckgo, empiriolabs, exa, firecrawl, nextplaid, paddle, valkey). Composio is one of the `all-no-torch` providers, so its separate pin is now redundant. The `postgresql` extra is kept to preserve the ability to point Langflow's database at a Postgres server.

Torch-requiring providers (Code Agents, CUGA, the local Docling OCR parser) stay opt-in, matching the slim Docker direction.

## Decision

Install from `langflow[bundles,postgresql]==1.12.2` as the single bundled requirement. Every provider component that does not require PyTorch is usable out of the box, which matches the "all dependencies are included" promise of Langflow Desktop for the experimental audience this installer serves.

## Consequences

- Larger install: the full no-torch provider set pulls many more SDKs, growing first-install time and disk usage beyond the existing "a few GB" guidance.
- More transitive dependency surface. `src/constraints.txt` exists to pin any dependency that ships a source-only release without wheels; the CI install-test matrix (real installer on win/mac/linux with build tools removed) is the gate that catches this. If a provider lacks pre-built wheels on a target platform, add a constraint or drop that specific bundle.
- `src/requirements.txt` is a single pinned line; the version-pin fallback (strip `==1.12.2`, retry latest) keeps the same extras.
- Bumping the Langflow pin now only touches `langflow[bundles,postgresql]==<version>`; there is no separate bundles pin to re-check.
- ADR 0005's install-mechanics rationale (bundled, space-free requirements file, constraints, fallback) is unchanged. Only its provider-set outcome is superseded.