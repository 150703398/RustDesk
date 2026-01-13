############################
# Stage 1: 下载 cloudflared
############################
FROM debian:bookworm-slim AS cf

RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
      -o /cloudflared && \
    chmod +x /cloudflared && \
    rm -rf /var/lib/apt/lists/*

############################
# Stage 2: RustDesk Server
############################
FROM rustdesk/rustdesk-server:latest

COPY --from=cf /cloudflared /usr/local/bin/cloudflared
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
