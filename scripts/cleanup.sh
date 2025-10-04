#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Load environment variables from .env file
if [[ -f "$(dirname "$0")/../.env" ]]; then
    export $(grep -v '^#' "$(dirname "$0")/../.env" | xargs)
fi

# Function to display usage information
usage() {
        cat <<EOF

🚀 cleanup.sh - Cleanup script to remove the nbd device 

Usage:
    $0 -d [ <nbd-device> ]

    -d DEVICE your nbd-device [OPTIONAL] DEFAULT=${NBD_DEVICE:-/dev/nbd0}

Example:
     $0 -d /dev/nbd0
EOF
        exit 1
}

# Defaults (from .env or fallback)
DEVICE="${NBD_DEVICE:-/dev/nbd0}"

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