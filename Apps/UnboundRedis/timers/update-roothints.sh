#!/bin/bash

# Variáveis de Configurações
ROOT_HINTS=/var/lib/unbound/root.hints
ROOT_KEY=/var/lib/unbound/root.key

# Script
## Baixando Lista de Root Servers (root.hints) & Atualizando o Root Dnskey (root.key)
{ echo -e "\e[30;48;5;248mBaixando (root.hints) & Atualizando o (root.key)\e[0m"; } 2> /dev/null
curl --silent -o "$ROOT_HINTS" -L "https://www.internic.net/domain/named.root"
chown -R unbound:unbound /var/lib/unbound
runuser -u unbound -- unbound-anchor
echo -e "root.hints Baixado & root.key Atualizado ..."

## Recarregar configuração do Unbound sem reiniciar
{ echo -e "\e[30;48;5;248mRecarregar Configuração do Unbound\e[0m"; } 2> /dev/null
set -x
unbound-control reload_keep_cache
