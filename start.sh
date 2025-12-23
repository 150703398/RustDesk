#!/bin/bash
set -e

cd "$(dirname "$0")"

export TUIC_PORT=24579
export HY2_PORT=25157
export REALITY_PORT=25157

export FILE_PATH="$PWD/.data"
mkdir -p "$FILE_PATH"

echo "[INIT] Working dir: $PWD"

# ---------- UUID 固定 ----------
UUID_FILE="$FILE_PATH/uuid.txt"
if [ -f "$UUID_FILE" ]; then
  UUID=$(cat "$UUID_FILE")
else
  UUID=$(cat /proc/sys/kernel/random/uuid)
  echo "$UUID" > "$UUID_FILE"
fi

# ---------- 下载 sing-box ----------
if [ ! -f "$FILE_PATH/sb" ]; then
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    URL="https://amd64.ssss.nyc.mn/sb"
  else
    URL="https://arm64.ssss.nyc.mn/sb"
  fi
  curl -L -o "$FILE_PATH/sb" "$URL"
  chmod +x "$FILE_PATH/sb"
fi

# ---------- Reality Key ----------
KEY_FILE="$FILE_PATH/reality.key"
if [ -f "$KEY_FILE" ]; then
  PRIVATE_KEY=$(grep PrivateKey "$KEY_FILE" | awk '{print $2}')
  PUBLIC_KEY=$(grep PublicKey "$KEY_FILE" | awk '{print $2}')
else
  OUT=$("$FILE_PATH/sb" generate reality-keypair)
  echo "$OUT" > "$KEY_FILE"
  PRIVATE_KEY=$(echo "$OUT" | awk '/PrivateKey/ {print $2}')
  PUBLIC_KEY=$(echo "$OUT" | awk '/PublicKey/ {print $2}')
fi

# ---------- TLS ----------
openssl ecparam -genkey -name prime256v1 -out "$FILE_PATH/key.pem" 2>/dev/null
openssl req -new -x509 -days 3650 -key "$FILE_PATH/key.pem" \
  -out "$FILE_PATH/cert.pem" -subj "/CN=bing.com" 2>/dev/null

# ---------- sing-box config ----------
cat > "$FILE_PATH/config.json" <<EOF
{
  "log": { "disabled": true },
  "inbounds": [
    {
      "type": "tuic",
      "listen": "::",
      "listen_port": 24579,
      "users": [{ "uuid": "$UUID", "password": "admin" }],
      "congestion_control": "bbr",
      "tls": {
        "enabled": true,
        "alpn": ["h3"],
        "certificate_path": "$FILE_PATH/cert.pem",
        "key_path": "$FILE_PATH/key.pem"
      }
    },
    {
      "type": "hysteria2",
      "listen": "::",
      "listen_port": 25157,
      "users": [{ "password": "$UUID" }],
      "masquerade": "https://bing.com",
      "tls": {
        "enabled": true,
        "alpn": ["h3"],
        "certificate_path": "$FILE_PATH/cert.pem",
        "key_path": "$FILE_PATH/key.pem"
      }
    },
    {
      "type": "vless",
      "listen": "::",
      "listen_port": 25157,
      "users": [{ "uuid": "$UUID", "flow": "xtls-rprx-vision" }],
      "tls": {
        "enabled": true,
        "server_name": "www.nazhumi.com",
        "reality": {
          "enabled": true,
          "handshake": {
            "server": "www.nazhumi.com",
            "server_port": 443
          },
          "private_key": "$PRIVATE_KEY",
          "short_id": [""]
        }
      }
    }
  ],
  "outbounds": [{ "type": "direct" }]
}
EOF

# ---------- 启动 sing-box ----------
"$FILE_PATH/sb" run -c "$FILE_PATH/config.json" &
SB_PID=$!

# ---------- 启动 Node（假官网 + Watchdog） ----------
node index.js &

wait $SB_PID
