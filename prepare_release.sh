#!/bin/bash

# Run in build/output dir
MATRIX_BOARD="$1"
CLOUD_IMAGE="${CLOUD_IMAGE:-yes}"
CLOUD_IMAGE_DESC="cli"
[[ "${CLOUD_IMAGE}" == "yes" ]] && CLOUD_IMAGE_DESC="cloud"

echo "Preparing release Markdown fragment for this run..."
cat <<EOD >release.md
- \`${MATRIX_BOARD}\`: ${MATRIX_DESC}
EOD

echo "Compressing files..."
find ./images -type f -size +1M | cut -d "/" -f 3 | while read fn; do
	echo "Compressing '$fn'..."

	FULL_SRC_FN="images/${fn}"
	ORIGINAL_SIZE="$(du -h "${FULL_SRC_FN}" | tr -s "\t" " " | cut -d " " -f 1)"
	# Target fn, replace stuff.
	TARGET_FN="$(echo -n "${fn}" | sed -e "s/Armbian.*-trunk_/Armbian_rpardini_${RELEASE_TAG}_/").xz"
	FULL_TARGET_FN="images/${TARGET_FN}"

	echo "Compressing ${FULL_SRC_FN} to ${FULL_TARGET_FN}"
	pixz -0 "${FULL_SRC_FN}" "${FULL_TARGET_FN}"
	XZ_SIZE="$(du -h "${FULL_TARGET_FN}" | tr -s "\t" " " | cut -d " " -f 1)"

	echo "  - [${TARGET_FN}](https://github.com/rpardini/armbian-release/releases/download/${RELEASE_TAG}/${TARGET_FN}) _(xz:${XZ_SIZE}b, original:${ORIGINAL_SIZE}b)_" >>release.md
done

echo "Listing images contents:"
ls -laht ./images || true

# GH Releases/packages has a limit of 2Gb per artifact.
# For not just remove, @TODO: in the future could split.
echo "Removing too-big images: "
find ./images -type f -size +2G
find ./images -type f -size +2G -exec rm -f {} ";"

# Tar up the logs
LOGS_TARBALL="images/build.logs.${MATRIX_BOARD}.${CLOUD_IMAGE_DESC}.tar"
echo "Tarring up the build logs... ${LOGS_TARBALL}.xz"
tar cf "${LOGS_TARBALL}" debug
pixz -0 "${LOGS_TARBALL}" "${LOGS_TARBALL}.xz"

echo "Chown images back to regular user (${REGULAR_USER})..."
chown -R "${REGULAR_USER}":"${REGULAR_USER}" ./images || true
