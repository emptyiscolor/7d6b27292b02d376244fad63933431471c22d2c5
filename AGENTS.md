# AGENTS.md

## Project

This repository is a small CloudLab/bootstrap project for provisioning a Linux host with tools such as VirtualBox, Docker, XRDP, FRP/FRPS, and related system configuration. Most files are standalone shell scripts intended to be run manually on a target machine.

## Important Files

- `bootstrap.sh`: top-level bootstrap for editor setup and VirtualBox installation.
- `install-docker.sh`: installs Docker and related host utilities, and rewrites the Docker systemd unit to use a custom data root.
- `install-xrdp.sh`: installs and configures XFCE + XRDP.
- `f_config.sh`: writes FRPS configuration from a base64 payload.
- `README.md`: currently minimal; do not assume it is the source of truth.

## Working Rules

- Treat this repo as operations code: changes can affect package sources, system services, login behavior, and files under `/etc`, `/usr/local`, `/lib/systemd`, and `/root`.
- Do not run provisioning scripts automatically unless the user explicitly asks; many commands require root and mutate the host.
- Prefer small, reviewable edits. Preserve the current script style unless the user asks for a broader cleanup.
- Call out security-sensitive findings clearly. This repo contains embedded configuration and likely credentials/tokens, especially in `f_config.sh`.
- When updating install steps, prefer current, supported package/install methods and note any deprecated commands you replace.

## Validation

- There is no formal test suite. Validate changes with lightweight checks first, such as `bash -n <script>` for edited shell files.
- If execution is required, ask before running anything that would install packages, modify services, or write outside the repo.
