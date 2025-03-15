FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://avahi-daemon.conf"

do_install:append() {
    install -d ${D}${sysconfdir}/avahi/
    install -m 0644 ${WORKDIR}/avahi-daemon.conf ${D}${sysconfdir}/avahi/
}