#!/usr/bin/env bash
set -euo pipefail

SOCKET_PATH=${DOCKER_SOCKET_PATH:-/var/run/docker.sock}
TARGET_USER=${DEVCONTAINER_TARGET_USER:-node}
FALLBACK_GROUP_NAME=${DOCKER_SOCKET_GROUP_NAME:-docker-host}

if [ ! -S "${SOCKET_PATH}" ]; then
  exit 0
fi

socket_gid=$(stat -c '%g' "${SOCKET_PATH}")
existing_group=$(getent group "${socket_gid}" | cut -d: -f1 || true)

if [ -z "${existing_group}" ]; then
  if getent group "${FALLBACK_GROUP_NAME}" >/dev/null; then
    groupmod --gid "${socket_gid}" "${FALLBACK_GROUP_NAME}"
  else
    groupadd --gid "${socket_gid}" "${FALLBACK_GROUP_NAME}"
  fi
  group_name="${FALLBACK_GROUP_NAME}"
else
  group_name="${existing_group}"
fi

if id -nG "${TARGET_USER}" | tr ' ' '\n' | grep -Fxq "${group_name}"; then
  exit 0
fi

usermod -aG "${group_name}" "${TARGET_USER}"





