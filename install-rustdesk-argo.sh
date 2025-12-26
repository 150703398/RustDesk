#!/usr/bin/env bash
set -e

# ========= 必改 =========
CF_TUNNEL_TOKEN="eyJhIjoiMTcxNjEzYjZkNTdjZTY2YzdhMWQ2OGQzMGEyMDBlYTYiLCJ0IjoiYjNkMzBkODMtYTNhYS00ZThhLTgxM2UtYTIwNDE4NmYwMTk4IiwicyI6Ik1UaGhNelEwTXprdE1Ea3lOUzAwWkdGakxXRmpZelF0TnpkbVl6QTNOamxpWmpVMiJ9"
INSTALL_DIR="/opt/rustdesk"
# ========================

echo "==> 创建目录"
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

echo "==> 安装依赖"
apt update
apt install -y curl tar systemd jq

echo "==> 获取 RustDesk Server 最新版本号"
VERSION=$(curl -s https://api.github.com/repos/rustdesk/rustdesk-server/releases/latest | jq -r .tag_name)

echo "==> 下载 RustDesk Server $VERSION"
curl -L \
  "https://github.com/rustdesk/rustdesk-server/releases/download/${VERSION}/rustdesk-server-linux-amd64.tar.gz" \
  -o rustdesk.tar.gz

echo "==> 解压 RustDesk Server"
tar -xzf rustdesk.tar.gz
chmod +x hbbs hbbr

echo "==> 下载 cloudflared"
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
  -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

echo "==> 创建 systemd 服务"

cat >/etc/systemd/system/rustdesk-argo.service <<EOF
[Unit]
Description=RustDesk Server with Cloudflare Tunnel
After=network.target

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
ExecStart=/bin/bash -c '${INSTALL_DIR}/hbbr & ${INSTALL_DIR}/hbbs -r 127.0.0.1:21117 & /usr/local/bin/cloudflared tunnel run --token ${CF_TUNNEL_TOKEN}'
Restart=always
RestartSec=5
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

echo "==> 启动服务"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable rustdesk-argo
systemctl restart rustdesk-argo

echo "==> 部署完成 🎉"
echo "-----------------------------------"
echo "查看 Key："
echo "journalctl -u rustdesk-argo -n 100"
echo "-----------------------------------"
