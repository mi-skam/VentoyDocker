# Build arguments with defaults from .env
ARG UBUNTU_VERSION=latest
ARG VENTOY_VERSION=1.1.07
ARG VENTOY_DOWNLOAD_URL=https://github.com/ventoy/Ventoy/releases/download/v1.1.07/ventoy-1.1.07-linux.tar.gz
ARG VENTOY_WORK_DIR=/root/ventoy-1.1.07

FROM ubuntu:${UBUNTU_VERSION}

# Install system dependencies
RUN apt update && apt install -y \
    nbd-client util-linux \
    wget tar xz-utils \
    parted fdisk \
    udev \
    dosfstools

# Create work directory
WORKDIR /root

# Download and extract Ventoy
RUN wget ${VENTOY_DOWNLOAD_URL} \
    && tar -xzf ventoy-${VENTOY_VERSION}-linux.tar.gz

# Set Working Directory
# This is where the Ventoy files are located
WORKDIR ${VENTOY_WORK_DIR}

COPY ./scripts/ ${VENTOY_WORK_DIR}/scripts/

RUN chmod +x ${VENTOY_WORK_DIR}/scripts/cleanup.sh ${VENTOY_WORK_DIR}/scripts/mount.sh 

CMD ["bash"]
