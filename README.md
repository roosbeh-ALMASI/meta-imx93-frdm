# FRDM-i.MX93 Custom Yocto BSP Layer

Custom Yocto layer for the NXP FRDM-i.MX93 Rev B2 board with
2 GB LPDDR4X memory.

Based on the NXP Linux BSP 6.18.2 release.

## Build configuration

- Machine: `imx93-11x11-lpddr4x-frdm`
- Distribution: `fsl-imx-xwayland`
- Image: `imx-image-core`
- Linux: 6.18.2
- U-Boot: 2025.04
- Host used for initial build: Ubuntu 22.04

## Source repositories

Linux:
https://github.com/roosbeh-ALMASI/linux-imx

- Branch: `frdm-imx93-lf-6.18.2`
- Commit: `725bbfc77d81de7788970d29b69fc8fc6e396033`

U-Boot:
https://github.com/roosbeh-ALMASI/uboot-imx

- Branch: `frdm-imx93-lf-2025.04`
- Commit: `bf822219cd73af410287036cbdba3b378f9b0267`

These repositories contain source snapshots with Git trees matching
the corresponding NXP source revisions, rather than full NXP history.

## Custom build fixes

This layer preserves the workarounds used for the successful BSP build:

1. Pseudo: pin version 1.9.5.
2. Mesa: disable native OpenCL support.
3. APT: use `--instdir` instead of `--root` in the native template.
4. NXP WLAN: invoke Kbuild using the staged kernel source tree.

It also redirects the Linux kernel, Linux headers, and U-Boot recipes
to the GitHub source snapshots above.

## Required build settings

The known-working configuration uses:

```bitbake
PACKAGE_CLASSES = "package_deb"
EXTRA_IMAGE_FEATURES += "package-management"
MACHINE_FEATURES:remove = "jailhouse"
```

## Setup

Initialize the NXP BSP environment using `imx-setup-release.sh`
with the machine and distribution documented above.

Clone this custom layer into:

`sources/meta-imx93-frdm`

From the BSP root, run:

```bash
./sources/meta-imx93-frdm/tools/setup-frdm.sh "$PWD/build-frdm"
```

The helper registers the custom layer and applies the required
build settings. It requires an initialized build directory.

Source the NXP build environment before running BitBake:

```bash
source setup-environment build-frdm
bitbake imx-image-core
```

## Reproducibility status

The initial firmware was successfully built and booted from microSD
using the original NXP source revisions and custom build fixes.

The GitHub source overrides and setup helper have not yet been
validated through a fresh complete image build.

The separate `imx-manifest` repository will pin the remaining
NXP Yocto layers for reproducible checkout.
