DESCRIPTION = "Custom image with MediaMTX installed"
LICENSE = "MIT"

IMAGE_INSTALL:append = " \
    mediamtx \
    wpa-supplicant \
    avahi-daemon \
    tzdata \
    gstreamer1.0 \
    gstreamer1.0-rtsp-server \
    gstreamer1.0-plugins-base \
    alsa-utils \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
"


# Enable SSH server
IMAGE_FEATURES:append = " ssh-server-dropbear"

inherit core-image
