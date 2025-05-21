#!/bin/bash

set -e

PROJECT_NAME="virtual-komputer"
CONTAINER_NAME="virtual-komputer"
PORT_WEB=3040
NGROK_LOG="$HOME/${PROJECT_NAME}/ngrok.log"
NGROK_TOKEN="ISI_TOKEN_NGROK_MU_DI_SINI"  # <-- GANTI dengan token ngrok kamu

echo "?? Membuat direktori proyek..."
mkdir -p ~/${PROJECT_NAME}/config/custom-cont-init.d

echo "?? Menyiapkan Docker Compose v2.27.0..."
COMPOSE_VERSION="v2.27.0"
mkdir -p ~/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64 \
  -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
export PATH="$HOME/.docker/cli-plugins:$PATH"
echo "? Docker Compose terinstal: $(docker compose version)"

echo "?? Membuat docker-compose.yml..."
cat > ~/${PROJECT_NAME}/docker-compose.yml <<EOF
services:
  webtop:
    container_name: ${CONTAINER_NAME}
    image: lscr.io/linuxserver/webtop:ubuntu-xfce
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Jakarta
      - WEBTOP_PASSWORD=admin123
    volumes:
      - $HOME/${PROJECT_NAME}/config:/config
    ports:
      - "${PORT_WEB}:3000"
    shm_size: "2gb"
    restart: unless-stopped
EOF

echo "?? Menambahkan auto-installer Chromium & Discord..."
cat > ~/${PROJECT_NAME}/config/custom-cont-init.d/01-install-apps.sh <<'EOF'
#!/bin/bash

echo "?? Menginstal Chromium & Discord..."

apt-get update

# Install Chromium
apt-get install -y chromium

# Install Discord via .deb
DISCORD_DEB="/tmp/discord.deb"
wget -O "$DISCORD_DEB" "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y "$DISCORD_DEB" && \
    rm -f "$DISCORD_DEB"

echo "? Chromium & Discord terinstal."
EOF

chmod +x ~/${PROJECT_NAME}/config/custom-cont-init.d/01-install-apps.sh

echo "?? Menjalankan container..."
cd ~/${PROJECT_NAME}
docker compose up -d

echo "?? Menyiapkan ngrok..."
if ! command -v ngrok >/dev/null; then
  echo "?? Menginstal ngrok..."
  curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
  echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
  sudo apt update && sudo apt install -y ngrok
fi

ngrok config add-authtoken "${NGROK_TOKEN}"

echo "?? Menjalankan ngrok tunnel di port ${PORT_WEB}..."
nohup ngrok http ${PORT_WEB} --log=stdout > "${NGROK_LOG}" 2>&1 &
sleep 8

NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -oE 'https://[a-z0-9\-]+\.ngrok-free\.app' | head -n1)

echo "? Virtual Komputer aktif!"
if [[ -n "$NGROK_URL" ]]; then
  echo "?? Akses Webtop di: ${NGROK_URL}"
else
  echo "?? Gagal mengambil URL ngrok. Cek log di: ${NGROK_LOG}"
fi
