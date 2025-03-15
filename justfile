# Justfile for Yocto RPI5 Setup

# Set the build directory and configuration directory
build_dir := "build"
conf_dir := "build/conf"

docker_image := "yocto-builder:latest"
yocto_image := "camera-image"
machine := "raspberrypi0-2w-64"

# Ensure Just uses bash
set shell := ["bash", "-c"]

# Setup task to configure the build environment
@setup:
    echo "Setting up Yocto environment..."
    mkdir -p {{conf_dir}}
    cp --update=none sources/meta-camera/conf/local.conf.sample {{conf_dir}}/local.conf
    cp --update=none sources/meta-camera/conf/bblayers.conf.sample {{conf_dir}}/bblayers.conf
    echo "Setup complete! You can now build using 'just build'"

# Clean build directory
@clean:
    echo "Cleaning build directory..."
    rm -rf {{build_dir}}/tmp {{build_dir}}/sstate-cache
    echo "Build directory cleaned."

# Fetch latest Yocto submodules
@update:
    echo "Updating Yocto submodules..."
    git submodule update --init --recursive
    echo "Submodules updated."

# Build the Yocto image for RPI5
@build:
    echo "Starting Yocto build {{yocto_image}}..."
    source sources/poky/oe-init-build-env {{build_dir}} && bitbake {{yocto_image}}

@build-from-docker:
    echo "Starting docker..."
    docker run --rm \
        -v {{justfile_directory()}}:{{justfile_directory()}} \
        -w {{justfile_directory()}} \
        --user $(id -u):$(id -g) \
        {{docker_image}} \
        just build

@populate-sdk:
    echo "Populating SDK for {{yocto_image}}..."
    source sources/poky/oe-init-build-env {{build_dir}} && bitbake {{yocto_image}} -c populate_sdk

@populate-sdk-from-docker:
    echo "Starting docker..."
    docker run --rm \
        -v {{justfile_directory()}}:{{justfile_directory()}} \
        -w {{justfile_directory()}} \
        --user $(id -u):$(id -g) \
        {{docker_image}} \
        just populate-sdk

@docker-run:
    echo "Starting docker..."
    docker run --rm -it \
        -v {{justfile_directory()}}:{{justfile_directory()}} \
        -w {{justfile_directory()}} \
        --user $(id -u):$(id -g) \
        {{docker_image}} \
        bash

@docker-build:
    echo "Building docker image..."
    docker build . -t {{docker_image}}
    echo "Finished and tagged the image to {{docker_image}}"

@flash device:
    echo "Checking the device {{device}}..." && \
    size=$(lsblk {{device}} -d -r -o SIZE -n -b | awk '{print $1 / (1024*1024*1024)}') && \
    if [ -z "$size" ]; then echo "Error: Device {{device}} not found!" && exit 1; fi && \
    if [ "$(echo "$size > 80" | bc)" -eq 1 ]; then echo "Error: Refusing to write to a device larger than 80GB ($size GB)" && exit 1; fi && \
    echo "WARNING: This will erase all data on {{device}} ($size GB). Continue? (yes/no)" && read answer && if [ "$answer" != "yes" ]; then echo "Aborted." && exit 1; fi && \
    echo "Flashing Yocto image({{yocto_image}}) to {{device}}..."
    bzcat build/tmp/deploy/images/{{machine}}/{{yocto_image}}-{{machine}}.rootfs.wic.bz2 | sudo dd of={{device}} status=progress
    sync
