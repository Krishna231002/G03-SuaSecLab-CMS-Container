#!/bin/bash

set -e

version="4.3.1"
archive="kata-go-static-${version}-amd64.tar.zst"
checksum="66b35b06f6b41b56f8606ddf3ed3e5660b0971d1e309d903457c4056a0b9eff0"

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
config_dir="/var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.d"

if ! command -v k3s >/dev/null 2>&1; then
    echo "K3s is not installed"
    exit 1
fi

if [ ! -c /dev/kvm ]; then
    echo "KVM is not available"
    exit 1
fi

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Unsupported architecture"
    exit 1
fi

if [ -x /opt/kata/bin/kata-runtime ]; then
    if [ "$(cat /opt/kata/VERSION)" != "$version" ]; then
        echo "A different Kata version is installed"
        exit 1
    fi
    echo "Kata is already installed"
else
    if [ -e /opt/kata ]; then
        echo "Existing Kata directory found. Check installation."
        exit 1
    fi

    mkdir -p "$HOME/kata-install"
    cd "$HOME/kata-install"

    wget -c "https://github.com/kata-containers/kata-containers/releases/download/${version}/${archive}"

    echo "$checksum  $archive" | sha256sum -c -

    sudo tar --zstd -xpf "$archive" -C /
fi

sudo /opt/kata/bin/kata-runtime \
    --kata-config=/opt/kata/share/defaults/kata-containers/configuration-qemu.toml \
    check --no-network-checks

sudo mkdir -p "$config_dir"

if ! sudo cmp -s "$project_dir/k3s/containerd/kata.toml" "$config_dir/kata.toml"; then
    sudo cp "$project_dir/k3s/containerd/kata.toml" "$config_dir/kata.toml"
    sudo systemctl restart k3s
fi

sudo k3s kubectl wait --for=condition=Ready nodes --all --timeout=180s
sudo k3s kubectl apply -f "$project_dir/k3s/runtimeclass-kata.yaml"

sudo /opt/kata/bin/kata-runtime --version
sudo k3s kubectl get runtimeclass kata
