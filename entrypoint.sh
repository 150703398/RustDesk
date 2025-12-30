#!/bin/sh
set -e

echo "[+] Starting RustDesk hbbr"
hbbr &

echo "[+] Starting RustDesk hbbs"
hbbs -r 127.0.0.1:21117 &

echo "[+] Starting Cloudflare Tunnel"
cloudflared tunnel run --token "CF_TUNNEL_TOKEN"
