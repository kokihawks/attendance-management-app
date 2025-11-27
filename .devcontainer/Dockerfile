FROM mcr.microsoft.com/devcontainers/typescript-node:20

ARG USERNAME=node

ENV PNPM_HOME=/home/${USERNAME}/.local/share/pnpm
ENV PATH=${PNPM_HOME}:/home/${USERNAME}/.npm-global/bin:${PATH}

USER root

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        default-mysql-client \
        redis-tools \
        jq \
        unzip \
        ca-certificates \
        curl \
        gnupg \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo ${VERSION_CODENAME}) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @nestjs/cli@latest \
    && mkdir -p ${PNPM_HOME} \
    && chown -R ${USERNAME}:${USERNAME} ${PNPM_HOME} \
    && corepack enable

RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-devcontainer-${USERNAME} \
    && chmod 0440 /etc/sudoers.d/90-devcontainer-${USERNAME}

USER ${USERNAME}
WORKDIR /workspace


