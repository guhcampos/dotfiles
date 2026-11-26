#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
# I make **heavy** use of `direnv` to properly configure different projects with
# specific environment variables.
################################################################################

if command -v direnv >/dev/null; then
  eval "$(direnv hook bash)"
else
  echo "$(date) ERROR: 'direnv' not found on \$PATH"
fi
