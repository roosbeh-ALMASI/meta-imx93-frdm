#!/usr/bin/env bash
set -euo pipefail

LAYER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/initialized/build-directory" >&2
    exit 1
fi
BUILD_DIR="$(realpath "$1")"

LOCAL_CONF="$BUILD_DIR/conf/local.conf"
BBLAYERS_CONF="$BUILD_DIR/conf/bblayers.conf"

if [[ ! -f "$LOCAL_CONF" || ! -f "$BBLAYERS_CONF" ]]; then
    echo "ERROR: Build directory is not initialized: $BUILD_DIR" >&2
    echo "Initialize it using NXP's imx-setup-release.sh first." >&2
    exit 1
fi

if [[ ! -f "$LAYER_DIR/conf/layer.conf" ]]; then
    echo "ERROR: Custom layer.conf not found." >&2
    exit 1
fi

# The layer must be installed in the BSP sources directory.
BSP_DIR="$(cd "$BUILD_DIR/.." && pwd)"
EXPECTED_LAYER="$BSP_DIR/sources/meta-imx93-frdm"

if [[ "$LAYER_DIR" != "$EXPECTED_LAYER" ]]; then
    echo "ERROR: Custom layer must be located at:" >&2
    echo "  $EXPECTED_LAYER" >&2
    echo "Current location: $LAYER_DIR" >&2
    exit 1
fi

# Check for conflicting package format settings before modifying files.
if grep -Eq '^[[:space:]]*PACKAGE_CLASSES[[:space:]]*=' "$LOCAL_CONF" &&
   ! grep -Eq '^[[:space:]]*PACKAGE_CLASSES[[:space:]]*=[[:space:]]*"package_deb"' "$LOCAL_CONF"; then
    echo 'ERROR: PACKAGE_CLASSES must be "package_deb".' >&2
    echo "Review $LOCAL_CONF before running this helper." >&2
    exit 1
fi

# Register the layer without duplicating its entry.
if ! grep -Fq 'sources/meta-imx93-frdm' "$BBLAYERS_CONF"; then
    printf '\nBBLAYERS += "${BSPDIR}/sources/meta-imx93-frdm"\n' \
        >> "$BBLAYERS_CONF"
fi

# Preserve the known-working FRDM-i.MX93 configuration.
if ! grep -Eq '^[[:space:]]*PACKAGE_CLASSES[[:space:]]*=' "$LOCAL_CONF"; then
    printf '\nPACKAGE_CLASSES = "package_deb"\n' >> "$LOCAL_CONF"
fi

if ! grep -Fq 'EXTRA_IMAGE_FEATURES += "package-management"' "$LOCAL_CONF"; then
    printf 'EXTRA_IMAGE_FEATURES += "package-management"\n' >> "$LOCAL_CONF"
fi

if ! grep -Fq 'MACHINE_FEATURES:remove = "jailhouse"' "$LOCAL_CONF"; then
    printf '\n# Standard FRDM-i.MX93 Linux image: no Jailhouse hypervisor\n' \
        >> "$LOCAL_CONF"
    printf 'MACHINE_FEATURES:remove = "jailhouse"\n' >> "$LOCAL_CONF"
fi

echo "FRDM-i.MX93 build configuration updated: $BUILD_DIR"
echo "Custom layer: $LAYER_DIR"
