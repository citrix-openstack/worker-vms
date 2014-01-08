#!/bin/bash
set -eu

VM="$1"
IMAGE_LOCATION="$2"

function main() {
    export_vm
}

function export_vm() {
    local protocol
    local vm

    protocol=$(echo "$IMAGE_LOCATION" | cut -d ":" -f 1)

    if [ "$protocol" = "nfs" ]; then
        local nfs_server
        local path_to_image
        local path_to_image_dir
        local image_filename
        local tmpdir

        local local_image_path

        nfs_server=$(echo "$IMAGE_LOCATION" | cut -d ":" -f 2)
        path_to_image=$(echo "$IMAGE_LOCATION" | cut -d ":" -f 3)
        path_to_image_dir=$(dirname $path_to_image)
        image_filename=$(basename $path_to_image)

        tmpdir=$(mktemp -d)
        local_image_path="$tmpdir/$image_filename"

        mount -t nfs "$nfs_server:$path_to_image_dir" "$tmpdir"
        rm -f "$local_image_path" || true
        xe vm-export filename="$local_image_path" compress=True uuid=$VM
        umount $tmpdir
    else
        die_with << EOF
ERROR: unrecognised protocol: $protocol specified by: $IMAGE_LOCATION
EOF
    fi
}

main
