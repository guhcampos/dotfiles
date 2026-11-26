#!/bin/bash
###############################################################################
# WARNING: this file is managed by `guhcampos-workstation`, manually editing it
# may be futile as it will be overridden.
#
# ACP client wrapper: starts OpenCode's stdio Agent Client Protocol adapter as
# the selected sandbox user. ACP uses a private server for this process rather
# than the launchd-managed shared HTTP server.
#
# usage: opencode-acp-client <profile-or-account>
###############################################################################

set -u

selector="${1:?usage: opencode-acp-client <profile-or-account>}"
account=""

# Prefer profile IDs if a local account name happens to overlap one.
case "${selector}" in
{% for u in sandbox_users %}
    "{{ u.profile }}") account="{{ u.account }}" ;;
{% endfor %}
    *) ;;
esac

# Also accept the mapped local macOS account name.
if [ -z "${account}" ]; then
    case "${selector}" in
{% for u in sandbox_users %}
        "{{ u.account }}") account="{{ u.account }}" ;;
{% endfor %}
        *) echo "workstation: unknown sandbox profile or account ${selector}" >&2; exit 1 ;;
    esac
fi

home="/Users/${account}"
if [ ! -d "${home}" ]; then
    echo "workstation: sandbox home ${home} does not exist" >&2
    exit 1
fi

cd "${home}" || exit 1

exec /usr/bin/sudo -n -u "${account}" -H \
    /usr/bin/env PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    /opt/homebrew/bin/opencode acp
