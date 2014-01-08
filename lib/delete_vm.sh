set -eu

VM="$1"

VDIS="$(xe vbd-list vm-uuid=$VM params=vdi-uuid --minimal)"

xe vm-uninstall uuid=$VM force=True

IFS=,
for vdi in "$VDIS"; do
    xe vdi-destroy uuid=$vdi || true
done
