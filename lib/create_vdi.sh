set -eu

NAME_LABEL="$1"
DISK_SIZE_GB="$2"

function main() {
    create_vdi > /dev/null
    echo "$EXTRA_VDI"
}

function create_vdi() {
    LOCALSR=$(xe sr-list name-label="Local storage" --minimal)
    EXTRA_VDI=$(xe vdi-create name-label="$NAME_LABEL" virtual-size="${DISK_SIZE_GB}GiB" sr-uuid=$LOCALSR type=user)
}

main
