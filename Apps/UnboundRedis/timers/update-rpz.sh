#!/bin/bash
# Script gerador de arquivo de Zona RPZ
# Por Luiz Carlos Devilarte
# Em 06/06/2024
# Créditos e Agradecimentos ao grande Prof. Blau Araújo (Shell Script)

# Gerando a Zona Local
cat > /etc/unbound/rpz.block.hosts.local.zone << "EOF"
$TTL 2h
@ IN SOA localhost. root.localhost. (01 6h 1h 1w 2h)
  IN NS localhost.
; RPZ Block Hosts Local
EOF
BlockListAnatel=($(wget -qO - https://raw.githubusercontent.com/Devilarte/BlockLists/main/BlockList_Local))
for url in "${BlockListAnatel[@]/$'\r'/}"
do
echo "*.${url} CNAME ."
echo "${url} CNAME ."
done >> /etc/unbound/rpz.block.hosts.local.zone

# Gerando a Zona Anatel
cat > /etc/unbound/rpz.block.hosts.anatel.zone << "EOF"
$TTL 2h
@ IN SOA localhost. root.localhost. (02 6h 1h 1w 2h)
  IN NS localhost.
; RPZ Block Hosts Anatel
EOF
BlockListAnatel=($(wget -qO - https://raw.githubusercontent.com/Devilarte/BlockLists/main/BlockList_Anatel))
for url in "${BlockListAnatel[@]/$'\r'/}"
do
echo "*.${url} CNAME ."
echo "${url} CNAME ."
done >> /etc/unbound/rpz.block.hosts.anatel.zone
