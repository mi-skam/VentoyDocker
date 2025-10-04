#!/usr/bin/env bash

# Start Docker container with Ventoy
# This script builds the Docker image if needed and runs the container

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Get the script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../common.sh"

# Function to display usage information
usage() {
    cat <<EOF

🚀 start-ventoy.sh - Start Docker container with Ventoy

Usage:
  $0 [-p <port>]

Options:
  -p PORT      TCP port for Ventoy web interface (default: from .env or 24680) [OPTIONAL]
  -h           Show this help message

Example:
  $0 -p 8080

Environment:
  Configure defaults in .env file in repository root
  See .env.example for all available options

EOF
    exit 1
}

# Load environment configuration
load_env
export_config

# Validate environment
validate_os
check_qemu
check_docker

# Parse command-line options (can override .env values)
PORT="${VENTOY_WEB_PORT}"

while getopts ":p:h" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    h)
        usage
        ;;
    *)
        usage
        ;;
    esac
done

# Build the Docker image if it doesn't exist
IMAGE_TAG="${DOCKER_IMAGE_NAME}:${VENTOY_VERSION}"
if ! docker image inspect "${IMAGE_TAG}" &>/dev/null; then
    echo "Docker image '${IMAGE_TAG}' not found. Building..."
    # Change to repository root to build
    cd "${SCRIPT_DIR}/../.."
    docker build -t "${IMAGE_TAG}" \
        --build-arg VENTOY_VERSION="${VENTOY_VERSION}" \
        --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
        --build-arg VENTOY_DOWNLOAD_URL="${VENTOY_DOWNLOAD_URL}" \
        .
fi

# Check if build was successful
if [[ $? -ne 0 ]]; then
    echo "✗ Docker image build failed"
    exit 1
fi

echo "✓ Docker image ready: ${IMAGE_TAG}"

# Run the Docker container
echo ""
echo "Starting Docker container..."
docker run -it --rm \
    --name "${DOCKER_CONTAINER_NAME}" \
    --privileged \
    -p "${PORT}:24680" \
    -e NBD_PORT="${NBD_PORT}" \
    -e NBD_DEVICE="${NBD_DEVICE}" \
    -e NBD_HOST="${NBD_HOST}" \
    "${IMAGE_TAG}" \
    bash \
    -c "
echo ''
echo '=============================================================='
echo '🔗  To connect to NBD from inside the container, run:'
echo ''
echo '    ./scripts/container/mount.sh'
echo ''
echo '🟢 Or manually with:'
echo '    nbd-client ${NBD_HOST} ${NBD_PORT} ${NBD_DEVICE}'
echo ''
echo '⚠️   Before exiting the container, cleanly detach NBD:'
echo ''
echo '    ./scripts/container/cleanup.sh'
echo ''
echo '🟢 Or manually with:'
echo '    nbd-client -d ${NBD_DEVICE}'
echo ''
echo '🟢 Clean detach procedure is essential to avoid data loss.'
echo ''
echo '--------------------------------------------------------------'
echo '📢 Important Notes:'
echo ''
echo '✅ Only Ventoy CLI and Ventoy Web are supported in this container.'
echo '❌ Ventoy GUI interface is NOT supported.'
echo ''
echo '🌐 To start VentoyWeb:'
echo '    ./VentoyWeb.sh -H 0.0.0.0'
echo '    Then access: http://localhost:${PORT}'
echo ''
echo 'For official documentation, visit: https://www.ventoy.net/en/doc_start.html'
echo '=============================================================='
echo ''
exec bash
"
