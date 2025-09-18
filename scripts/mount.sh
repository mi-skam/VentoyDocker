#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Function to display usage information
usage() {
    cat <<EOF

🚀 mount.sh - Mount the USB device into the container

Usage:
  $0 [-d <mount-path>] [-p <port>]

Options:
  -d DEVICE    mount path for usb drive in container (default: /dev/nbd0)  [OPTIONAL]
  -p PORT      TCP port to listen on (default: 10809)           [OPTIONAL]

Example:
  $0 -d /dev/nbd0 -p 10809

EOF
    exit 1
}


# Defaults
PORT="10809"
DEVICE="/dev/nbd0"

# Parse options
while getopts ":p:d:" opt; do
    case "${opt}" in
    p)
        PORT="${OPTARG}"
        ;;
    d)
        DEVICE="${OPTARG}"
        ;;
    *)
        usage
        ;;
    esac
done

nbd-client host.docker.internal "${PORT}" "${DEVICE}"
