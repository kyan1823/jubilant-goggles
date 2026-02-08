#!/bin/ash
set -e
CLOUDFLARED_TOKEN="${CLOUDFLARED_TOKEN:-}"

/usr/sbin/sshd &
[ -f /root/frp/frps.toml ] && /usr/local/bin/frps -c /root/frp/frps.toml &
[ -f /root/frp/frpc.toml ] && /usr/local/bin/frpc -c /root/frp/frpc.toml &
[ -f /root/xray/config.json ] && /usr/local/bin/xray -c /root/xray/config.json &
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    cloudflared tunnel run --token "$CLOUDFLARED_TOKEN" &
fi
wait
