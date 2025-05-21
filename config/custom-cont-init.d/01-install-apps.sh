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
