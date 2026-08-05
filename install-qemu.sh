#!/usr/bin/env bash

# Install QEMU/KVM and the utilities commonly used by kernel developers.

set -Eeuo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=kernel-dev-common.sh
. "$SCRIPT_DIR/kernel-dev-common.sh"

QEMU_USER=${QEMU_USER:-}

usage() {
    cat <<'EOF'
Usage: sudo ./install-qemu.sh [--user USER]

Installs QEMU, KVM/libvirt, UEFI firmware, cloud-image helpers, and networking
utilities. USER is added to the kvm and libvirt groups when those groups exist.
EOF
}

while (($#)); do
    case $1 in
        --user) [[ $# -ge 2 ]] || die "--user requires a value"; QEMU_USER=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

require_root
load_os_release
apt_update

apt_install \
    bridge-utils cloud-image-utils dnsmasq-base genisoimage iproute2 iptables \
    libvirt-clients libvirt-daemon-system ovmf qemu-system-x86 qemu-utils \
    socat virtinst
apt_install_available swtpm

add_user_to_group "$QEMU_USER" kvm
add_user_to_group "$QEMU_USER" libvirt

if systemd_is_running; then
    systemctl enable --now libvirtd.service
else
    log "systemd is not running; libvirtd was installed but not started"
fi

if [[ -e /dev/kvm ]]; then
    log "/dev/kvm is present; hardware acceleration is available to authorized users"
else
    log "/dev/kvm is absent; QEMU will use software emulation until KVM is enabled"
fi

log "QEMU setup is complete"
