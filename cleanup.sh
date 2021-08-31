#!/bin/bash
# Cleanup last build's leftovers first.
if [[ -d build/.tmp ]]; then
	echo "Unmounting .tmp recursive..."
	umount --recursive build/.tmp || echo "Tried to umount .tmp but failed"
	echo "Removing .tmp..."
	rm --one-file-system --force --recursive build/.tmp # Stop if this fails. Things are hanging.
fi

if [[ -d build/output/debug ]]; then
	echo "Cleaning previous run output/debug..."
	rm -rf build/output/debug
fi

if [[ -d build/output/images ]]; then
	echo "Cleaning previous run output/images..."
	rm -rf build/output/images
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
