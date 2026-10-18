# Invoke Kbuild from the kernel source tree, not the artifacts directory.
EXTRA_OEMAKE = "KERNELDIR=${STAGING_KERNEL_DIR} -C ${STAGING_KERNEL_DIR} M=${S}"
