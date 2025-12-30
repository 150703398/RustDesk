#!/bin/sh
set -e

echo "[+] Starting RustDesk hbbr"
hbbr &

echo "[+] Starting RustDesk hbbs"
hbbs -r 127.0.0.1:21117 &

echo "[+] Starting Cloudflare Tunnel"
cloudflared tunnel run --token "eyJhIjoiMTcxNjEzYjZkNTdjZTY2YzdhMWQ2OGQzMGEyMDBlYTYiLCJ0IjoiYjNkMzBkODMtYTNhYS00ZThhLTgxM2UtYTIwNDE4NmYwMTk4IiwicyI6Ik1UaGhNelEwTXprdE1Ea3lOUzAwWkdGakxXRmpZelF0TnpkbVl6QTNOamxpWmpVMiJ9"
