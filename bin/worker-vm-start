#!/bin/bash
set -eu

THISDIR=$(dirname $(readlink -f $0))
LIBDIR=$(cd $THISDIR && cd .. && cd lib && pwd)

. $LIBDIR/functions.sh

load_config

cat $LIBDIR/get_worker.sh |
    bash $LIBDIR/remote_bash.sh $WORKER_VM_XENSERVER \
    "$WORKER_VM_NETWORKING" \
    "$WORKER_VM_NAME" \
    "$WORKER_VM_XVA"
