#!/usr/bin/env bash
# © 2026 Lionel Guo · lionelliguo@gmail.com. All rights reserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$(cd "${SCRIPT_DIR}/../../../shared" && pwd)"

STATE_FILES=(
  "${STATE_DIR}/edgeone-workshop.tfstate"
  "${STATE_DIR}/edgeone-workshop.tfstate.backup"
  "${STATE_DIR}/edgeone-workshop.tfstate.lock.info"
  "${STATE_DIR}/.terraform.tfstate.lock.info"
)

echo "This will remove the local Terraform state used by the workshop:"
echo "  ${STATE_DIR}/edgeone-workshop.tfstate"
echo
echo "Cloud resources will not be deleted, but Terraform will forget anything"
echo "currently recorded in this local state. Use this only when restarting the"
echo "workshop from Lab 01 or when the instructor asks you to reset local state."
echo
read -r -p "Type RESET to continue: " CONFIRM

if [[ "${CONFIRM}" != "RESET" ]]; then
  echo "State reset cancelled."
  exit 1
fi

for file in "${STATE_FILES[@]}"; do
  if [[ -e "${file}" ]]; then
    rm -f "${file}"
    echo "Removed ${file}"
  fi
done

echo "Shared Terraform state reset complete."
