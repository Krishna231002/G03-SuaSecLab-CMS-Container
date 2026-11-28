#!/usr/bin/env bash
set -euo pipefail

# ---- settings ----
IMAGE_NAME="g03-suaseclab:latest"
CONTAINER_NAME="suaseclab-heaven"
PORT="8080"
REPO_DIR="$(pwd)"

log() { echo "[$(date +%H:%M:%S)] $*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing tool: $1" >&2; exit 1; }; }

log "Checking required tools..."
need docker
need git

log "Building image $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" "$REPO_DIR"

log "Removing any old container named $CONTAINER_NAME..."
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

log "Starting the container..."
docker run -d --name "$CONTAINER_NAME" -p "$PORT:80" "$IMAGE_NAME"

log "Waiting for the site to answer..."
sleep 3
if curl -fsS "http://localhost:$PORT" >/dev/null; then
  log "SUCCESS: site is answering on port $PORT"
else
  echo "FAILED: site did not answer on port $PORT" >&2
  exit 1
fi
