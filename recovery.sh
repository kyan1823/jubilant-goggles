#!/usr/bin/ash
set -euo pipefail

STORAGE="${STORAGE:-/mnt}"; STORAGE="${STORAGE%/}"

if [ "$(id -u)" -ne 0 ]; then
    exit 255
fi
mkdir -p "${STORAGE}/backup"
latest_backup=$(
    (for f in "${STORAGE}/backup/shadow_"*.bak; do
        [ -e "$f" ] || continue
        base=$(basename "$f")
        ts=${base#shadow_}
        ts=${ts%.bak}
        printf "%s\t%s\n" "$ts" "$f"
    done) | sort -r | head -n1 | cut -f2
)

if [ -z "$latest_backup" ]; then
    exit 1
fi

shadow_line=$(head -n1 "$latest_backup" 2>/dev/null)

if [ -z "$shadow_line" ]; then
    exit 255
fi
if ! echo "$shadow_line" | grep -q '^root:'; then
    exit 255
fi
pwfield=$(printf '%s' "$shadow_line" | cut -d: -f2)
if [ -z "$pwfield" ] || [ "$pwfield" == '!'* ] || [ "$pwfield" == '*'* ]; then
    exit 1
fi
if sed -i "s|^root:*|$shadow_line|" /etc/shadow 2>/dev/null; then
    exit 0
fi
exit 255
