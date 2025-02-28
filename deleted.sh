#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m' 

echo -e "${yellow}Видалення ноди Pipe...${nc}"

sudo systemctl stop pipe-pop
sudo systemctl disable pipe-pop
sudo rm /etc/systemd/system/pipe-pop.service
sudo systemctl daemon-reload
sleep 1

rm -rf $HOME/pipenetwork

