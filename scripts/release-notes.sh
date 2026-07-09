#!/usr/bin/env bash
#
# Generate GitHub release notes for a given tag from CHANGELOG.md.
# Usage:  bash scripts/release-notes.sh v1.6.0 [CHANGELOG.md]
# Prints markdown to stdout.
set -euo pipefail

TAG="${1:?Usage: release-notes.sh <tag> [CHANGELOG]}"
CHANGELOG="${2:-CHANGELOG.md}"

if [ ! -f "$CHANGELOG" ]; then
  echo "Error: $CHANGELOG not found" >&2
  exit 1
fi

# ── Extract the section for this tag ────────────────────────────────────────
section=$(awk -v pat="## $TAG" '
  /^## / {
    if (found) exit
    if ($0 ~ "^"pat" ") { found=1; next }
  }
  found { print }
' "$CHANGELOG")

if [ -z "$section" ]; then
  echo "Error: no CHANGELOG section for $TAG" >&2
  exit 1
fi

# ── Group bullets by commit type ────────────────────────────────────────────
features=""
fixes=""
docs=""
maintenance=""

while IFS= read -r line; do
  # strip leading whitespace
  trimmed="${line#"${line%%[![:space:]]*}"}"

  # match "- <type>: <desc>"
  if printf '%s' "$trimmed" | grep -qE '^- [a-z]+: '; then
    raw="${trimmed#- }"          # "feat: blah blah"
    ctype="${raw%%:*}"           # "feat"
    desc="${raw#*: }"            # "blah blah"
    case "$ctype" in
      feat)     features="${features}- ${desc}"$'\n' ;;
      fix)      fixes="${fixes}- ${desc}"$'\n' ;;
      docs)     docs="${docs}- ${desc}"$'\n' ;;
      chore|refactor) maintenance="${maintenance}- ${desc}"$'\n' ;;
      *)        maintenance="${maintenance}- ${line}"$'\n' ;;
    esac
  else
    maintenance="${maintenance}${line}"$'\n'
  fi
done <<< "$section"

# ── Build "What's Changed" section ──────────────────────────────────────────
what_changed="## What's Changed"$'\n'
if [ -n "$features" ]; then
  what_changed="${what_changed}### Features"$'\n'"${features}"$'\n'
fi
if [ -n "$fixes" ]; then
  what_changed="${what_changed}### Bug Fixes"$'\n'"${fixes}"$'\n'
fi
if [ -n "$docs" ]; then
  what_changed="${what_changed}### Documentation"$'\n'"${docs}"$'\n'
fi
if [ -n "$maintenance" ]; then
  what_changed="${what_changed}### Maintenance"$'\n'"${maintenance}"$'\n'
fi

# ── Full Changelog link ─────────────────────────────────────────────────────
if printf '%s' "$TAG" | grep -qE '(beta|rc|alpha)'; then
  # Pre-release: compare against the last tag of any kind (skip self)
  prev_tag=$(git tag --sort=-v:refname 2>/dev/null | grep -v "^${TAG}$" | head -1 || true)
else
  # GA release: compare against the last GA tag (skip pre-releases)
  prev_tag=$(git tag --sort=-v:refname 2>/dev/null | grep -v "^${TAG}$" | grep -vE '(beta|rc|alpha)' | head -1 || true)
fi
if [ -n "$prev_tag" ]; then
  compare="https://github.com/NikkiSatmaka/langflow-installer-wrapper/compare/${prev_tag}...${TAG}"
else
  compare="https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/tag/${TAG}"
fi

# ── Output ──────────────────────────────────────────────────────────────────
cat <<EOF
## Installation

Download the zip for your platform from the **Assets** section below, extract, and double-click the launcher:

| Platform | Archive |
|----------|---------|
| Windows  | \`langflow-installer-win.zip\` |
| macOS    | \`langflow-installer-macos.zip\` |
| Linux    | \`langflow-installer-linux.zip\` |

${what_changed}
**Full Changelog**: ${compare}
EOF
