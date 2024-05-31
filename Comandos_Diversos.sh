# Salve o nome da interface na variável iname
iname=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}') && echo $iname

# Exibir noma da versão do sistema
echo $(lsb_release -cs)

