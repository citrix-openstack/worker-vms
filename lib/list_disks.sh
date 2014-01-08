set -eu

VM_NAME="$1"

function main() {
    list_devices
}

function list_devices() {
    VM=$(xe vm-list name-label="$VM_NAME" --minimal)

    IFS=","
    for userdev in $(xe vbd-list vm-uuid=$VM params=userdevice --minimal); do
        echo "$userdev"
    done
}

main
