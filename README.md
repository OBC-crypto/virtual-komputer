# virtual-komputer



chmod +x virtual-komputer.sh
./virtual-komputer


docker exec -it virtual-komputer bash



#Script install Discord#

apt update
sudo apt install wget
wget -O discord-0.0.95.deb "https://discord.com/api/download?platform=linux"
sudo apt install ./discord-0.0.95.deb -y

discord --no-sandbox
