#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
################################################################################

if command -v pyenv >/dev/null; then
  eval "$(pyenv init -)"
else
  echo "$(date) ERROR: 'pyenv' not found on \$PATH"
fi

pyenv global system
