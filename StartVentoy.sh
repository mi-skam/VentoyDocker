#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Load environment variables from .env file
if [[ -f "$(dirname "$0")/.env" ]]; then
    export $(grep -v '^#' "$(dirname "$0")/.env" | xargs)
fi

# Function to display usage information
usage() {
    cat <<EOF

🚀 StartVentoy.sh - Start Docker container with ventoy. 

Usage:
  $0 [-p <port>]

Options:
  -p PORT      TCP port for ventoy web (default: ${VENTOY_WEB_PORT:-24680}) [OPTIONAL]

Example:
  ./$0 -p 8080

EOF
    exit 1
}

# User operating system
OS=$(uname -s)

# check if the os is macos
if [[ "$OS" == "Darwin" ]]; then
    echo "macOS is supported."
elif [[ "$OS" == "Linux" ]]; then
    echo "You can directly use ventoy on Linux, no need to use docker."
    echo "Please refer to the official documentation for installation instructions: https://www.ventoy.net/en/doc_start.html"
    exit 0
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# check if qemu and qemu-nbd is installed  is macos
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v qemu-system-x86_64 &>/dev/null; then
        echo "qemu-system-x86_64 could not be found. Please install QEMU."
        echo "You can install it using Homebrew with the command: brew install qemu"
        exit 1
    fi
    if ! command -v qemu-nbd &>/dev/null; then
        echo "qemu-nbd could not be found. Please install QEMU."
        echo "You can install it using Homebrew with the command: brew install qemu"
        exit 1
    fi
fi

# check if docker is installed
if ! command -v docker &>/dev/null; then
    echo "Docker could not be found. Please install Docker."
    echo "You can download it from https://www.docker.com/get-started"
    exit 1
fi

# Build the Docker image if it is not already built
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_NAME:-ventoy-docker}:${VENTOY_VERSION:-1.1.07}"
if ! docker image inspect "$DOCKER_IMAGE_TAG" &>/dev/null; then
    echo "Docker image '$DOCKER_IMAGE_TAG' not found. Building the image..."
    docker build \
        --build-arg UBUNTU_VERSION="${UBUNTU_VERSION:-latest}" \
        --build-arg VENTOY_VERSION="${VENTOY_VERSION:-1.1.07}" \
        --build-arg VENTOY_DOWNLOAD_URL="${VENTOY_DOWNLOAD_URL}" \
        --build-arg VENTOY_WORK_DIR="${VENTOY_WORK_DIR:-/root/ventoy-1.1.07}" \
        -t "$DOCKER_IMAGE_TAG" .
fi

# Check if the build was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Docker image build failed."
    exit 1
fi

# Defaults (from .env or fallback)
PORT="${VENTOY_WEB_PORT:-24680}"

# Parse options
while getopts ":p:" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    *)
        usage
        ;;
    esac
done

# Run the Docker container
echo "Running the Docker container..."
docker run -it --rm \
    --name "${DOCKER_CONTAINER_NAME:-ventoy-docker}" \
    --privileged \
    -p "${PORT}":${VENTOY_WEB_PORT:-24680} \
    "$DOCKER_IMAGE_TAG" \
    bash \
    -c "
echo ''
echo '=============================================================='
echo '🔗  To connect to NBD from your host, run the following:'
echo ''
echo '    nbd-client ${NBD_HOST:-host.docker.internal} <nbd-port> <nbd-device>'
echo ''
echo '🟢 Example:'
echo '    nbd-client ${NBD_HOST:-host.docker.internal} ${NBD_PORT:-10809} ${NBD_DEVICE:-/dev/nbd0}'
echo ''
echo '📁 Optionally you can run the following script to connect to NBD from your host'
echo ''
echo '    ./scripts/mount.sh'
echo ''
echo '⚠️   Before exiting the container, cleanly detach NBD:'
echo ''
echo '    nbd-client -d ${NBD_DEVICE:-/dev/nbd0}'
echo ''
echo '🟢 Clean Detach Procedure is essential to avoid data loss.'
echo ''
echo '📁 Optionally you can run the following script cleanly detach NBD'
echo ''
echo '    ./scripts/cleanup.sh'
echo ''
echo '--------------------------------------------------------------'
echo '📢 Important Notes:'
echo ''
echo '✅ Only the Ventoy CLI and Ventoy Web is currently supported in this container.'
echo '❌ Ventoy GUI interface are NOT supported.'
echo ''
echo 'For official documentation, visit: https://www.ventoy.net/en/doc_start.html'
echo '=============================================================='
echo ''
exec bash
"
