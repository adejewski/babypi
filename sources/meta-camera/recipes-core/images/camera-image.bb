DESCRIPTION = "Custom image with MediaMTX installed"
LICENSE = "MIT"

IMAGE_INSTALL:append = " \
    mediamtx \
    wpa-supplicant \
"

# Enable SSH server
IMAGE_FEATURES:append = " ssh-server-dropbear"

inherit core-image
