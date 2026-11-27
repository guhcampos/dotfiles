#!/bin/bash
################################################################################
# WARNING: managed by ansible @ https://github.com/guhcampos/dotfiles
# Manual edits may be overwritten.
# -----------------------------------------------------------------------------
#
# opencode idle reaper: kills a sandbox user's `opencode serve` when it has
# been idle for longer than IDLE_SECS (default 900) and has no ESTABLISHED
# connections on its internal port. runs as root from launchd every 5 minutes.
#
# usage: opencode-idle-reaper <name:internal_port>[,<name:internal_port>...]
################################################################################

set -u

LOG_FILE="/var/log/workstation-opencode-reaper.log"
IDLE_SECS="${IDLE_SECS:-900}"

log() {
  echo "$(date '+%Y-%m-%dT%H:%M:%S') $*" >>"${LOG_FILE}"
}

# keep the log bounded: it only records actual kills
if [ -f "${LOG_FILE}" ] && [ "$(stat -f %z "${LOG_FILE}" 2>/dev/null || echo 0)" -gt 1048576 ]; then
  : >"${LOG_FILE}"
fi

now=$(date +%s)
entries=$(printf '%s' "${1:-}" | tr ',' ' ')

for entry in ${entries}; do
  user="${entry%%:*}"
  internal_port="${entry##*:}"
  last_activity_file="/Users/${user}/.local/state/opencode-last-activity"
  serve_pattern="opencode serve --hostname 127.0.0.1 --port ${internal_port}"

  pgrep -u "${user}" -f "${serve_pattern}" >/dev/null 2>&1 || continue

  # no activity marker means we never bridged a connection; leave it alone
  [ -f "${last_activity_file}" ] || continue

  last=$(cat "${last_activity_file}" 2>/dev/null)
  case "${last}" in
  '' | *[!0-9]*) continue ;;
  esac

  idle=$((now - last))
  [ "${idle}" -lt "${IDLE_SECS}" ] && continue

  # a live client is still bridged on the internal port; leave it alone
  if /usr/sbin/lsof -nP -iTCP:"${internal_port}" -sTCP:ESTABLISHED 2>/dev/null | grep -q ESTABLISHED; then
    continue
  fi

  if pkill -u "${user}" -f "${serve_pattern}"; then
    log "killed idle opencode serve for ${user} (port ${internal_port}, idle ${idle}s)"
  fi
done
