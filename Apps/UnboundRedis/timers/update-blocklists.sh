#!/bin/bash

# Variáveis de Configurações
BLOCKLIST_DIR=/opt/unbound/blocklists
WHITELIST_DIR=/opt/unbound/whitelists
STEVEN_BLOCKLIST=$BLOCKLIST_DIR/steven.hosts
UNBOUND_BLOCKLIST=$BLOCKLIST_DIR/unbound.block.conf

# Script
## StevenBlack
{ echo -e "\e[30;48;5;248mBaixando Lista de Bloqueio de StevenBlack\e[0m"; } 2> /dev/null
curl --silent -o "$STEVEN_BLOCKLIST" -L "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
echo -e "Lista de hosts baixada ..."
sed -i -E -n 's/#.*//;s/[ ^I]*$//;/^$/d;/0.0.0.0 0.0.0.0$/d;/0.0.0.0/p' $STEVEN_BLOCKLIST
echo -e "Lista de hosts limpa ..."

# ** Outras listas de hosts podem ser adicionadas aqui, analise com sed para remover comentários e linhas em branco

## Criar arquivo de Bloqueio para o Unbound
{ echo -e "\e[30;48;5;248mCriando Lista de Bloqueio para o Unbound\e[0m"; } 2> /dev/null
echo -n "" > $UNBOUND_BLOCKLIST
sed -E -n '/0.0.0.0/p' $STEVEN_BLOCKLIST >> $UNBOUND_BLOCKLIST

# ** Mesclar outras listas de hosts aqui para Lista de Bloqueio do Unbound

LC_COLLATE=C sort -uf -o $UNBOUND_BLOCKLIST{,}

# ** Dois formatos de Lista de Bloqueio para o Unbound são fornecidos abaixo, Always_null (0.0.0.0) e Redirecionamento para IP. Use o que você preferir:
# Sempre Nulo (Always_null)
sed -i -E -n 's/0.0.0.0 /local-zone: "/;/local-zone:/s/$/." always_null/p' $UNBOUND_BLOCKLIST
# Redirecionamento para IP (Redirect to IP)
# sed -i -E -n 's/0.0.0.0 /local-zone: "/;/local-zone:/s/$/." redirect/p;s/local-zone: /local-data: /;/local-data:/s/" redirect/ A 127.0.0.1"/p' $UNBOUND_BLOCKLIST

sed -i '1s/^/server:\n/' $UNBOUND_BLOCKLIST
echo -e "Listas classificadas e mescladas exclusivamente no formato de Lista de Bloqueio do Unbound ..."

## Recarregar configuração do Unbound sem reiniciar
{ echo -e "\e[30;48;5;248mRecarregar Configuração do Unbound\e[0m"; } 2> /dev/null
set -x
unbound-control reload_keep_cache
