#!/bin/bash
# Atualizações (root)
apt update && apt full-upgrade -y
clear
echo "Script executado com Sucesso!"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."