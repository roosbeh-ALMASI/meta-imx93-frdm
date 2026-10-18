# Reproducible FRDM-i.MX93 U-Boot source snapshot.
SRCBRANCH = "frdm-imx93-lf-2025.04"

SRC_URI = "git://github.com/roosbeh-ALMASI/uboot-imx.git;protocol=https;branch=${SRCBRANCH}"
SRCREV = "bf822219cd73af410287036cbdba3b378f9b0267"

# Preserve the original NXP U-Boot local version suffix.
LOCALVERSION = "-lf_v2025.04"
