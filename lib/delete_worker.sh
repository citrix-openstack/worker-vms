#!/bin/bash

set -eu

VM_NAME="$1"

VM=$(xe vm-list name-label="$VM_NAME" --minimal)

VDIS="$(xe vbd-list vm-uuid=$VM params=vdi-uuid --minimal)"

xe vm-uninstall vm="$VM_NAME" force=True

echo "Destroying VDIS: $VDIS"
IFS=","
for vdi in $VDIS; do
    echo "destroy $vdi"
    xe vdi-destroy uuid=$vdi || true
done
