#!/usr/bin/env bash

# Install a compiler toolchain and common Linux kernel build/debug utilities.

set -Eeuo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=kernel-dev-common.sh
. "$SCRIPT_DIR/kernel-dev-common.sh"

usage() {
    cat <<'EOF'
Usage: sudo ./install-kernel-dev-tools.sh

Installs GCC/LLVM, Linux kernel build dependencies, and debugging utilities.
EOF
}

case ${1:-} in
    -h|--help) usage; exit 0 ;;
    '') ;;
    *) die "unknown argument: $1" ;;
esac

require_root
load_os_release
apt_update

apt_install \
    bc bison build-essential ca-certificates ccache clang cpio curl dwarves \
    flex gdb git kmod libcap-dev libdw-dev \
    libelf-dev libncurses-dev libpci-dev libssl-dev libudev-dev lld llvm \
    make openssl pkg-config python3 python3-pip python3-venv rsync sparse \
    strace tar unzip wget xz-utils zstd
apt_install_available gcc-multilib g++-multilib

# Package names for perf and tracing differ between Debian and Ubuntu.
if [[ $ID == ubuntu ]]; then
    apt_install_available linux-tools-common "linux-tools-$(uname -r)" trace-cmd
else
    apt_install_available linux-perf trace-cmd
fi

log "kernel build and debug tools are installed"
log "example LLVM build: make LLVM=1 defconfig && make LLVM=1 -j\$(nproc)"
