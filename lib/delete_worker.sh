#!/bin/bash

set -eu

VM_NAME="$1"

xe vm-uninstall vm="$VM_NAME" force=True
