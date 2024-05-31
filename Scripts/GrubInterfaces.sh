#!/bin/bash
mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT net.ifnames=0 biosdevname=0"' | tee /etc/default/grub.d/interfaces.cfg
update-grub
clear
echo "Script executado com Sucesso!"
echo
echo "É necessário alterar o nome da interface para ethX no arquivo /etc/network/interfaces"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."