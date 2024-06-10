#!/bin/bash
# Instalação Goland
mkdir Golang && cd Golang
wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
clear
echo "Script executado com Sucesso!"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."