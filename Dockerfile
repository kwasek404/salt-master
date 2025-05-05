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
    binutils \
    patchelf \
    apt-utils \
    supervisor \
    uwsgi \
    uwsgi-plugin-python3 \
    python3 \
    python3-flask \
    sudo \
    && \
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
    # See https://github.com/saltstack/salt/issues/66590 version 1.15
    salt-pip install pygit2==1.15 && \
    # Clean up APT cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a user for uwsgi
RUN useradd -r -m uwsgi_user && \
    mkdir -p /var/log/uwsgi && \
    chown uwsgi_user:uwsgi_user /var/log/uwsgi

# Set permissions for salt-run to allow uwsgi_user to execute it with sudo
RUN echo "uwsgi_user ALL=(root) NOPASSWD: /usr/bin/salt-run" > /etc/sudoers.d/uwsgi_sudo

# Default ports used by Salt Master
EXPOSE 4505 4506
EXPOSE 8080

COPY update/update.py /app/update.py
COPY update/uwsgi.ini /app/uwsgi.ini

# Copy supervisor configuration files
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/salt-master.conf /etc/supervisor/conf.d/salt-master.conf
COPY supervisor/uwsgi.conf /etc/supervisor/conf.d/uwsgi.conf

# Default startup command (can be customized)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]