#!/bin/bash
# Post-build script — runs after rootfs is built, before image generation

TARGET_DIR=$1

# Create extlinux boot config
mkdir -p "${TARGET_DIR}/boot/extlinux"
cp "${BR2_EXTERNAL_SMARTPI_PATH}/board/smartpi-one/boot/extlinux.conf" \
   "${TARGET_DIR}/boot/extlinux/"
