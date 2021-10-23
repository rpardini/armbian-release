#!/bin/bash

# This is run in the build dir, with cache in place, hopefully with previous runs rootfs and sources from the same machine
# output/debs might or not be populated with previous runs on the same machine
# output/images and output/debug are clean
# Parameters are as follows

declare -i BUILD_OK=1
MATRIX_BOARD="$1"
EXTRA_VARS="$2"
BUILD_VARS="CLEAN_LEVEL=none PROGRESS_LOG_TO_FILE=yes PROGRESS_DISPLAY=none DEB_COMPRESS=none"

# Write the userpatches/VERSION file with our info.
# RELEASE_TAG needs to start with a digit otherwise Debian packaging rules will be violated
echo "${RELEASE_TAG}-${RELEASE_OWNER}" > userpatches/VERSION

# Editing that file causes compile.sh to find a dirty git checkout and refuse to work, so
touch .ignore_changes

echo "Starting build for ${MATRIX_BOARD} - CLOUD_IMAGE:${CLOUD_IMAGE}"
USERCONFIG="rpardini-generic"

if [[ -f "userpatches/config-rpardini-${MATRIX_BOARD}.conf" ]]; then
	echo "Using rpardini userpatches config for ${MATRIX_BOARD}..."
	USERCONFIG="rpardini-${MATRIX_BOARD}"
	BUILD_VARS="${BUILD_VARS} BOARD=${MATRIX_BOARD}"
fi

echo "Using userconfig '${USERCONFIG}' for ${MATRIX_BOARD}..."

echo "::notice file=${MATRIX_BOARD}::Building CLOUD_IMAGE=\"${CLOUD_IMAGE}\" ${BUILD_VARS} ./compile.sh \"${USERCONFIG}\" ${BUILD_VARS} ${EXTRA_VARS}"
# shellcheck disable=SC2086 # I *want* to expand EXTRA_VARS/BUILD_VARS as vars.
CLOUD_IMAGE="${CLOUD_IMAGE}" ${BUILD_VARS} ./compile.sh "${USERCONFIG}" ${BUILD_VARS} ${EXTRA_VARS} || BUILD_OK=0

# Remove stuff we added before the build, so working copy is clean again.
rm -f .ignore_changes userpatches/VERSION || true

# Done, chown the output back to regular user.
echo "output chown to ${REGULAR_USER}"
chown -R "${REGULAR_USER}":"${REGULAR_USER}" output || true

if [[ $BUILD_OK -gt 0 ]]; then
	echo "OK"
	exit 0
else
	echo "::error file=${MATRIX_BOARD}::Build failed"
	exit 1
fi
