FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " file://wpa_supplicant-wlan0.conf"

do_install:append() {
    install -d ${D}/etc/wpa_supplicant

    # Replace placeholders with actual values from local.conf
    sed -e "s|{{SSID}}|${WIFI_SSID}|g" \
        -e "s|{{PASSWORD}}|${WIFI_PSK}|g" \
        -e "s|{{COUNTRY_CODE}}|${WPA_COUNTRY}|g" \
        ${WORKDIR}/wpa_supplicant-wlan0.conf > ${D}/etc/wpa_supplicant/wpa_supplicant-wlan0.conf

    chmod 0644 ${D}/etc/wpa_supplicant/wpa_supplicant-wlan0.conf
}

