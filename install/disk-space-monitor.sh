#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: install/disk-space-monitor.sh

Installs and starts the user-level disk-space-monitor systemd service on Linux.

Environment:
  COPILOT_RUNTIME_REPO  Repository containing script/watch-clean.ts.
EOF
}

if [ "${1:-}" = '--help' ] || [ "${1:-}" = '-h' ]; then
    usage
    exit 0
fi
[ "$#" -eq 0 ] || {
    usage >&2
    exit 2
}

if [ "$(uname -s)" != 'Linux' ] || ! command -v systemctl >/dev/null 2>&1; then
    echo 'Skipping disk cleanup service installation: systemd is unavailable'
    exit 0
fi
if ! systemctl --user show-environment >/dev/null 2>&1; then
    echo 'Skipping disk cleanup service installation: user systemd is unavailable'
    exit 0
fi

runtime_repo="${COPILOT_RUNTIME_REPO:-}"
existing_unit="$HOME/.config/systemd/user/disk-space-monitor.service"
if [ -z "$runtime_repo" ] && [ -f "$existing_unit" ]; then
    runtime_repo="$(sed -n 's/^WorkingDirectory=//p' "$existing_unit" | head -n 1)"
fi
if [ -z "$runtime_repo" ] && [ -f "$HOME/code/copilot-agent-runtime/script/watch-clean.ts" ]; then
    runtime_repo="$HOME/code/copilot-agent-runtime"
fi

mkdir -p "$(dirname "$existing_unit")"
environment_line=
if [ -n "$runtime_repo" ]; then
    runtime_repo="$(realpath "$runtime_repo")"
    escaped_repo="${runtime_repo//\\/\\\\}"
    escaped_repo="${escaped_repo//\"/\\\"}"
    environment_line="Environment=\"COPILOT_RUNTIME_REPO=$escaped_repo\""
fi

cat >"$existing_unit" <<EOF
[Unit]
Description=Monitor and reclaim developer disk space

[Service]
Type=simple
$environment_line
ExecStart=%h/.dotfiles/bin/disk-space-monitor
Restart=always
RestartSec=15
SuccessExitStatus=130 143
Nice=10
IOSchedulingClass=idle
KillMode=control-group
TimeoutStopSec=30

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable disk-space-monitor.service
systemctl --user restart disk-space-monitor.service
echo 'Installed and started disk-space-monitor.service'
