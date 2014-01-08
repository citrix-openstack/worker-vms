function die_with() {
    cat >&2
    exit 1
}

function load_config() {
    local config
    config=${WORKER_VM_CONFIG:-"$HOME/.worker-vms"}

    [ -e "$config" ] || die_with << EOF
ERROR: config file not found.
either create $HOME/.worker-vms or set the WORKER_VM_CONFIG environment
variable.
EOF

    . "$config"
}
