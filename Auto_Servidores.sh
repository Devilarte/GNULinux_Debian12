#!/bin/bash
# Requer dialog
 
tela=inicial
 
while : ; do
 
    case "$tela" in
        #Tela Inicial (MAIN)
        inicial)
            main=$(
                dialog --stdout \
                    --backtitle 'Automação de Servidores Linux' \
                    --title 'Automação de Servidores' \
                    --menu 'Selecione a Distribuição:'\
                    0 0 0 \
                    1 'GNU/Linux Debian' \
                    2 'GNU/Linux Ubuntu' \
            )
            [ $? -ne 0 ] && clear && break
            case "$main" in
                1) tela=grupo_1 ;;
                2) tela=grupo_2 ;;
            esac
        ;;
            #Tela Grupo 1
            grupo_1)
                anterior=inicial
                grupo_1=$(
                  dialog --stdout               \
                         --title 'GNU/Linux Debian'  \
                         --menu 'Selecione o Script:' \
                        0 0 0                   \
                        1 'SubGrupo 1A' \
                        2 'SubGrupo 1B' \
                        3 'SubGrupo 1C' \
                        0 'Voltar' )
 
                [ $? -ne 0 ] && tela=$anterior
 
                case "$grupo_1" in
                     1) tela=subgrupo_1a ;;
                     2) tela=subgrupo_1b ;;
                     3) tela=subgrupo_1c ;;
                     0) tela=$anterior ;;
                esac
            ;;
                subgrupo_1a)
                    anterior=inicial
                    subgrupo_1a=$(
                      dialog --stdout               \
                             --title 'SubGrupo 1A'    \
                             --menu 'Selecione o Script:' \
                            0 0 0                   \
                            1 'Atualização do Sistema' \
                            0 'Voltar' )
 
                    [ $? -ne 0 ] && tela=$anterior
 
                    case "$subgrupo_1a" in
                         1) clear; bash Scripts/grub.sh ;;
                         0) tela=grupo_1 ;;
                    esac
                ;;
                subgrupo_1b)
                    anterior=inicial
                    subgrupo_1b=$(
                      dialog --stdout               \
                             --title 'SubGrupo 1B'    \
                             --menu 'Selecione o Script:' \
                            0 0 0                   \
                            1 'Atualização do Sistema' \
                            0 'Voltar' )
 
                    [ $? -ne 0 ] && tela=$anterior
 
                    case "$subgrupo_1b" in
                         1) clear; bash Scripts/grub.sh ;;
                         0) tela=grupo_1 ;;
                    esac
                ;;
                subgrupo_1c)
                    anterior=inicial
                    subgrupo_1c=$(
                      dialog --stdout               \
                             --title 'SubGrupo 1C'    \
                             --menu 'Selecione o Script:' \
                            0 0 0                   \
                            1 'Atualização do Sistema' \
                            0 'Voltar' )
 
                    [ $? -ne 0 ] && tela=$anterior
 
                    case "$subgrupo_1c" in
                         1) clear; bash Scripts/grub.sh ;;
                         0) tela=grupo_1 ;;
                    esac
                ;;
            #Tela Grupo 2
            grupo_2)
                anterior=inicial
                grupo_2=$(
                  dialog --stdout               \
                         --title 'GNU/Linux Ubuntu'  \
                         --menu 'Selecione o Script:' \
                        0 0 0                   \
                        1 'IDENTIFICA 2a - LALALA' \
                        2 'IDENTIFICA 2b - LALALA' \
                        3 'IDENTIFICA 2c - LALALA' \
                        0 'Voltar' )
 
                [ $? -ne 0 ] && tela=$anterio
 
                case "$grupo_2" in
                     1) clear; echo "AQUI FOI EXECUTADO O SCRIPT"; read -p "Pressione [Enter] para continuar ou CTRL+C para sair..." ;;
                     2) clear; echo "AQUI FOI EXECUTADO O SCRIPT"; read -p "Pressione [Enter] para continuar ou CTRL+C para sair..." ;;
                     3) clear; echo "AQUI FOI EXECUTADO O SCRIPT"; read -p "Pressione [Enter] para continuar ou CTRL+C para sair..." ;;
                     0) tela=$anterior ;;
                esac
            ;;

            *)
                clear
                exit
            ;;
    esac
 
    retorno=$?
    [ $retorno -eq 1   ] && tela=$anterior   # cancelar
    [ $retorno -eq 255 ] break     # Esc
 
done