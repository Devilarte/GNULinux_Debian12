#!/bin/bash
mkdir -p /etc/default/grub.d
echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT apparmor=0"' | tee /etc/default/grub.d/apparmor.cfg
update-grub
clear
echo "Script executado com Sucesso!"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."