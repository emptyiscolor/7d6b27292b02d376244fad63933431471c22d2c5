#!/usr/bin/env bash

# Install Docker Engine from Docker's official Debian/Ubuntu repository.

set -Eeuo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=kernel-dev-common.sh
. "$SCRIPT_DIR/kernel-dev-common.sh"

DOCKER_USER=${DOCKER_USER:-}
DOCKER_DATA_ROOT=${DOCKER_DATA_ROOT:-}

usage() {
    cat <<'EOF'
Usage: sudo ./install-docker.sh [--user USER] [--data-root PATH]

Options:
  --user USER       Add USER to the docker group.
  --data-root PATH  Store Docker state at PATH instead of /var/lib/docker.

The docker group grants root-equivalent access. Omit --user if users should
access Docker only through sudo.
EOF
}

while (($#)); do
    case $1 in
        --user) [[ $# -ge 2 ]] || die "--user requires a value"; DOCKER_USER=$2; shift 2 ;;
        --data-root) [[ $# -ge 2 ]] || die "--data-root requires a value"; DOCKER_DATA_ROOT=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument: $1" ;;
    esac
done

require_root
load_os_release
apt_update
apt_install ca-certificates curl python3

install -d -m 0755 /etc/apt/keyrings
key_tmp=$(mktemp)
trap 'rm -f "$key_tmp"' EXIT
curl --fail --silent --show-error --location \
    "https://download.docker.com/linux/${ID}/gpg" --output "$key_tmp"
install -m 0644 "$key_tmp" /etc/apt/keyrings/docker.asc

docker_suite=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
[[ -n $docker_suite ]] || die "distribution codename is missing from /etc/os-release"
docker_arch=$(dpkg --print-architecture)

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/${ID}
Suites: ${docker_suite}
Components: stable
Architectures: ${docker_arch}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update
apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if [[ -n $DOCKER_DATA_ROOT ]]; then
    [[ $DOCKER_DATA_ROOT == /* ]] || die "Docker data root must be an absolute path"
    install -d -m 0711 "$DOCKER_DATA_ROOT"
    install -d -m 0755 /etc/docker
    DOCKER_DATA_ROOT=$DOCKER_DATA_ROOT python3 - <<'PY'
import json
import os
from pathlib import Path

config_path = Path("/etc/docker/daemon.json")
if config_path.exists():
    try:
        config = json.loads(config_path.read_text())
    except json.JSONDecodeError as exc:
        raise SystemExit(f"refusing to overwrite invalid {config_path}: {exc}")
else:
    config = {}

config["data-root"] = os.environ["DOCKER_DATA_ROOT"]
temporary = config_path.with_suffix(".json.tmp")
temporary.write_text(json.dumps(config, indent=2, sort_keys=True) + "\n")
temporary.chmod(0o644)
temporary.replace(config_path)
PY
    log "configured Docker data root: $DOCKER_DATA_ROOT"
fi

add_user_to_group "$DOCKER_USER" docker

if systemd_is_running; then
    systemctl enable --now docker.service containerd.service
    if [[ -n $DOCKER_DATA_ROOT ]]; then
        systemctl restart docker.service
    fi
    docker info >/dev/null
else
    log "systemd is not running; Docker was installed but not started"
fi

log "Docker Engine and the Compose/Buildx plugins are installed"
