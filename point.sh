#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m' 

echo -e "${green}Перевіряємо поїнти Pipe...${nc}"

sleep 2
cd
cd $HOME/pipenetwork/
./pop --points