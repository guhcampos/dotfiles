#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
################################################################################

PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH}"

if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    # shellcheck disable=SC1091
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      if [[ -r "${COMPLETION}" ]]; then
        # shellcheck disable=SC1090
        source "${COMPLETION}"
      fi
    done
  fi
fi

export PATH
