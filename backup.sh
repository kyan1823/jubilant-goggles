#!/usr/bin/ash
set -euo pipefail

STORAGE="${STORAGE:-/mnt}"; STORAGE="${STORAGE%/}"
ts=$(date +%F_%H%M%S)

if [ "$(id -u)" -ne 0 ]; then
    exit 255
fi
shadow_line=$(grep '^root:' /etc/shadow || true)
if [ -z "$shadow_line" ]; then
    exit 255
fi

pwfield=$(printf '%s' "$shadow_line" | cut -d: -f2)
if [ -z "$pwfield" ] || [[ "$pwfield" == '!'* ]] || [[ "$pwfield" == '*'* ]]; then
    exit 1
fi
mkdir -p "${STORAGE}/backup" && echo $shadow_line > "${STORAGE}/backup/shadow_$ts.bak"

