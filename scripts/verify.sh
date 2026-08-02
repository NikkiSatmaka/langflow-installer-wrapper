#!/usr/bin/env bash
#
# Verification checks for the Langflow installer project.
# Exits non-zero on any failure. Silence = all clear.
# Run from repo root: bash scripts/verify.sh
set -euo pipefail

PASS=0
FAIL=0

pass() { PASS=$((PASS + 1)); }
fail() {
    echo "FAIL: $*"
    FAIL=$((FAIL + 1))
}

# ── 1. Shebang on .sh files ────────────────────────────────────────────────

for f in Install\ Langflow.sh Stop\ Langflow.sh src/*.sh; do
    [ -f "$f" ] || continue
    read -r first <"$f"
    if [ "$first" != "#!/usr/bin/env bash" ]; then
        fail "$f: shebang must be '#!/usr/bin/env bash', got '$first'"
    fi
done
pass "shebang"

# ── 2. set -euo pipefail on .sh files ──────────────────────────────────────

for f in Install\ Langflow.sh Stop\ Langflow.sh src/install-langflow.sh src/stop-langflow.sh scripts/verify.sh scripts/package.sh; do
    [ -f "$f" ] || continue
    if ! grep -q 'set -euo pipefail' "$f" 2>/dev/null; then
        fail "$f: missing 'set -euo pipefail'"
    fi
done
pass "set -euo pipefail"

# ── 3. Brace balance on .ps1 files ─────────────────────────────────────────

for f in src/*.ps1; do
    [ -f "$f" ] || continue
    opens=$(tr -d -c '{' <"$f" | wc -c)
    closes=$(tr -d -c '}' <"$f" | wc -c)
    if [ "$opens" -ne "$closes" ]; then
        fail "$f: brace imbalance ($opens open vs $closes close)"
    fi
done
pass "brace balance"

# ── 4. No irm|iex in install-langflow-script.ps1 ───────────────────────────

if grep -Eq 'irm.*iex' src/install-langflow-script.ps1 2>/dev/null; then
    fail "install-langflow-script.ps1 contains irm|iex pattern"
fi
pass "no irm|iex"

# ── 5. UTF-8 BOM on .ps1 files (skip uv-install.ps1, maintained upstream) ──

for f in src/install-langflow-script.ps1 src/stop-langflow-script.ps1; do
    [ -f "$f" ] || continue
    bom=$(head -c 3 "$f" | od -A n -t x1 | tr -d ' \n')
    if [ "$bom" != "efbbbf" ]; then
        fail "$f: missing UTF-8 BOM (got '$bom')"
    fi
done
pass "UTF-8 BOM"

# ── 6. Executable bit on .command and .sh files ────────────────────────────

for f in Install\ Langflow.command Stop\ Langflow.command \
    Install\ Langflow.sh Stop\ Langflow.sh src/*.sh scripts/verify.sh scripts/package.sh; do
    [ -f "$f" ] || continue
    if [ ! -x "$f" ]; then
        fail "$f: not executable"
    fi
done
pass "executable bit"

# ── 7. bash syntax check ───────────────────────────────────────────────────

for f in src/install-langflow.sh src/stop-langflow.sh scripts/verify.sh scripts/package.sh; do
    [ -f "$f" ] || continue
    if ! bash -n "$f" 2>/dev/null; then
        fail "$f: bash syntax error"
    fi
done
pass "bash syntax"

# ── 8. Version consistency ──────────────────────────────────────────────────

LF_VER=$(awk -F '"' '/^\$LangflowVersion/{print $2; exit}' src/install-langflow-script.ps1 2>/dev/null || true)
if [ -z "$LF_VER" ]; then
    fail "could not extract LangflowVersion from install-langflow-script.ps1"
else
    for doc in README.md CONTRACT.md AGENTS.md docs/index.html; do
        if [ -f "$doc" ]; then
            if ! grep -Fq "$LF_VER" "$doc" 2>/dev/null; then
                fail "$doc: missing Langflow version $LF_VER"
            fi
        fi
    done
fi
pass "version consistency"

# ── 9. Secrets scan ────────────────────────────────────────────────────────

for f in src/install-langflow.sh src/install-langflow-script.ps1; do
    [ -f "$f" ] || continue
    if grep -Eq 'sk-[a-zA-Z0-9]{20,}' "$f" 2>/dev/null; then
        fail "$f: possible secret key found"
    fi
    if grep -Eq 'ghp_[a-zA-Z0-9]{36}' "$f" 2>/dev/null; then
        fail "$f: possible GitHub token found"
    fi
done
pass "secrets scan"

# ── 10. constraints.txt exists ────────────────────────────────────────────

if [ ! -f src/constraints.txt ]; then
    fail "src/constraints.txt: missing constraints file"
fi
pass "constraints.txt"

# ── 11. Zip contents match spec ────────────────────────────────────────────

for f in "Install Langflow.bat" "Stop Langflow.bat" \
    "Install Langflow.command" "Stop Langflow.command" \
    "Install Langflow.sh" "Stop Langflow.sh" \
    src/install-langflow-script.ps1 src/stop-langflow-script.ps1 \
    src/uv-install.ps1 src/constraints.txt src/install-langflow.sh src/stop-langflow.sh; do
    if [ ! -f "$f" ]; then
        fail "$f: referenced by zip spec but does not exist"
    fi
done
pass "zip spec files exist"

# ── 12. Lint (shellcheck + shfmt + PSScriptAnalyzer via mise) ──────────────

if ! command -v mise >/dev/null 2>&1; then
    fail "mise not found -- install it (https://mise.jdx.dev) then run 'mise install'"
else
    if ! mise run lint; then
        fail "lint failed (see output above)"
    fi
fi
pass "lint"

# ── Summary ─────────────────────────────────────────────────────────────────

echo "────────────────────────────────────────"
echo "  $PASS passed  /  $FAIL failed"
echo "────────────────────────────────────────"
[ "$FAIL" -eq 0 ] || exit 1
