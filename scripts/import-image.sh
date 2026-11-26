
#!/bin/bash

# Import the CMS image into K3s

image_file="$1"

if [ -z "$image_file" ]; then
    echo "Usage: $0 <image archive>"
    exit 1
fi

if [ ! -f "$image_file" ]; then
    echo "Image file not found"
    exit 1
fi

if ! command -v k3s >/dev/null 2>&1; then
    echo "K3s is not installed"
    exit 1
fi

echo "Importing CMS image..."

if sudo k3s ctr -n k8s.io images import "$image_file"; then
    echo "Image imported successfully"
else
    echo "Image import failed"
    exit 1
fi

echo
echo "Available CMS images:"
sudo k3s ctr -n k8s.io images ls | grep suasploitable-cms
