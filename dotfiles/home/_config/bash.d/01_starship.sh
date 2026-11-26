#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
# Load [`starship`](https://starship.rs) - my shell prompt of choice. Should be
# the first customization to load, as it may affect how other files are handled.
################################################################################

if type -P starship >/dev/null; then
  eval "$(starship init bash)"
else
  echo "$(date) ERROR: 'starship' not found on \$PATH"
fi
