#!/bin/ash
set -e
CLOUDFLARED_TOKEN="${CLOUDFLARED_TOKEN:-}"

cleanup() {
    echo "Received termination signal, shutting down..."
    if [ ! -f /root/backup.sh ]; then
        echo "warn: backup.sh not found"
    elif /bin/ash /root/backup.sh; then
        echo "info: backup success"
    else
        echo "error: backup failed, $result"
    fi
    exit 0
}

trap cleanup TERM INT

if [ ! -f /root/recovery.sh ]; then
    echo "warn: recovery.sh not found"
elif /bin/ash /root/recovery.sh; then
    echo "info: recovery success"
else
    echo "error: recovery failed, $result"
fi
/usr/sbin/sshd &
/usr/sbin/crond -c /etc/crontabs &
[ -f /root/frp/frps.toml ] && /usr/local/bin/frps -c /root/frp/frps.toml &
[ -f /root/frp/frpc.toml ] && /usr/local/bin/frpc -c /root/frp/frpc.toml &
[ -f /root/xray/config.json ] && /usr/local/bin/xray -c /root/xray/config.json &
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    cloudflared tunnel run --token "$CLOUDFLARED_TOKEN" &
fi
wait
