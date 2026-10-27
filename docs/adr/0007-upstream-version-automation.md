# Spec: Upstream Langflow Version Automation

## Objective

Check for a newer stable Langflow release, prove it installs under this repository's supported Python 3.12 / Windows, macOS, and Linux constraints, then propose the version change for maintainer review. If metadata is unavailable, malformed, or the install compatibility gate fails, create or update a GitHub issue for human resolution instead of changing the pinned version.

## Proposed behavior

- Run weekly and on manual dispatch.
- Read the latest stable `langflow` release from the official PyPI JSON API; ignore pre-release versions and do nothing if the stable release is not newer than the installer pin.
- Update all version references currently required by `scripts/verify.sh`, both installer version constants, and `src/requirements.txt` in an isolated workflow workspace.
- Run repository consistency checks and the existing real installer install-test matrix against the candidate version on Windows, macOS, and Linux, using Python 3.12 and the committed constraints.
- On success, open a branch and pull request with the candidate changes; never commit directly to `main` or create a release/tag. A human reviews and merges the PR.
- On compatibility/metadata failure, open or update one deduplicated GitHub issue containing candidate version and failure details. Do not update the pin or open a version-bump PR.
- Use the repository's `GITHUB_TOKEN` with minimum permissions; no external credentials or new dependencies.

## Compatibility contract

A candidate is compatible only when the actual installer succeeds and installed Langflow version verification passes on all three existing OS matrix targets. Package metadata or wheel availability alone is insufficient. The current install-test workflow reads the pinned version from checked-out source, so implementation must make the candidate pin visible to that reusable validation job (for example, validate within the candidate branch/workflow workspace rather than testing the current `main` pin).

## Commands and verification

- Existing repository gate: `bash scripts/verify.sh`.
- Compatibility gate: existing `install-test.yml` matrix with the candidate pin.
- Local workflow/script smoke: exercise newer stable, same/older version, prerelease, metadata error, and installation failure fixtures without GitHub or PyPI writes.

## Project structure

- `.github/workflows/`: scheduled/manual detection, validation, PR and issue actions.
- `scripts/`: small deterministic candidate parsing/update helper if needed.
- `docs/adr/`: this decision/specification and operational behavior.
- `CHANGELOG.md`: record the shipped automation.

## Boundaries

- Always: keep current pin unchanged until all supported platform installs pass; open a reviewable PR on success; escalate unsafe outcomes via issue; update version references consistently.
- Ask first: automatic merge or automatic release/tag creation; changing supported Python/platforms or weakening install gates.
- Never: direct push to `main`, prerelease updates, silently skip incompatibility, or replace the real install test with metadata-only checks.

## Success criteria

1. A newer stable compatible version results in a pull request containing all required version updates and passing the three-platform installer test.
2. No newer stable version results in no PR or issue.
3. A prerelease is ignored.
4. Metadata, consistency, or compatibility failures create/update a deduplicated issue and do not propose a version bump.
5. The scheduled and manual workflow paths require no new secrets.

## Open questions

None. The default is human-reviewed PRs, not automatic merging.