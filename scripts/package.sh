#!/usr/bin/env bash
#
# Package the Langflow installer into platform-specific zips.
# Usage:  bash scripts/package.sh [tag]
#   If tag is given, both versioned and unversioned zips are produced:
#     langflow-installer-{platform}-{tag}.zip
#     langflow-installer-{platform}.zip
#   Otherwise, only unversioned zips:
#     langflow-installer-{platform}.zip
#
# Output goes to dist/
set -euo pipefail

TAG="${1:-}"
DIST="dist"
mkdir -p "$DIST"

# Build a zip for a given platform.
# Arguments:
#   $1: platform name (win|macos|linux)
#   all remaining args: files to include (with their relative paths)
package_platform() {
    local platform="$1"
    shift
    local tmpdir
    tmpdir=$(mktemp -d)

    mkdir -p "$tmpdir/src"

    # Copy each listed file, placing src/ items under tmpdir/src/
    for f in "$@"; do
        case "$f" in
            src/*)
                cp "$f" "$tmpdir/src/"
                ;;
            *)
                cp "$f" "$tmpdir/"
                ;;
        esac
    done

    # Build the zip in dist/
    local zip_name="langflow-installer-${platform}.zip"
    (cd "$tmpdir" && zip -rq "$OLDPWD/$DIST/$zip_name" .)
    echo "  $zip_name"

    # If a tag was given, also produce a versioned copy
    if [ -n "$TAG" ]; then
        local tagged_name="langflow-installer-${platform}-${TAG}.zip"
        cp "$DIST/$zip_name" "$DIST/$tagged_name"
        echo "  $tagged_name"
    fi

    rm -rf "$tmpdir"
}

echo "Packaging..."

# Fetch uv-installer from upstream (not committed to repo)
echo "  Fetching uv-install.ps1 from astral.sh..."
curl -fsSL https://astral.sh/uv/install.ps1 -o src/uv-install.ps1

package_platform "win" \
    "Install Langflow.bat" "Stop Langflow.bat" LICENSE \
    "src/install-langflow-script.ps1" "src/stop-langflow-script.ps1" \
    "src/uv-install.ps1" "src/constraints.txt" "src/assets/langflow.ico"

# Clean up fetched file
rm -f src/uv-install.ps1

package_platform "macos" \
    "Install Langflow.command" "Stop Langflow.command" LICENSE \
    "src/install-langflow.sh" "src/stop-langflow.sh" "src/constraints.txt"

package_platform "linux" \
    "Install Langflow.sh" "Stop Langflow.sh" LICENSE \
    "src/install-langflow.sh" "src/stop-langflow.sh" "src/constraints.txt" "src/assets/langflow.png"

echo "Done. All zips in $DIST/"
