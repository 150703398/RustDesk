#!/bin/sh
set -e

hbbr &
hbbs -r 127.0.0.1:21117 &
cloudflared tunnel run --token "$CF_TUNNEL_TOKEN"
