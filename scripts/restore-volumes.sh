
#!/bin/bash

# Restore CMS backups into Kubernetes volumes

set -e

backup_dir="${1:-}"
namespace="${2:-}"

if [ -z "$backup_dir" ] || [ -z "$namespace" ]; then
    echo "Usage: $0 <backup directory> <namespace>"
    exit 1
fi

if [ ! -d "$backup_dir" ]; then
    echo "Backup directory not found"
    exit 1
fi

archives=(
    mariadb-volume.tar.gz
    wordpress-volume.tar.gz
    mail-volume.tar.gz
    tls-volume.tar.gz
)

directories=(db wp mail tls)

# Check all backups before restoring
for archive in "${archives[@]}"; do
    if [ ! -s "$backup_dir/$archive" ]; then
        echo "Missing backup: $archive"
        exit 1
    fi

    gzip -t "$backup_dir/$archive"
done

# Check if the restoration pod is ready
sudo k3s kubectl wait --for=condition=Ready \
    pod/cms-restore -n "$namespace" --timeout=60s

# Refuse to overwrite existing data
for directory in "${directories[@]}"; do
    contents=$(sudo k3s kubectl exec -n "$namespace" cms-restore -- \
        ls -A "/restore/$directory")

    if [ -n "$contents" ]; then
        echo "Volume is not empty: $directory"
        exit 1
    fi
done

# Restore each backup
for i in "${!archives[@]}"; do
    echo "Restoring ${archives[$i]}..."

    sudo k3s kubectl exec -i -n "$namespace" cms-restore -- \
        tar --numeric-owner -xzpf - \
        -C "/restore/${directories[$i]}" \
        < "$backup_dir/${archives[$i]}"
done

echo "CMS volume restoration completed."

