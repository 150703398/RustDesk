#!/bin/sh
set -e

echo "=== RustDesk + Cloudflare Tunnel Starting ==="

echo "[1/3] Start hbbr"
hbbr &

echo "[2/3] Start hbbs"
hbbs -r 127.0.0.1:21117 &

echo "[3/3] Start Cloudflare Tunnel"
exec cloudflared tunnel run --token "eyJhIjoiMTcxNjEzYjZkNTdjZTY2YzdhMWQ2OGQzMGEyMDBlYTYiLCJ0IjoiYjNkMzBkODMtYTNhYS00ZThhLTgxM2UtYTIwNDE4NmYwMTk4IiwicyI6Ik1UaGhNelEwTXprdE1Ea3lOUzAwWkdGakxXRmpZelF0TnpkbVl6QTNOamxpWmpVMiJ9"
