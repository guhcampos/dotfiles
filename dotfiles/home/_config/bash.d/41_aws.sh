#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
# setup for managing cloud resources on AWS.
################################################################################

which aws_completer >>/dev/null && complete -C "$(which aws_completer)" aws

# alias assume="source /opt/homebrew/bin/assume"
alias assume=". assume"
