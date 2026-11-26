#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
# setup to manage cloud resources on GCP
################################################################################

if [[ -f "${HOME}/.local/google-cloud-sdk/path.bash.inc" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/.local/google-cloud-sdk/path.bash.inc"
fi
