# Habilitando Servidor DNS Local
/ip dns
set allow-remote-requests=no servers=172.25.10.10

# Habilitando Servidor NTP Local
/system ntp client
set enabled=yes primary-ntp=172.25.10.10 secondary-ntp=200.160.0.8 server-dns-names=""

# Regras NAT para Forçar Consultas apenas no Servidor DNS Local
/ip firewall nat
add action=dst-nat chain=dstnat comment="## DNS Force" !connection-bytes !connection-limit !connection-mark !connection-rate !connection-type !content disabled=no !dscp !dst-address !dst-address-list !dst-address-type !dst-limit dst-port=53 !fragment !hotspot !icmp-options !in-bridge-port !in-bridge-port-list !in-interface !in-interface-list !ingress-priority !ipsec-policy !ipv4-options !layer7-protocol !limit log=no log-prefix="" !nth !out-bridge-port !out-bridge-port-list !out-interface !out-interface-list !packet-mark !packet-size !per-connection-classifier !port !priority protocol=udp !psd !random !routing-mark !routing-table src-address=!172.25.10.10 !src-address-list !src-address-type !src-mac-address !src-port !tcp-mss !time !tls-host to-addresses=172.25.10.10 to-ports=53 !ttl
add action=dst-nat chain=dstnat comment="## DNS Force" !connection-bytes !connection-limit !connection-mark !connection-rate !connection-type !content disabled=no !dscp !dst-address !dst-address-list !dst-address-type !dst-limit dst-port=53 !fragment !hotspot !icmp-options !in-bridge-port !in-bridge-port-list !in-interface !in-interface-list !ingress-priority !ipsec-policy !ipv4-options !layer7-protocol !limit log=no log-prefix="" !nth !out-bridge-port !out-bridge-port-list !out-interface !out-interface-list !packet-mark !packet-size !per-connection-classifier !port !priority protocol=tcp !psd !random !routing-mark !routing-table src-address=!172.25.10.10 !src-address-list !src-address-type !src-mac-address !src-port !tcp-mss !time !tls-host to-addresses=172.25.10.10 to-ports=53 !ttl

# Script Chacagem Servidor DNS
/system script
add name=CheckDNS policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":log warning \"Checando Servidor DNS...\"\r\n:local DNSLocal \"172.25.10.10\";\r\n:local DNSPublico \"1.1.1.1,8.8.8.8\";\r\n:local DNSAtual;\r\n:set \$DNSAtual [/ip dns get servers];\r\n:log warning \"Servidor DNS: \$DNSAtual\"\r\n:do {\r\n:put [resolve google.com server=\$DNSLocal];\r\nif (\$DNSAtual!=\$DNSLocal) do={\r\n:log warning \"Servidor DNS Local - OK!\"\r\n/ip dns set servers=\$DNSLocal\r\n:log warning \"Habilitando Regras - For\E7ar Consultas DNS Local\"\r\n/ip firewall nat set [find comment=\"## DNS Force\"] disabled=no\r\n} else={}\r\n} on-error={ :set \$DNSAtual [/ip dns get servers];\r\nif (\$DNSAtual!=\$DNSPublico) do={\r\n:log error \"DNS Failover: Mudando para DNS P\FAblico\";\r\n/ip dns set servers=\$DNSPublico;\r\n:log warning \"Desabilitando Regras - For\E7ar Consultas DNS Local\"\r\n/ip firewall nat set [find comment=\"## DNS Force\"] disabled=yes\r\n} else={:log error \"DNS Local Indispon\EDvel no momento!\"}\r\n}"

# Cron Checagem Servidor DNS
/system scheduler
add disabled=no interval=10m name=Cron_CheckDNS on-event=CheckDNS policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon