#!/usr/bin/env bash

# Read-only verification for the Linux kernel development host setup.

set -Eeuo pipefail

EXPECT_QEMU=0
EXPECT_DOCKER=0

usage() {
    cat <<'EOF'
Usage: ./verify-kernel-dev-host.sh [--expect-qemu] [--expect-docker]

Checks required compiler/build commands and, when requested, QEMU and Docker.
This script does not modify the host.
EOF
}

while (($#)); do
    case $1 in
        --expect-qemu) EXPECT_QEMU=1; shift ;;
        --expect-docker) EXPECT_DOCKER=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'ERROR: unknown argument: %s\n' "$1" >&2; exit 2 ;;
    esac
done

missing=0

check_command() {
    local command_name=$1
    if command -v "$command_name" >/dev/null 2>&1; then
        printf 'ok      %-18s %s\n' "$command_name" "$(command -v "$command_name")"
    else
        printf 'missing %s\n' "$command_name" >&2
        missing=1
    fi
}

for command_name in bash bc bison clang flex gcc gdb git ld.lld make pahole python3 sparse; do
    check_command "$command_name"
done

if ((EXPECT_QEMU)); then
    check_command qemu-system-x86_64
    check_command qemu-img
    check_command virsh
    if [[ -e /dev/kvm ]]; then
        printf 'ok      %-18s present\n' /dev/kvm
    else
        printf 'notice  %-18s absent (TCG software emulation remains available)\n' /dev/kvm
    fi
fi

if ((EXPECT_DOCKER)); then
    check_command docker
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
        printf 'ok      %-18s available\n' 'docker compose'
    else
        printf 'missing docker compose plugin\n' >&2
        missing=1
    fi
fi

if ((missing)); then
    printf 'Kernel development host verification failed.\n' >&2
    exit 1
fi

printf 'Kernel development host verification passed.\n'
