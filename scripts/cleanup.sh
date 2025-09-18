#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Function to display usage information
usage() {
        cat <<EOF

🚀 cleanup.sh - Cleanup script to remove the nbd device 

Usage:
    $0 -d [ <nbd-device> ]
  
    -d DEVICE your nbd-device [OPTIONAL] DEFAULT=/dev/nbd0

Example:
     $0 -d /dev/nbd0
EOF
        exit 1
}

# Defaults
DEVICE="/dev/nbd0"

# Parse options
while getopts ":d:" opt; do
    case "${opt}" in
    d)
        DEVICE="${OPTARG}"
        ;;
    *)
        usage
        ;;
    esac
done

nbd-client -d "${DEVICE}"
echo "Cleanup 🧹 Done!!"