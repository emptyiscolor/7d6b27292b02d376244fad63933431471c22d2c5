# Linux host bootstrap scripts

This repository contains standalone provisioning helpers for CloudLab and Linux
development hosts. The kernel-development path supports current Debian and
Ubuntu hosts and installs an LLVM/GCC toolchain, kernel build dependencies,
debugging utilities, QEMU/KVM/libvirt, and Docker Engine.

## One-shot kernel development setup

Run the orchestrator from a fresh Debian or Ubuntu host:

```sh
git clone https://github.com/emptyiscolor/7d6b27292b02d376244fad63933431471c22d2c5
cd 7d6b27292b02d376244fad63933431471c22d2c5
sudo ./setup-linux-kernel-dev.sh --user "$USER"
```

To place Docker's storage on a larger disk:

```sh
sudo ./setup-linux-kernel-dev.sh \
  --user "$USER" \
  --docker-data-root /mnt/data/docker
```

Log out and back in after setup so new `docker`, `kvm`, and `libvirt` group
memberships take effect. Membership in the `docker` group grants root-equivalent
access; omit `--user` when that is not appropriate.

User group membership is changed only when `--user` is explicitly supplied.
The setup is designed to be rerun. Existing valid `/etc/docker/daemon.json`
settings are preserved when `data-root` is added. Use `--skip-docker` or
`--skip-qemu` for a smaller host.

## Individual scripts

- `install-kernel-dev-tools.sh` installs compilers and build/debug dependencies.
- `install-qemu.sh` installs QEMU, KVM/libvirt, firmware, and VM utilities.
- `install-docker.sh` uses Docker's official APT repository and Compose/Buildx
  plugins; it no longer downloads and pipes a remote installer into a shell.
- `verify-kernel-dev-host.sh` performs read-only command checks.

Run components independently when updating an existing host:

```sh
sudo ./install-kernel-dev-tools.sh
sudo ./install-qemu.sh --user "$USER"
sudo ./install-docker.sh --user "$USER" --data-root /mnt/data/docker
./verify-kernel-dev-host.sh --expect-qemu --expect-docker
```

## Quick kernel build

```sh
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
make LLVM=1 defconfig
make LLVM=1 -j"$(nproc)"
```

For an unaccelerated QEMU host, omit `-enable-kvm`/`-accel kvm` from VM launch
commands. `/dev/kvm` is checked during setup but its absence is not treated as
an installation failure because nested virtualization is often unavailable on
cloud hosts.
