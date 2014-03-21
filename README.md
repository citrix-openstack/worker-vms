worker-vms
==========

Helper scripts to launch VMs

Dependency: [remote-bash](https://github.com/citrix-openstack/remote-bash) has
to be on the path.

## Launch a VM from an XVA

Make sure you can access the machine. Please note, that `HOST` might include
the username as well:

    echo "ls -la" | remote-bash $HOST

Now create a configuration for this worker:

    cat > worker << EOF
    WORKER_VM_NAME="jenkins"
    WORKER_VM_NETWORKING="0=xenbr0"
    WORKER_VM_XVA="nfs:copper.eng.hq.xensource.com:/exported-vms/slave.xva"
    WORKER_VM_XENSERVER="$HOST"
    EOF

And create the worker:

    WORKER_VM_CONFIG=worker worker-vm-create
