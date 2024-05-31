#!/bin/bash
# Aplicações Essenciais (root)
apt install -y wget sudo zip unzip locate python3 ca-certificates curl gnupg apt-transport-https bash-completion rsync software-properties-common
ln -s /usr/bin/python3 /usr/bin/python
clear
echo "Script executado com Sucesso!"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."