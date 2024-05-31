#!/bin/bash
# Desinstalar/Remover toda GUI do Debian (root)
apt purge task-desktop task-german task-german-desktop hyphen-en-us libglu1-mesa libreoffice-* libu2f-udev mythes-en-us x11-apps x11-session-utils xinit xorg xserver-* desktop-base totem gedit gedit-common gir1.2-* gnome-* gstreamer* sound-icons speech-dispatcher totem-common xserver-* xfonts-* xwayland gir1.2* gnome-* vlc*
apt autoremove --purge
clear
echo "Script executado com Sucesso!"
read -p "Pressione [Enter] para continuar ou CTRL+C para sair..."