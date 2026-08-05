#!/usr/bin/env bash

# Shared helpers for the kernel development host setup scripts.

set -Eeuo pipefail

log() {
    printf '[kernel-dev] %s\n' "$*"
}

die() {
    printf '[kernel-dev] ERROR: %s\n' "$*" >&2
    exit 1
}

require_root() {
    if [[ ${EUID} -ne 0 ]]; then
        die "run this script as root (for example: sudo $0 $*)"
    fi
}

load_os_release() {
    [[ -r /etc/os-release ]] || die "/etc/os-release is missing"
    # shellcheck disable=SC1091
    . /etc/os-release

    case "${ID:-}" in
        debian|ubuntu) ;;
        *) die "unsupported distribution '${ID:-unknown}'; Debian and Ubuntu are supported" ;;
    esac
}

apt_update() {
    if [[ ${KERNEL_DEV_SKIP_APT_UPDATE:-0} != 1 ]]; then
        log "refreshing APT metadata"
        apt-get update
    fi
}

apt_install() {
    log "installing packages: $*"
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

apt_install_available() {
    local package
    local -a available=()

    for package in "$@"; do
        if apt-cache show "$package" >/dev/null 2>&1; then
            available+=("$package")
        else
            log "optional package '$package' is unavailable; skipping"
        fi
    done

    if ((${#available[@]})); then
        apt_install "${available[@]}"
    fi
}

systemd_is_running() {
    command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]
}

add_user_to_group() {
    local user=$1
    local group=$2

    [[ -n $user ]] || return 0
    id "$user" >/dev/null 2>&1 || die "user '$user' does not exist"
    getent group "$group" >/dev/null 2>&1 || return 0

    if id -nG "$user" | tr ' ' '\n' | grep -qx "$group"; then
        log "user '$user' is already in group '$group'"
    else
        usermod -aG "$group" "$user"
        log "added '$user' to group '$group' (log out and back in to apply it)"
    fi
}
