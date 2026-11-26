#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
# Standardizes shell configuration between Linux and MacOS so I have a similar
# experience in both systems.
################################################################################

PATH=${HOME}/.local/bin:/usr/sbin:/sbin:$PATH

LC_ALL="en_US.UTF-8"
SHELLCHECK_OPTS="-e SC2002"
TERM="xterm-256color"

function setup_linux() {
  ##############################################################################
  # LINUX OS SPECIFIC
  ##############################################################################
  alias ls="ls --color"
  alias du="du --max-depth=1 -h"
  alias df="df -h"
  alias python=python3
  alias ag=rg

  PATH="/snap/bin:${PATH}"

  # support for abnt2 portuguese keyboards on linux
  GTK_IM_MODULE="cedilla"

  if [[ -f /etc/bash_completion ]]; then
    # shellcheck disable=SC1091
    source /etc/bash_completion
  fi

}

function setup_macos() {
  ##############################################################################
  # MAC OS SPECIFIC
  ##############################################################################
  BASH_SILENCE_DEPRECATION_WARNING=1

  if [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
  fi

  alias ls="ls -G"
  alias python=python3
  alias ag=rg

}

case "$(uname -s)" in
Darwin)
  setup_macos
  ;;
Linux)
  setup_linux
  ;;
esac

export BASH_SILENCE_DEPRECATION_WARNING
export GTK_IM_MODULE
export LC_ALL
export PATH
export SHELLCHECK_OPTS
export TERM
