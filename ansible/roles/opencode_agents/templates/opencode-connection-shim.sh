#!/bin/bash
################################################################################
# WARNING: managed by ansible @ https://github.com/guhcampos/dotfiles
# Manual edits may be overwritten.
# -----------------------------------------------------------------------------
# opencode connection shim: launchd accepts the client connection on the public
# port and hands it to us on stdin/stdout. we make sure `opencode serve` is up
# for this sandbox user (spawning it on the internal port when needed), touch
# the last-activity marker consumed by the idle reaper, then bridge the raw
# connection to the server.
#
# usage: opencode-connection-shim <user> <internal_port> <last_activity_file> <password_file>
################################################################################

set -u

user="${1:?usage: opencode-connection-shim <user> <internal_port> <last_activity_file> <password_file>}"
internal_port="${2:?missing internal_port}"
last_activity_file="${3:?missing last_activity_file}"
password_file="${4:?missing password_file}"

home="/Users/${user}"
serve_log="${home}/.local/state/opencode-serve.log"
lock_dir="/tmp/.workstation-opencode-${user}.lock"

probe() {
  /usr/bin/nc -z 127.0.0.1 "${internal_port}" >/dev/null 2>&1
}

release_lock() {
  rmdir "${lock_dir}" 2>/dev/null || true
}

###############################################################################
# serialized start: only one connection may boot `opencode serve` at a time
###############################################################################
waited=0
until mkdir "${lock_dir}" 2>/dev/null; do
  sleep 1
  waited=$((waited + 1))
  if [ "${waited}" -ge 30 ]; then
    echo "workstation: could not acquire the opencode start lock for ${user}, try again" >&2
    exit 1
  fi
done
trap release_lock EXIT

if ! probe; then
  if ! command -v opencode >/dev/null 2>&1; then
    echo "workstation: opencode is not on PATH for ${user}, install it with brew" >&2
    exit 1
  fi
  if [ ! -s "${password_file}" ]; then
    echo "workstation: missing or empty agent password file ${password_file}" >&2
    exit 1
  fi

  # launchd does not read the sandbox user's shell profile. Load the sandbox-
  # wide environment explicitly so the server and its child processes inherit it.
  env_file="${home}/.env"
  if [ ! -r "${env_file}" ]; then
    echo "workstation: missing or unreadable sandbox environment file ${env_file}" >&2
    exit 1
  fi
  set -a
  if ! . "${env_file}"; then
    set +a
    echo "workstation: failed to load sandbox environment file ${env_file}" >&2
    exit 1
  fi
  set +a

  mkdir -p "$(dirname "${serve_log}")"
  # no nohup here: it fails without a controlling terminal (launchd inetd
  # context); the redirect + disown already detach the server from this shim.
  # OPENCODE_PASSWORD gives the server a fixed password (username is always
  # `opencode`) so clients can authenticate across restarts.
  OPENCODE_PASSWORD="$(cat "${password_file}")" \
    env \
    HOME="${home}" \
    PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    opencode serve --hostname 127.0.0.1 --port "${internal_port}" \
    >>"${serve_log}" 2>&1 &
  serve_pid=$!
  disown "${serve_pid}" 2>/dev/null || true

  ready=0
  for _ in $(seq 1 25); do
    if probe; then
      ready=1
      break
    fi
    sleep 1
  done

  if [ "${ready}" -ne 1 ]; then
    kill "${serve_pid}" 2>/dev/null || true
    echo "workstation: opencode serve for ${user} failed to start, see ${serve_log}" >&2
    exit 1
  fi
fi

release_lock
trap - EXIT

###############################################################################
# touch the activity marker before bridging; the idle reaper reads its mtime
###############################################################################
mkdir -p "$(dirname "${last_activity_file}")"
date +%s >"${last_activity_file}"

exec /usr/bin/nc 127.0.0.1 "${internal_port}"
