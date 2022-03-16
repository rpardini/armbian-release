#!/bin/bash

# GH_FULL_RUN_ID carries the full run id + number + attempt, and should be unique.
# Use a marker file to determine if this is the first run on a given runner.
# If it is, clean the output/debs left there by the previous build, so we don't
#  accumulate .debs eternally.
echo "Starting cleanup.sh. GH_FULL_RUN_ID: ${GH_FULL_RUN_ID}"
export GH_RUN_MARKER_DIR="/opt/armbian_github_markers"
mkdir -p "${GH_RUN_MARKER_DIR}"
export GH_RUN_MARKER_FILE="${GH_RUN_MARKER_DIR}/${GH_FULL_RUN_ID}.marker"
export IS_FIRST_RUN="no"
if [[ -f "${GH_RUN_MARKER_FILE}" ]]; then
	echo "Found ${GH_RUN_MARKER_FILE} -- this is NOT the first run."
else
	echo "Can't find ${GH_RUN_MARKER_FILE} -- this is the first run."
	export IS_FIRST_RUN="yes"
	echo "Marking ${GH_RUN_MARKER_FILE} for the next run to find."
	touch "${GH_RUN_MARKER_FILE}"
fi

# Cleanup last build's leftovers first.
if [[ -d build/.tmp ]]; then
	echo "Unmounting .tmp recursive..."
	umount --recursive build/.tmp || echo "Tried to umount .tmp but failed"
	echo "Removing .tmp..."
	rm --one-file-system --force --recursive build/.tmp # Stop if this fails. Things are hanging.
fi

if [[ -d build/output/logs ]]; then
	echo "Cleaning previous run output/logs..."
	rm -rf build/output/logs
fi

if [[ -d build/output/images ]]; then
	echo "Cleaning previous run output/images..."
	rm -rf build/output/images
fi

if [[ "${IS_FIRST_RUN}" == "yes" ]]; then
	echo "First run detected, cleaning previous run output/debs"...
	rm -rf build/output/debs build/output/debs-beta
fi

if [[ -d preserved_cache ]]; then
	echo "Cleaning leftover cache..."
	rm -rf preserved_cache
fi

if [[ -d preserved_output ]]; then
	echo "Cleaning leftover output..."
	rm -rf preserved_output
fi

if [[ -d build/cache ]]; then
	echo "Moving build/cache to preserved_cache..."
	mv build/cache preserved_cache
fi

if [[ -d build/output ]]; then
	echo "Moving build/output to preserved_output..."
	mv build/output preserved_output
fi

echo "Chown build dir back to regular user (${REGULAR_USER})..."
chown -R "${REGULAR_USER}":"${REGULAR_USER}" build || true

echo "Show ccache status"
ccache -s

echo "Restart apt-cacher-ng."
systemctl restart apt-cacher-ng.service
systemctl status apt-cacher-ng.service

echo "Done cleanup run."
