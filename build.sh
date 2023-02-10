#!/bin/bash

# This is run in the build dir, with cache in place, hopefully with previous runs rootfs and sources from the same machine
# output/debs might or not be populated with previous runs on the same machine
# output/images and output/debug are clean
# Parameters are as follows

declare -i BUILD_OK=1
MATRIX_BOARD="$1"
EXTRA_VARS="$2"
DEFAULT_VARS="CLEAN_LEVEL=none DEB_COMPRESS=none SHOW_LOG=yes DONT_BUILD_ARTIFACTS=kernel,firmware,full_firmware" # SHOW_DEBUG=yes

# Write the userpatches/VERSION file with our info.
# RELEASE_TAG needs to start with a digit otherwise Debian packaging rules will be violated
echo "${RELEASE_TAG}-${RELEASE_OWNER}" > userpatches/VERSION

# Editing that file causes compile.sh to find a dirty git checkout and refuse to work, so
touch .ignore_changes

#echo "Starting build for ${MATRIX_BOARD} - CLOUD_IMAGE:${CLOUD_IMAGE}"

start_time=$(date +%s)

# shellcheck disable=SC2086 # I *want* to expand EXTRA_VARS as vars.
CLOUD_IMAGE="${CLOUD_IMAGE}" BOARD="${MATRIX_BOARD}" ./compile.sh "rpardini-generic" BOARD="${MATRIX_BOARD}" ${DEFAULT_VARS} ${EXTRA_VARS} || BUILD_OK=0

end_time=$(date +%s)
runtime_seconds=$((end_time - start_time))

# Remove stuff we added before the build, so working copy is clean again.
rm -f .ignore_changes userpatches/VERSION || true

if [[ $BUILD_OK -gt 0 ]]; then
	#echo "::notice file=${MATRIX_BOARD}::$(hostname -s) SUCCESSFULLY built ${MATRIX_BOARD} cloud=${CLOUD_IMAGE} ok=${BUILD_OK} in ${runtime_seconds} seconds."
	echo "OK"
	exit 0
else
	echo "::error file=${MATRIX_BOARD}::$(hostname -s) FAILED to build ${MATRIX_BOARD} cloud=${CLOUD_IMAGE} ok=${BUILD_OK} in ${runtime_seconds} seconds."
	exit 1
fi
