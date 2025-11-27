#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="/workspace/.devcontainer/scripts"

if [ -x "${SCRIPT_DIR}/setup-docker-sock.sh" ]; then
  sudo DEVCONTAINER_TARGET_USER=node bash "${SCRIPT_DIR}/setup-docker-sock.sh"
fi

exec sleep infinity


