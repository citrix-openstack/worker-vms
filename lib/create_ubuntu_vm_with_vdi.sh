set -eu

VDI="$1"
RAM="$2"
NAME_LABEL="$3"
VM=""

{

UBUTEMPLATE=$(xe template-list name-label="Ubuntu Lucid Lynx 10.04 (64-bit)" --minimal)
VM=$(xe vm-clone uuid=$UBUTEMPLATE new-name-label="$NAME_LABEL")
xe vm-param-set uuid=$VM is-a-template=false
xe vm-param-set uuid=$VM name-description="$NAME_LABEL"
xe vm-memory-limits-set static-min=$RAM static-max=$RAM dynamic-min=$RAM dynamic-max=$RAM uuid=$VM
VBD=$(xe vbd-create vm-uuid=$VM vdi-uuid=$VDI device=0 bootable=true)
xe vm-param-set uuid=$VM PV-bootloader=pygrub

} >&2

echo "$VM"
