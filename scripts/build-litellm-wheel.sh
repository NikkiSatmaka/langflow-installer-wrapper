#!/usr/bin/env bash
#
# Build the litellm macOS wheel from source.
#
# litellm >=1.93 ships a Rust extension (maturin) and publishes no macOS
# wheels, so macOS installs use a wheel built here at package time. The
# version is read from src/constraints.txt (single source of truth) and
# built from the PyPI sdist so the wheel always matches what the installer
# resolves.
#
# Requires a C toolchain (Xcode Command Line Tools) and Rust. Only intended
# to run on an arm64 macOS CI runner.
#
# Usage:  bash scripts/build-litellm-wheel.sh [output-dir]
#   Default output dir is src/ (matching the repo zip layout).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${1:-$SCRIPT_DIR/../src}"
CONSTRAINTS_FILE="$SCRIPT_DIR/../src/constraints.txt"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

if [ "$(uname -s)" != "Darwin" ]; then
    echo "error: the litellm wheel must be built on macOS" >&2
    exit 1
fi

command -v cargo >/dev/null 2>&1 || {
    echo "error: Rust (cargo) is required to build the litellm wheel" >&2
    exit 1
}

LITELLM_VERSION="$(awk -F '==' '/^litellm==/{print $2; exit}' "$CONSTRAINTS_FILE")"
if [ -z "$LITELLM_VERSION" ]; then
    echo "error: no 'litellm==X.Y.Z' found in $CONSTRAINTS_FILE" >&2
    exit 1
fi

echo "Building litellm==$LITELLM_VERSION wheel from PyPI sdist..."

uv venv "$WORKDIR/venv" --python 3.12 >/dev/null
uv pip install --python "$WORKDIR/venv/bin/python" pip >/dev/null

if ! "$WORKDIR/venv/bin/python" -m pip wheel \
    --no-deps \
    --no-binary litellm \
    --wheel-dir "$WORKDIR/wheels" \
    "litellm==$LITELLM_VERSION" >"$WORKDIR/build.log" 2>&1; then
    cat "$WORKDIR/build.log" >&2
    exit 1
fi

WHEEL=""
for w in "$WORKDIR/wheels"/litellm-*.whl; do
    [ -e "$w" ] && WHEEL="$w" && break
done
if [ -z "$WHEEL" ]; then
    echo "error: no wheel produced for litellm==$LITELLM_VERSION" >&2
    exit 1
fi

case "$WHEEL" in
    *macosx*arm64*.whl) ;;
    *)
        echo "error: unexpected wheel: $WHEEL (expected a macOS arm64 wheel)" >&2
        exit 1
        ;;
esac

mkdir -p "$OUT_DIR"
cp "$WHEEL" "$OUT_DIR/"
echo "Wheel built: $OUT_DIR/$(basename "$WHEEL")"
