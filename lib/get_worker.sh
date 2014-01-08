#!/bin/bash
set -eux

NETWORKING="$1"
SLAVENAME="$2"
IMAGE_LOCATION="$3"

FRESHSLAVE="${SLAVENAME}-fresh"
IMAGENAME="${3:-slave}"

function resolve_to_network() {
    local name_or_bridge
    local result

    name_or_bridge="$1"

    result=$(xe network-list name-label=$1 --minimal)
    if [ -z "$result" ]; then
        result=$(xe network-list bridge=$1 --minimal)
    fi

    if [ -z "$result" ]; then
        echo "No network found with name-label/bridge $name_or_bridge" >&2
        exit 1
    fi

    echo "$result"
}

function wipe_networking() {
    local vm

    vm=$1

    IFS=","
    for vif in $(xe vif-list vm-uuid=$vm --minimal); do
        xe vif-destroy uuid=$vif
    done
    unset IFS
}

function setup_networking() {
    local network_configs
    local vm

    vm="$1"
    network_configs="$2"

    local netname
    local device
    local net

    IFS=","
    for netconfig in $network_configs; do
        if [ "$netconfig" == "none" ]; then
            continue
        fi
        device=$(echo $netconfig | cut -d"=" -f 1)
        netname=$(echo $netconfig | cut -d"=" -f 2)

        net=$(resolve_to_network $netname)
        if ! xe vif-create device=$device vm-uuid=$vm network-uuid=$net >/dev/null; then
            echo "Failed to create network interface" >&2
            exit 1
        fi
    done
    unset IFS
}

function import_vm() {
    local protocol
    local vm

    protocol=$(echo "$IMAGE_LOCATION" | cut -d ":" -f 1)

    if [ "$protocol" = "nfs" ]; then
        local nfs_server
        local path_to_image
        local path_to_image_dir
        local image_filename
        local tmpdir

        nfs_server=$(echo "$IMAGE_LOCATION" | cut -d ":" -f 2)
        path_to_image=$(echo "$IMAGE_LOCATION" | cut -d ":" -f 3)
        path_to_image_dir=$(dirname $path_to_image)
        image_filename=$(basename $path_to_image)

        tmpdir=$(mktemp -d)
        mount -t nfs "$nfs_server:$path_to_image_dir" "$tmpdir"
        VM=$(xe vm-import filename="$tmpdir/$image_filename")
        umount $tmpdir
    else
        exit 1
    fi
}

if [ -z "$(xe snapshot-list name-label="$FRESHSLAVE" --minimal)" ]
then
    xe vm-uninstall vm="$SLAVENAME" force=true || true
    import_vm 
    xe vm-param-set uuid="$VM" name-label="$SLAVENAME"

    xe vm-snapshot vm="$SLAVENAME" new-name-label="$FRESHSLAVE" > /dev/null
fi

SNAP=$(xe snapshot-list name-label="$FRESHSLAVE" --minimal)
xe snapshot-revert snapshot-uuid=$SNAP

VM=$(xe vm-list name-label="$SLAVENAME" --minimal)

wipe_networking $VM
setup_networking $VM "$NETWORKING"

xe vm-start uuid=$VM

while [ "$(xe vm-param-get uuid=$VM param-name=power-state)" != "running" ];
do
    sleep 1
done

while true
do
    SLAVE_IP=$(xe vm-param-get uuid=$VM param-name=networks | sed -ne 's,^.*0/ip: \([0-9.]*\).*$,\1,p')
    [ -z "$SLAVE_IP" ] || { echo "ubuntu@$SLAVE_IP"; exit 0; }
    sleep 1
done
