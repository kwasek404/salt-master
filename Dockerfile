# Use the stable slim Debian image as a base
FROM debian:stable-slim

# Arguments passed during the build by GitHub Actions
ARG SALT_VERSION

# Metadata labels
LABEL maintainer="Mateusz Kwaśniewicz <mateusz.kwasniewicz@kwasek.org>"
LABEL org.opencontainers.image.source = "https://github.com/kwasek404/salt-master" # Replace with your repo URL
LABEL org.opencontainers.image.description="Docker image with Salt Master ${SALT_VERSION} on Debian:stable-slim"
LABEL org.opencontainers.image.version = "${SALT_VERSION}"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    binutils && \
    # Add the Salt Project (Broadcom) GPG key
    # Key URL taken from the official Salt install guide
    curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp && \
    # Add the Salt repository
    curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources && \
    # Update package list and install salt-master (latest available version from the repo)
    apt-get update && \
    apt-get install -y --no-install-recommends salt-master=${SALT_VERSION} && \
    # (Optional) Check the installed version - mainly for build logs
    salt-master --version && \
    # Install pygit2 for git integration
    salt-pip install pygit2 && \
    # Clean up APT cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Default ports used by Salt Master
EXPOSE 4505 4506

# Default startup command (can be customized)
CMD ["salt-master", "-l", "info"]