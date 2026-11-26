#!/bin/bash
###############################################################################
# WARNING: this file is managed by `guhcampos-workstation`, manually editing it
# may be futile as it will be overriden.
#
# opencode client wrapper: connects your local opencode TUI to a sandbox
# user's on-demand agent server, supplying the fixed agent password from the
# sandbox home. Running this as the primary user also wakes the server up:
# the launchd listener spawns it on the first connection.
#
# usage: opencode-client <profile-or-account>
###############################################################################

set -u

selector="${1:?usage: opencode-client <profile-or-account>}"
account=""
port=""

# Prefer profile IDs if a local account name happens to overlap one.
case "${selector}" in
{% for u in sandbox_users %}
    "{{ u.profile }}") account="{{ u.account }}"; port={{ u.public_port }} ;;
{% endfor %}
    *) ;;
esac

# Also accept the mapped local macOS account name.
if [ -z "${account}" ]; then
    case "${selector}" in
{% for u in sandbox_users %}
        "{{ u.account }}") account="{{ u.account }}"; port={{ u.public_port }} ;;
{% endfor %}
        *) echo "workstation: unknown sandbox profile or account ${selector}" >&2; exit 1 ;;
    esac
fi

password_file="/Users/${account}/.config/opencode/agent-password"
if [ ! -r "${password_file}" ]; then
    echo "workstation: cannot read ${password_file} (are you in the group ${account}?)" >&2
    exit 1
fi

OPENCODE_PASSWORD="$(cat "${password_file}")"
export OPENCODE_PASSWORD
exec /opt/homebrew/bin/opencode --server "http://127.0.0.1:${port}"
