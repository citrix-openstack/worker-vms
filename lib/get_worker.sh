#!/bin/bash
set -eu

SLAVENAME="$2"

function main() {
    get_vm_ip > /dev/null
    echo "${SLAVE_IP:-}"
}

function get_vm_ip() {
    VM=$(xe vm-list name-label="$SLAVENAME" --minimal)

    if [ "$(xe vm-param-get uuid=$VM param-name=power-state)" != "running" ]; then
        log "VM is not running"
        return
    fi

    log "waiting for IP address on interface 0"
    while true
    do
        SLAVE_IP=$(xe vm-param-get uuid=$VM param-name=networks | sed -ne 's,^.*0/ip: \([0-9.]*\).*$,\1,p')
        if [ -n "$SLAVE_IP" ]; then
            break
        fi
        sleep 1
    done
}

function log() {
    local message

    message="$@"
    echo "$message" >&2
}

main
