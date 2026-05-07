#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <collection_name>" >&2
  echo "example: $0 docker_compose" >&2
  exit 1
fi

COLLECTION_NAME="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COLLECTION_DIR="${REPO_ROOT}/collections/${COLLECTION_NAME}"
ENV_FILE="${REPO_ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "error: ${ENV_FILE} not found" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

if [[ -z "${ANSIBLE_GALAXY_TOKEN:-}" ]]; then
  echo "error: ANSIBLE_GALAXY_TOKEN missing from ${ENV_FILE}" >&2
  exit 1
fi

if [[ ! -f "${COLLECTION_DIR}/galaxy.yml" ]]; then
  echo "error: galaxy.yml not found in ${COLLECTION_DIR}" >&2
  exit 1
fi

NAMESPACE=$(awk '/^namespace:/ {print $2}' "${COLLECTION_DIR}/galaxy.yml")
NAME=$(awk '/^name:/ {print $2}' "${COLLECTION_DIR}/galaxy.yml")
VERSION=$(awk '/^version:/ {print $2}' "${COLLECTION_DIR}/galaxy.yml")
ARTIFACT="${NAMESPACE}-${NAME}-${VERSION}.tar.gz"

echo "==> Building ${NAMESPACE}.${NAME} v${VERSION}"
cd "${COLLECTION_DIR}"
rm -f -- *.tar.gz
ansible-galaxy collection build --force

echo "==> Publishing ${ARTIFACT} to Ansible Galaxy"
ansible-galaxy collection publish "${ARTIFACT}" --token "${ANSIBLE_GALAXY_TOKEN}"

echo "==> Cleaning up ${ARTIFACT}"
rm -f -- "${ARTIFACT}"

echo "==> Done: https://galaxy.ansible.com/ui/repo/published/${NAMESPACE}/${NAME}/"
