#!/bin/bash
set -eu

THISDIR=$(dirname $(readlink -f $0))
LIBDIR=$(cd $THISDIR && cd .. && cd lib && pwd)

. $LIBDIR/functions.sh

load_config

set +u
DISK_SIZE_GB="$1"
set -u

[ -z "$DISK_SIZE_GB" ] && die_with << EOF
ERROR: Please specify the size of the disk in GiB
EOF

if cat $LIBDIR/list_disks.sh |
    bash $LIBDIR/remote_bash.sh $WORKER_VM_XENSERVER \
    "$WORKER_VM_NAME" | grep -q 1; then
    die_with << EOF
ERROR: It seems that the VM already has a second hard drive
EOF
fi

VDI=$(cat $LIBDIR/create_vdi.sh |
    bash $LIBDIR/remote_bash.sh $WORKER_VM_XENSERVER \
    "extra-vdi" \
    "$DISK_SIZE_GB")

cat $LIBDIR/add_vdi_as_xvdb.sh |
    bash $LIBDIR/remote_bash.sh $WORKER_VM_XENSERVER \
    "$VDI" \
    "$WORKER_VM_NAME"

echo "$VDI"
