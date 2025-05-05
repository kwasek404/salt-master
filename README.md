# Salt Master Docker Image

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/kwasek404/salt-master/build-salt-master.yml?branch=main&label=Build%20Status)](https://github.com/kwasek404/salt-master/actions/workflows/build-salt-master.yml)
[![View on GHCR](https://img.shields.io/badge/ghcr.io-kwasek404%2Fsalt--master-blue)](https://ghcr.io/kwasek404/salt-master)
This project provides a Docker image for Salt Master, based on `debian:stable-slim`. The main goal is to offer an up-to-date image that automatically includes the latest `salt-master` version available in the official Salt Project repository.

## Features

* **Up-to-Date:** Built daily to install the latest `salt-master` package version.
* **Official Source:** Uses the official Salt Project Debian repository (`packages.broadcom.com`) by fetching the `salt.sources` file directly during the build.
* **Debian Base:** Based on `debian:stable-slim`.
* **Automation:** Build and publish process is fully automated using GitHub Actions.
* **GHCR:** Images are published to GitHub Container Registry (GHCR).
* **Salt Master Management:** Uses Supervisor to manage the `salt-master` process.
* **Web API for Updates:** Includes a Flask-based web API for triggering `git_pillar` and `fileserver` updates via HTTP requests to the `/update` endpoint.
* **uWSGI:** Employs uWSGI to serve the Flask application.
* **Retry Mechanism:** The update API includes a retry mechanism for handling temporary failures when executing salt commands.

## Usage

Images are available on the GitHub Container Registry.

### Pulling the Image

You can pull the latest image using:

```bash
docker pull ghcr.io/kwasek404/salt-master:latest
```

### Building the Image Locally

To build the image locally, you can use the following command:

```bash
docker build -t salt-master --build-arg SALT_VERSION=3007.1 .
```