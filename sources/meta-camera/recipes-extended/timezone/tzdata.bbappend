do_install:append() {
    ln -sf /usr/share/zoneinfo/${TIMEZONE} ${D}/etc/localtime
    echo "${TIMEZONE}" > ${D}/etc/timezone
}