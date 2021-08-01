#!/bin/bash

# This is run in the build dir, with cache in place, hopefully with previous runs rootfs and sources from the same machine
# output/debs might or not be populated with previous runs on the same machine
# output/images and output/debug are clean
# Parameters are as follows

declare -i BUILD_OK=0
MATRIX_BOARD="$1"
EXTRA_VARS="$2"
echo "Starting build for ${MATRIX_BOARD} - CLOUD_IMAGE:${CLOUD_IMAGE}"
echo "Starting CLOUD_IMAGE=${CLOUD_IMAGE} ./compile.sh "rpardini-${MATRIX_BOARD}" CLEAN_LEVEL=none ${EXTRA_VARS}"
CLOUD_IMAGE="${CLOUD_IMAGE}" ./compile.sh "rpardini-${MATRIX_BOARD}" CLEAN_LEVEL=none ${EXTRA_VARS} && BUILD_OK=1

# Done, chown the output back to regular use
echo "output chown to ${REGULAR_USER}"
chown -R "${REGULAR_USER}":"${REGULAR_USER}" output || true

if [[ $BUILD_OK -gt 0 ]]; then
	echo "OK"
	exit 0
else
	echo "::error file=${MATRIX_BOARD}::Build failed"
	exit 1
fi
