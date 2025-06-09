#!/usr/bin/env bash

# References:
# * https://docs.rockylinux.org/gemstones/setup_local_repo/
# * https://forum.level1techs.com/t/how-to-create-a-local-mirror-of-rocky-linux-9-3-repo-when-rsync-isnt-available-anymore/219934
# updated: tuan t. pham
# It's about 232 GB for x86_64 binary packages
# Another copy is at https://github.com/neofob/tscripts
# NOTE:
# * The URL for webpage has "pub"
# * The URI for rsync does not have "pub"


REPO_BASE_DIR=${REPO_BASE_DIR:-"/opt/www/rpm-mirror"}
REPO_VERSION=${REPO_VERSION:-"9"}
REPO_EXCLUDES_LIST=${REPO_EXCLUDES_LIST:-"./excludes.txt"}
REPO_BASE_URL=${REPO_BASE_URL:-"mirror.cs.vt.edu/pub/rocky"}
REPO_BASE_EPEL_URL=${REPO_BASE_EPEL_URL:-"mirror.cs.vt.edu/pub/epel"}
REPO_URI=${REPO_URI:-"mirror.cs.vt.edu/rocky/${REPO_VERSION}"}
REPO_EPEL_URI=${REPO_EPEL_URI:-"mirror.cs.vt.edu/epel/${REPO_VERSION}/Everything"}

REPO_ROCKY_V_BASE_DIR="${REPO_BASE_DIR}/pub/rocky/${REPO_VERSION}"
REPO_ROCKY_EPEL_V_BASE_DIR="${REPO_ROCKY_V_BASE_DIR}/Everything"

mkdir -p "${REPO_ROCKY_V_BASE_DIR}" "${REPO_ROCKY_EPEL_V_BASE_DIR}"

if [[ ! -d "$REPO_BASE_DIR" ]]; then
    echo "Base repo directory does not exist: $REPO_BASE_DIR" >&2
    exit 1
fi

rsync_opts=(
    --archive
    --verbose
    --compress
    --human-readable
    --progress
    --delete
)

keys=(
    RPM-GPG-KEY-rockyofficial
    RPM-GPG-KEY-Rocky-$REPO_VERSION
)
epel_key="RPM-GPG-KEY-EPEL-${REPO_VERSION}"

if [[ -f "$REPO_EXCLUDES_LIST" ]]; then
    rsync_opts+=('--exclude-from='"$REPO_EXCLUDES_LIST")
fi

rsync_cmd() {
    local src="$1"
    local dest="$2"

    echo "rsync ${rsync_opts[@]} $src $dest"
    rsync "${rsync_opts[@]}" "$src" "$dest" || exit 1
}

download_key() {
    local key="$1"
    local url="$2"

    if [[ ! -e ${REPO_BASE_DIR}/${key} ]]; then
        wget -P "$REPO_BASE_DIR" "https://${url}/${key}" || exit 1
    fi
}

rsync_cmd "rsync://${REPO_URI}/" "${REPO_ROCKY_V_BASE_DIR}/"
echo

rsync_cmd "rsync://${REPO_EPEL_URI}/" "${REPO_ROCKY_EPEL_V_BASE_DIR}/"
echo

for key in "${keys[@]}"; do
    download_key "$key" "$REPO_BASE_URL"
done

download_key "$epel_key" "$REPO_BASE_EPEL_URL"
