#!/usr/bin/env bash

# One-shot Debian/Ubuntu host setup for Linux kernel development and debugging.

set -Eeuo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=kernel-dev-common.sh
. "$SCRIPT_DIR/kernel-dev-common.sh"

TARGET_USER=${TARGET_USER:-}
DOCKER_DATA_ROOT=${DOCKER_DATA_ROOT:-}
INSTALL_DOCKER=1
INSTALL_QEMU=1

usage() {
    cat <<'EOF'
Usage: sudo ./setup-linux-kernel-dev.sh [options]

One-shot setup for building and debugging Linux kernels on Debian or Ubuntu.

Options:
  --user USER              Add USER to docker, kvm, and libvirt groups.
  --docker-data-root PATH  Store Docker state outside /var/lib/docker.
  --skip-docker            Do not install Docker Engine.
  --skip-qemu              Do not install QEMU/libvirt.
  -h, --help               Show this help.

Examples:
  sudo ./setup-linux-kernel-dev.sh --user "$USER"
  sudo ./setup-linux-kernel-dev.sh --docker-data-root /mnt/data/docker
EOF
}

while (($#)); do
    case $1 in
        --user) [[ $# -ge 2 ]] || die "--user requires a value"; TARGET_USER=$2; shift 2 ;;
        --docker-data-root) [[ $# -ge 2 ]] || die "--docker-data-root requires a value"; DOCKER_DATA_ROOT=$2; shift 2 ;;
        --skip-docker) INSTALL_DOCKER=0; shift ;;
        --skip-qemu) INSTALL_QEMU=0; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

require_root
load_os_release

log "setting up Linux kernel development host on ${PRETTY_NAME}"
apt_update
export KERNEL_DEV_SKIP_APT_UPDATE=1

"$SCRIPT_DIR/install-kernel-dev-tools.sh"

if ((INSTALL_QEMU)); then
    qemu_args=()
    [[ -n $TARGET_USER ]] && qemu_args+=(--user "$TARGET_USER")
    "$SCRIPT_DIR/install-qemu.sh" "${qemu_args[@]}"
fi

if ((INSTALL_DOCKER)); then
    docker_args=()
    [[ -n $TARGET_USER ]] && docker_args+=(--user "$TARGET_USER")
    [[ -n $DOCKER_DATA_ROOT ]] && docker_args+=(--data-root "$DOCKER_DATA_ROOT")
    "$SCRIPT_DIR/install-docker.sh" "${docker_args[@]}"
fi

verify_args=()
((INSTALL_QEMU)) && verify_args+=(--expect-qemu)
((INSTALL_DOCKER)) && verify_args+=(--expect-docker)
"$SCRIPT_DIR/verify-kernel-dev-host.sh" "${verify_args[@]}"

log "setup complete"
if [[ -n $TARGET_USER ]]; then
    log "log out and back in before using Docker, KVM, or libvirt as '$TARGET_USER'"
fi
