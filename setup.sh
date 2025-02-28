#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m' 

echo -e "${green}Встановлення ноди Pipe...${nc}"

sudo apt update -y && sudo apt upgrade -y
sudo apt install curl -y
sudo apt install bc -y
sleep 1

cho -e "${green}Створення необхідних папок${nc}" 
mkdir -p $HOME/pipenetwork
mkdir -p $HOME/pipenetwork/download_cache

curl -o $HOME/pipenetwork/pop https://dl.pipecdn.app/v0.2.8/pop
chmod +x $HOME/pipenetwork/pop
$HOME/pipenetwork/pop --refresh

echo -e "${yellow}Пропишіть к-сть оперативної пам’яті для ноди:${nc}"
read -p "RAM: " ram
echo -e "${yellow}Пропишіть к-сть вільного дискового простору для ноди:${nc}"
read -p "Max-disk: " max_disk
echo -e "${yellow}Введіть адресу гаманця Solana:${nc}"
read -p "pubKey: " pubKey

echo -e "ram=$ram\nmax-disk=$max_disk\ncache-dir=$HOME/pipenetwork/download_cache\npubKey=$pubKey" > $HOME/pipenetwork/.env

echo -e "${green}Створення та запуск системного сервісу${nc}" 
USERNAME=$(whoami)
HOME_DIR=$(eval echo ~$USERNAME)

sudo tee /etc/systemd/system/pipe-pop.service > /dev/null << EOF
[Unit]
Description=Pipe POP Node Service
After=network.target
Wants=network-online.target

[Service]
User=$USERNAME
Group=$USERNAME
WorkingDirectory=$HOME_DIR/pipenetwork
ExecStart=$HOME_DIR/pipenetwork/pop \
    --ram $ram \
    --max-disk $max_disk \
    --cache-dir $HOME_DIR/pipenetwork/download_cache \
    --pubKey $pubKey
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node

[Install]
WantedBy=multi-user.target
EOF

echo -e "${green}перезапуск системного сервісу${nc}" 
sudo systemctl daemon-reload
sleep 1
sudo systemctl enable pipe-pop
sudo systemctl start pipe-pop

echo -e "${yellow}----------------------------------------------${nc}"
echo -e "${green}Команда для перегляду логів:${nc}"
echo "sudo journalctl -u pipe-pop -f --no-hostname -o cat"
echo -e "${yellow}----------------------------------------------${nc}"
sleep 2

sudo journalctl -u pipe-pop -f --no-hostname -o cat
