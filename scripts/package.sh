#!/usr/bin/env bash
#
# Package the Langflow installer into platform-specific zips.
# Usage:  bash scripts/package.sh [tag]
#   If tag is given, zips are named langflow-installer-{platform}-{tag}.zip
#   Otherwise, langflow-installer-{platform}.zip
#
# Output goes to dist/
set -euo pipefail

TAG="${1:-}"
DIST="dist"
mkdir -p "$DIST"

package_win() {
    local tmpdir
    tmpdir=$(mktemp -d)
    local prefix="langflow-installer-win"
    [ -n "$TAG" ] && prefix="${prefix}-${TAG}"

    cp "Install Langflow.bat" "$tmpdir/"
    cp "Stop Langflow.bat" "$tmpdir/"
    cp LICENSE "$tmpdir/"
    mkdir -p "$tmpdir/src"
    cp src/install-langflow-script.ps1 "$tmpdir/src/"
    cp src/stop-langflow-script.ps1 "$tmpdir/src/"
    cp src/uv-install.ps1 "$tmpdir/src/"

    (cd "$tmpdir" && zip -rq "$OLDPWD/$DIST/${prefix}.zip" .)
    rm -rf "$tmpdir"
    echo "  ${prefix}.zip"
}

package_macos() {
    local tmpdir
    tmpdir=$(mktemp -d)
    local prefix="langflow-installer-macos"
    [ -n "$TAG" ] && prefix="${prefix}-${TAG}"

    cp "Install Langflow.command" "$tmpdir/"
    cp "Stop Langflow.command" "$tmpdir/"
    cp LICENSE "$tmpdir/"
    mkdir -p "$tmpdir/src"
    cp src/install-langflow.sh "$tmpdir/src/"
    cp src/stop-langflow.sh "$tmpdir/src/"

    (cd "$tmpdir" && zip -rq "$OLDPWD/$DIST/${prefix}.zip" .)
    rm -rf "$tmpdir"
    echo "  ${prefix}.zip"
}

package_linux() {
    local tmpdir
    tmpdir=$(mktemp -d)
    local prefix="langflow-installer-linux"
    [ -n "$TAG" ] && prefix="${prefix}-${TAG}"

    cp "Install Langflow.sh" "$tmpdir/"
    cp "Stop Langflow.sh" "$tmpdir/"
    cp LICENSE "$tmpdir/"
    mkdir -p "$tmpdir/src"
    cp src/install-langflow.sh "$tmpdir/src/"
    cp src/stop-langflow.sh "$tmpdir/src/"

    (cd "$tmpdir" && zip -rq "$OLDPWD/$DIST/${prefix}.zip" .)
    rm -rf "$tmpdir"
    echo "  ${prefix}.zip"
}

echo "Packaging..."
package_win
package_macos
package_linux
echo "Done. All zips in $DIST/"
