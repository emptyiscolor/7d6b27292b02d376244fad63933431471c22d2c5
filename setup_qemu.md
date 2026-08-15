# Kernel development host setup

Supported hosts: Debian and Ubuntu.

```sh
sudo ./setup-linux-kernel-dev.sh --user "$USER"
```

This installs kernel build/debug tools, QEMU/KVM/libvirt, and Docker. Log out
and back in afterward to apply group membership.

Useful options:

```sh
# Put Docker data on a larger disk
sudo ./setup-linux-kernel-dev.sh --user "$USER" \
  --docker-data-root /mnt/data/docker

# Skip optional components
sudo ./setup-linux-kernel-dev.sh --user "$USER" --skip-docker
sudo ./setup-linux-kernel-dev.sh --skip-qemu
```

Verify the host:

```sh
./verify-kernel-dev-host.sh --expect-qemu --expect-docker
```

If `/dev/kvm` is unavailable, QEMU still works using slower software emulation.
The `docker` group grants root-equivalent access, so omit `--user` when that is
not appropriate.
