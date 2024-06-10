#!/bin/bash
# Redis Server CacheDB  (root)
curl -fsSL https://packages.redis.io/gpg
gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
apt update && apt install -y redis-server
systemctl daemon-reload
systemctl enable redis-server
clear
echo "Redis CacheDB Instalado com Sucesso!"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."