# Work around dpkg-native pathname canonicalization failures under pseudo.
# Use --instdir instead of --root for target rootfs package operations.

do_install:append:class-native() {
    sed -i 's/--root=#ROOTFS#/--instdir=#ROOTFS#/g' \
        ${D}${sysconfdir}/apt/apt.conf.sample
}
