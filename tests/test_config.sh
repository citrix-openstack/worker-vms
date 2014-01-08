set -eux

THISDIR=$(dirname $(readlink -f $0))
LIBDIR=$(cd $THISDIR && cd .. && cd lib && pwd)

. "$LIBDIR/functions.sh"


CONFIG=$(mktemp)
WORKER_VM_CONFIG=$CONFIG load_config

rm $CONFIG
(
    WORKER_VM_CONFIG=$CONFIG load_config
) && echo "script should fail if config file does not exist" | die_with || true

echo "All tests passed"
