#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
YELLOW='\033[0;33m'
nc='\033[0m' 

echo -e "${green}Встановлення ноди Pipe...${nc}"
sleep 3
sudo apt-get update
sudo apt install -y libssl-dev ca-certificates jq
    
if ! command -v docker &> /dev/null; then
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker "$USER"
fi
if ! command -v iptables &> /dev/null; then
sudo apt update && sudo apt install -y iptables
fi

    sudo apt update
    sudo apt install -y iptables-persistent
    

    sudo mkdir -p /opt/popcache && cd /opt/popcache


    echo -e "${YELLOW}Впишіть ваший invite-код:${NC}"
    read INVITE
    
    echo -e "${YELLOW}Ім'я ноди:${NC}"
    read POP_NODE

    echo -e "${YELLOW}UserNAME${NC}"
    read POP_NAME
    
    echo -e "${YELLOW} Telegram-user (без @):${NC}"
    read TELEGRAM
    
    echo -e "${YELLOW} Discord-user:${NC}"
    read DISCORD

    echo -e "${YELLOW}Посилання на ваш Github або Twiiter... :${NC}"
    read WEBSITE
    
    echo -e "${YELLOW}Ваш email:${NC}"
    read EMAIL
    
    echo -e "${YELLOW}Адреса гаманця Solana:${NC}"
    read SOLANA_PUBKEY
    
    eecho -e "${yellow}Введіть обсяг оперативної памʼяті (лише число в GB, напр., 6 або 8):${nc}"
    read RAM_GB
    
    echo -e "${yellow}Введіть максимальний розмір кешу на диску (лише число в GB, напр., 250):${nc}"
    read DISK_GB

    
    response=$(curl -s http://ip-api.com/json)
    
   
    country=$(echo "$response" | jq -r '.country')
    city=$(echo "$response" | jq -r '.city')
    
    POP_LOCATION="$city, $country"

    
    sudo bash -c 'cat > /etc/sysctl.d/99-popcache.conf << EOL
net.ipv4.ip_local_port_range = 1024 65535
net.core.somaxconn = 65535
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
EOL'
    sudo sysctl -p /etc/sysctl.d/99-popcache.conf

    
    sudo bash -c 'cat > /etc/security/limits.d/popcache.conf << EOL
*    hard nofile 65535
*    soft nofile 65535
EOL'

    
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
      URL="https://download.pipe.network/static/pop-v0.3.0-linux-x64.tar.gz"
    else
      URL="https://download.pipe.network/static/pop-v0.3.0-linux-arm64.tar.gz"
    fi
    wget -q "$URL" -O pop.tar.gz
    tar -xzf pop.tar.gz && rm pop.tar.gz
    chmod +x pop
    chmod 755 /opt/popcache/pop


    MB=$(( RAM_GB * 1024 ))
    cat > config.json <<EOL
{
  "pop_name": "${POP_NODE}",
  "pop_location": "${POP_LOCATION}",
  "invite_code": "${INVITE}",
  "server": {"host": "0.0.0.0","port": 443,"http_port": 80,"workers": 0},
  "cache_config": {"memory_cache_size_mb": ${MB},"disk_cache_path": "./cache","disk_cache_size_gb": ${DISK_GB},"default_ttl_seconds": 86400,"respect_origin_headers": true,"max_cacheable_size_mb": 1024},
  "api_endpoints": {"base_url": "https://dataplane.pipenetwork.com"},
  "identity_config": {"node_name": "${POP_NODE}","name": "${POP_NAME}","email": "${EMAIL}","website": "${WEBSITE}","discord": "${DISCORD}","telegram": "${TELEGRAM}","solana_pubkey": "${SOLANA_PUBKEY}"}
}
EOL

    
    for PORT in 80 443; do
    if sudo ss -tulpen | awk '{print $5}' | grep -q ":$PORT\$"; then
    echo -e "${blue}🔒 Порт $PORT зайнятий. Завершуємо процес...${nc}"
    sudo fuser -k ${PORT}/tcp
    sleep 2
    echo -e "${green}✅ Порт $PORT має бути звільнений.${nc}"
    else
    echo -e "${green}✅ Порт $PORT вже вільний.${nc}"
  fi
done

    sudo systemctl stop apache2
    sudo systemctl disable apache2
    
    sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
    sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    sudo sh -c "iptables-save > /etc/iptables/rules.v4"

    cat > Dockerfile << EOL
FROM ubuntu:24.04

# Install dependensi dasar
RUN apt update && apt install -y \\
    ca-certificates \\
    curl \\
    libssl-dev \\
    && rm -rf /var/lib/apt/lists/*

# Buat direktori untuk pop
WORKDIR /opt/popcache

# Salin file konfigurasi & binary dari host
COPY pop .
COPY config.json .

# Berikan izin eksekusi
RUN chmod +x ./pop

# Jalankan node
CMD ["./pop", "--config", "config.json"]
EOL

    docker build -t popnode .
    cd ~

    docker run -d \
      --name popnode \
      -p 80:80 \
      -p 443:443 \
      --restart unless-stopped \
      popnode
    
   