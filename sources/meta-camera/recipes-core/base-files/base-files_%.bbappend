do_install:append() {
    # Create systemd network configuration directory
    install -d ${D}${sysconfdir}/systemd/network

    # Create systemd-networkd config for wlan0
    cat << EOF > ${D}${sysconfdir}/systemd/network/10-wlan0.network
[Match]
Name=wlan0

[Network]
DHCP=yes
EOF

    # Enable wpa_supplicant service for wlan0
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
    ln -sf /lib/systemd/system/wpa_supplicant@.service \
        ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
}
