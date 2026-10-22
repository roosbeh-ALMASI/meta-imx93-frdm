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

The GitHub-based BSP has been successfully built and boot-tested on the NXP FRDM-i.MX93 Rev B2 board with 2 GB LPDDR4X.

### Verified

- Fresh repository initialization and synchronization using the custom `imx-manifest` repository.
- Successful integration of the pinned `meta-imx93-frdm` custom layer.
- Linux kernel 6.18.2 compilation using the pinned GitHub source snapshot.
- U-Boot 2025.04 compilation using the pinned GitHub source snapshot.
- Successful complete `imx-image-core` build.
- Successful flashing to microSD using NXP UUU 1.5.243.
- Successful boot and root login on the physical FRDM-i.MX93 Rev B2 board.
- Running Linux kernel `6.18.2-1.0.0-g725bbfc77d81`.
- Root filesystem mounted from `/dev/mmcblk1p2`, confirming microSD boot.

### Build host and resource configuration

The validated build was performed on Ubuntu 22.04.5 LTS.

To avoid host memory exhaustion during compilation, the following settings were used in `conf/local.conf`:

```bitbake
BB_NUMBER_THREADS = "4"
PARALLEL_MAKE = "-j 4"
PARALLEL_MAKEINST = "-j 4"
```

### Remaining limitation

The successful reproduction build used verified source archives from an existing BSP download cache after some upstream archive downloads failed or produced checksum mismatches.

Therefore, a completely cache-independent build on a clean host has not yet been verified.

The GitHub-based source checkout, complete image compilation, microSD flashing, and physical hardware boot have all been validated.

For the complete checkout, build, and flashing procedure, see:

https://github.com/roosbeh-ALMASI/imx-manifest
