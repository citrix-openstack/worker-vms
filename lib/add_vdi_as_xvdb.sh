set -eu

VDI="$1"
VM_NAME="$2"

VM=$(xe vm-list name-label="$VM_NAME" --minimal)

VBD=$(xe vbd-create vm-uuid=$VM vdi-uuid=$VDI device=1)

xe vbd-plug uuid=$VBD
