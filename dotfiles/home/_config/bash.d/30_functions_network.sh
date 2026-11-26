#!/bin/bash
################################################################################
# Managed by guhcampos-dotfiles.
# -----------------------------------------------------------------------------
################################################################################

function vping {
  #  Verbose ping a hostname: a series of single packet pings. Useful to
  # keep pinging a hostname without having to remember which window is
  # pinging what host.

  host=$1

  if [ -z "${host}" ]; then
    echo "Please provide a hostname to ping"
    echo
    return 1
  fi

  while true; do
    ping -oc 1 "${host}"
    sleep 1
  done

  return $?
}

function tping {
  #  Transitive ping a hostname: ssh to host A then ping host B from there

  host=$1
  proxy=$2

  if [[ -z "${host}" || -z "${proxy}" ]]; then
    echo "tping: Transitively ping a hostname through a proxy using SSH"
    echo
    echo "Usage:"
    echo "tping ${host} ${proxy}"
    echo
    return 1
  fi

  command="ping -c 1 ${host}"

  while true; do
    #shellcheck disable=SC2029
    ssh "${proxy}" "${command}"
    sleep 1
  done

  return $?
}

function psproc {
  # PS for a proc name
  ps -C "${1}" -o pid,cmd
}

function mywatch {
  # Similar to `watch` but works on Mac OS X and has colors =D
  while true; do
    sleep 1
    clear
    date
    "$*"
  done
}
