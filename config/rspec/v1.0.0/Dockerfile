FROM ubuntu:22.04 as buildtool

ARG NODE_VERSION=14.21.3

LABEL org.opencontainer.image.source="https://github.com/shikimori/shikimori/blob/master/config/rspec/v1.0.0/Dockerfile"

ENV DEBIAN_FRONTEND noninteractive
ENV TZ "Europe/Moscow"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        ruby \
        libpq-dev \
        curl \
        file \
        gnupg \
        libvips \
        imagemagick \
        make \
        unzip \
        tzdata \
        libjpeg-progs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
ENV NVM_DIR /root/.nvm

# Install node
RUN . ${NVM_DIR}/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    nvm use default
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Verify node and npm installation
RUN node --version && \
    npm --version

# Install Docker
RUN curl -fsSL https://get.docker.com | bash

FROM ubuntu:22.04
COPY --from=buildtool / /

ARG NODE_VERSION=14.21.3

ENV HOME /root
ENV NVM_DIR /root/.nvm
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}"