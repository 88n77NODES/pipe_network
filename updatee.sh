#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m' 

echo -e "${green}Оновлення ноди Pipe...${nc}"

sudo systemctl stop pipe-pop
rm -f $HOME/pipenetwork/pop
curl -o $HOME/pipenetwork/pop https://dl.pipecdn.app/v0.2.8/pop
chmod +x $HOME/pipenetwork/pop
$HOME/pipenetwork/pop --refresh
sudo systemctl restart pipe-pop && sudo journalctl -u pipe-pop -f --no-hostname -o cat