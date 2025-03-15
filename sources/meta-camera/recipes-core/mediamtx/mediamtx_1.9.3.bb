SUMMARY = "MediaMTX / rtsp-simple-server is a ready-to-use and zero-dependency server and proxy that allows users to publish, read and proxy live video and audio streams."
GO_IMPORT = "github.com/bluenviron/mediamtx"
HOMEPAGE = "https://${GO_IMPORT}"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=77fd2623bd5398430be5ce60489c2e81"

inherit systemd

SRC_URI = "git://${GO_IMPORT};branch=main;protocol=https"
SRCREV = "6cd7487857dc6ee8b82cff1f45c900ad7e3d6362"

SRC_URI += "file://mediamtx.yml"
SRC_URI += "file://picam.service"

S = "${WORKDIR}/git"

SYSTEMD_SERVICE:${PN} = "picam.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_compile[network] = "1"
DEPENDS += " go-native libcamera"

TARGET_GOARCH = "${@'arm64' if d.getVar('TARGET_ARCH') == 'aarch64' else \
                'arm' if d.getVar('TARGET_ARCH') == 'arm' else \
                'amd64' if d.getVar('TARGET_ARCH') == 'x86_64' else \
                '386' if d.getVar('TARGET_ARCH') == 'i686' else \
                'riscv64' if d.getVar('TARGET_ARCH') == 'riscv64' else ''}"
export TARGET_GOARCH

do_compile() {
    export CC="${BUILD_CC}"

    go generate ./...

    CGO_ENABLED=0 GOOS=linux GOARCH=${TARGET_GOARCH} go build .
}

do_install() {
    # Install binary
    install -d ${D}${bindir}
    install -m 0755 ${B}/mediamtx ${D}${bindir}/mediamtx

    # Install config
    install -d ${D}${sysconfdir}/mediamtx
    if [ ! -f ${D}${sysconfdir}/mediamtx/mediamtx.yml ]; then
        install -m 0644 ${WORKDIR}/mediamtx.yml ${D}${sysconfdir}/mediamtx/mediamtx.yml
    fi

    # Install systemd service
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/picam.service ${D}${systemd_system_unitdir}/picam.service
}
