# 0004: Pass uv the constraints file by a space-free relative name

**Status:** Accepted.

## Context

The installer applies `constraints.txt` with `uv pip install langflow --constraint=<path>`. On Windows machines whose user profile path contains a space (e.g. `C:\Users\John Doe\langflow`), uv reported the constraint file as not found: the path appeared truncated at the first space.

This is not a shell quoting problem. Windows PowerShell 5.1 (the runtime used by `Install Langflow.bat`) quotes native-command arguments containing spaces when it builds the command line, and argument array splatting preserves each element as a single token. The prior fixes (v1.9.1 separate-argument splat, the v1.9.2 quoted-path attempt, and the current `--constraint=path` equals form) all assumed the argument was not reaching uv intact.

uv itself re-splits the value of `--constraint`/`-c`/`--override`/`-r` on whitespace (pip's `PIP_CONSTRAINT` list semantics), then truncates a single path at the first space. This was reproduced against the project's pinned uv 0.12.1:

```
$ uv pip install pytest --constraint="/tmp/opencode/uv space test/constraints file.txt"
error: File not found: `/tmp/opencode/uv`
```

The bug is tracked upstream as astral-sh/uv#12639 and remains open. Because the truncation happens inside uv, after the argument is already correctly quoted, no amount of shell-level quoting can fix it.

CI did not catch this: GitHub runner home/checkout paths are space-free, so the real-installer run in `install-test.yml` never exercised a spaced constraint path.

## Decision

Give uv a constraint path whose argument value contains no whitespace, by copying the bundled `constraints.txt` into the langflow working directory and passing the relative name:

- `install-langflow-script.ps1`: `Copy-Item $ConstraintsFile "$LangflowDir\constraints.txt" -Force`, then `uv pip install ... --constraint=constraints.txt` with CWD set to `$LangflowDir` (already pushed before install).
- `install-langflow.sh`: `cp -f "$CONSTRAINTS_FILE" "$LANGFLOW_DIR/constraints.txt"`, then the same relative argument.

The relative name is space-free, so uv never parses a spaced path. The file on disk may still live under a spaced directory (`%USERPROFILE%\langflow`); uv joins the relative name to the CWD with OS path APIs after the whitespace split, so spaced directories are handled correctly. This was verified by running uv from a directory whose path contained spaces.

The copy is unconditional and idempotent, and the file is removed with the rest of the langflow directory on uninstall.

## Consequences

- The constraints mechanism works on Windows and macOS/Linux regardless of spaces in the user profile or installation directory.
- `install-test.yml` now runs the real installer from a directory containing a space on all three platforms, so a future uv change to constraint parsing (or a regression to an absolute-path argument) fails CI.
- `scripts/verify-install.sh` asserts `constraints.txt` exists in the langflow directory after install.
- The `--constraint=constraints.txt` wording in AGENTS.md and the smoke test instructions remains accurate; only the mechanism for staging the file changed.
