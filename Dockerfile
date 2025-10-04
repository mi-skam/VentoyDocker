# Build arguments for configuration
ARG UBUNTU_VERSION=latest
ARG VENTOY_VERSION=1.1.07
ARG VENTOY_DOWNLOAD_URL=https://github.com/ventoy/Ventoy/releases/download/v${VENTOY_VERSION}/ventoy-${VENTOY_VERSION}-linux.tar.gz

FROM ubuntu:${UBUNTU_VERSION}

# Install system dependencies
RUN apt update && apt install -y \
    nbd-client util-linux \
    wget tar xz-utils \
    parted fdisk \
    udev \
    dosfstools \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /root

# Download and extract Ventoy
RUN wget "${VENTOY_DOWNLOAD_URL}" -O ventoy.tar.gz \
    && tar -xzf ventoy.tar.gz \
    && rm ventoy.tar.gz

# Set working directory to Ventoy installation
WORKDIR /root/ventoy-${VENTOY_VERSION}

# Copy scripts into container
COPY ./scripts/ /root/ventoy-${VENTOY_VERSION}/scripts/

# Make all scripts executable
RUN find /root/ventoy-${VENTOY_VERSION}/scripts -type f -name "*.sh" -exec chmod +x {} \;

CMD ["bash"]
