
#!/bin/bash

# Check system requirements for SUASecLab

echo "Operating system"
grep PRETTY_NAME /etc/os-release
uname -r

echo
echo "CPU and memory"
echo "CPU cores: $(nproc)"
free -h

echo
echo "Disk space"
df -h /

echo
echo "Git"
if command -v git >/dev/null 2>&1; then
    git --version
else
    echo "Git is not installed"
fi

echo
echo "K3s and container runtime"
if command -v k3s >/dev/null 2>&1; then
    k3s --version
    if ! sudo k3s kubectl get nodes -o wide; then
        echo "Could not connect to K3s"
    fi
else
    echo "K3s is not installed"
fi

# Check KVM for Kata Containers
echo
echo "KVM"
if [ -c /dev/kvm ]; then
    echo "KVM device available"
    ls -l /dev/kvm
else
    echo "KVM device not available"
fi

echo
echo "Seccomp"
if grep -q '^Seccomp:' /proc/self/status; then
    echo "Seccomp interface detected"
else
    echo "Seccomp not detected"
fi

echo
echo "AppArmor"
if [ -r /sys/module/apparmor/parameters/enabled ]; then
    cat /sys/module/apparmor/parameters/enabled
else
    echo "AppArmor status unavailable"
fi

echo
echo "Kata Containers"
if command -v kata-runtime >/dev/null 2>&1; then
    kata-runtime --version
else
    echo "Kata runtime not found in PATH"
fi

echo
echo "System check completed."

