#!/bin/bash

# Instalar o Redis CacheDB
echo -e "Instalando o Redis CacheDB ..."
curl -fsSL https://packages.redis.io/gpg &>/dev/null;
gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg &>/dev/null;
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list &>/dev/null;
apt update && apt install -y redis-server &>/dev/null;
systemctl daemon-reload &>/dev/null;
systemctl enable redis-server &>/dev/null;

# Exportar as Configurações do redis.conf
cat UnboundRedis/confs/redis.conf > /etc/redis/redis.conf
########################## Fim - Instalação do Redis ##########################

# Compilar e Configurar Unbound DNS Server

## Instalar Dependencias Essenciais
apt install -y bison flex libevent-dev libexpat1-dev libhiredis-dev libnghttp2-dev libprotobuf-c-dev libssl-dev libsystemd-dev protobuf-c-compiler python3-dev swig

## Descompactar Compilação do Unbound
tar -C . -xvzf compiles/unbound.tar.gz
cd unbound_compile/
./configure --build=x86_64-linux-gnu --prefix=/usr --includedir=\${prefix}/include --infodir=\${prefix}/share/info --libdir=\${prefix}/lib/x86_64-linux-gnu --mandir=\${prefix}/share/man --localstatedir=/var --runstatedir=/run --sysconfdir=/etc --with-conf-file=/etc/unbound/unbound.conf --with-run-dir=/var/lib/unbound --with-chroot-dir= --with-dnstap-socket-path=/run/dnstap.sock --enable-ipset --enable-checking --with-libevent --with-libhiredis --with-libnghttp2 --with-pidfile=/run/unbound.pid --with-pythonmodule --with-pyunbound --with-rootkey-file=/var/lib/unbound/root.key --disable-dependency-tracking --disable-flto --disable-maintainer-mode --disable-option-checking --disable-rpath --disable-silent-rules --enable-cachedb --enable-dnstap --enable-subnet --enable-systemd --enable-tfo-client --enable-tfo-server
make && make install

## Adicionar Usuário e Grupo unbound
if ! getent passwd unbound &>/dev/null; then
	adduser --quiet --system --group --no-create-home --home /var/lib/unbound unbound
fi

## Criar Diretório Unbound
[ ! -d /var/lib/unbound ] && { mkdir -p /var/lib/unbound; chown -R unbound:unbound /var/lib/unbound; }

## Copiar Arquivos e Configurar Permissões
[ ! -f /etc/init.d/unbound ] && { cp -p -f UnboundRedis/etc/init.d/unbound /etc/init.d/; chown root:root /etc/init.d/unbound; chmod +x /etc/init.d/unbound; }
[ ! -f /usr/lib/systemd/system/unbound.service ] && { cp -p -f UnboundRedis/usr/lib/systemd/system/unbound.service /usr/lib/systemd/system/; chown root:root /usr/lib/systemd/system/unbound.service; }
[ ! -f /usr/libexec/unbound-helper ] && { cp -p -f UnboundRedis/usr/libexec/unbound-helper /usr/libexec/; chown root:root /usr/libexec/unbound-helper; chmod +x /usr/libexec/unbound-helper; }
[ ! -f /var/lib/unbound/root.hints ] && { cp -p -f UnboundRedis/var/lib/unbound/root.hints /var/lib/unbound/; chown -R unbound:unbound /var/lib/unbound/root.hints; }

## Criar unbound-control Crypto Keys em /etc/unbound/
[ ! -f /etc/unbound/unbound_control.key ] && { unbound-control-setup; }

## Criar e Configurar Permissão na pasta de Logs
mkdir /var/log/unbound && chown -R unbound:unbound /var/log/unbound

## Exportar as Configurações do unbound.conf
cat UnboundRedis/confs/unbound.conf > /etc/unbound/unbound.conf

## Exportar as Configurações do sysctl.conf
cat UnboundRedis/confs/sysctl.conf > /etc/sysctl.conf

## Configurar Blocklist e Root Hints
[ ! -d /opt/unbound/scripts ] && { mkdir -p /opt/unbound/scripts; }
[ ! -f /opt/unbound/scripts/update-blocklists.sh ] && { cp -p -f timers/update-blocklists.sh /opt/unbound/scripts/; chown root:root /opt/unbound/scripts/update-blocklists.sh; chmod +x /opt/unbound/scripts/update-blocklists.sh; }
[ ! -f /opt/unbound/scripts/update-roothints.sh ] && { cp -p -f timers/update-roothints.sh /opt/unbound/scripts/; chown root:root /opt/unbound/scripts/update-roothints.sh; chmod +x /opt/unbound/scripts/update-roothints.sh; }
[ ! -f /etc/systemd/system/unbound-blocklist.timer ] && { cp -p -f timers/unbound-blocklist.timer /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-blocklist.timer; }
[ ! -f /etc/systemd/system/unbound-blocklist.service ] && { cp -p -f timers/unbound-blocklist.service /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-blocklist.service; }
if ! systemctl status unbound-blocklist.timer &>/dev/null; then
	systemctl enable unbound-blocklist.timer &>/dev/null
	systemctl start unbound-blocklist.timer &>/dev/null
fi
[ ! -f /etc/systemd/system/unbound-roothints.timer ] && { cp -p -f timers/unbound-roothints.timer /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-roothints.timer; }
[ ! -f /etc/systemd/system/unbound-roothints.service ] && { cp -p -f timers/unbound-roothints.service /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-roothints.service; }
if ! systemctl status unbound-roothints.timer &>/dev/null; then
	systemctl enable unbound-roothints.timer &>/dev/null
	systemctl start unbound-roothints.timer &>/dev/null
fi

## Configurar as Zonas Local e Anatel
cat UnboundRedis/confs/rpz.block.hosts.local.zone > /etc/unbound/rpz.block.hosts.local.zone
cat UnboundRedis/confs/rpz.block.hosts.anatel.zone > /etc/unbound/rpz.block.hosts.anatel.zone
chown -R unbound:unbound /etc/unbound/rpz.block.hosts.local.zone
chown -R unbound:unbound /etc/unbound/rpz.block.hosts.anatel.zone
[ ! -f /opt/unbound/scripts/update-rpz.sh ] && { cp -p -f timers/unbound-rpz.timer /opt/unbound/scripts/; chown root:root /opt/unbound/scripts/update-rpz.sh; chmod +x /opt/unbound/scripts/update-rpz.sh; }
[ ! -f /etc/systemd/system/unbound-rpz.timer ] && { cp -p -f timers/unbound-rpz.timer /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-rpz.timer; }
[ ! -f /etc/systemd/system/unbound-rpz.service ] && { cp -p -f timers/unbound-rpz.service /etc/systemd/system/; chown root:root /etc/systemd/system/unbound-rpz.service; }
if ! systemctl status unbound-rpz.timer &>/dev/null; then
	systemctl enable unbound-rpz.timer &>/dev/null
	systemctl start unbound-rpz.timer &>/dev/null
fi

# Configurar /etc/resolv.conf
sed -i '1 i############ Configuração Inicial Comentada ############' /etc/resolv.conf
sed -i 's/^/#/' /etc/resolv.conf
echo "#############################################################" >> /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
echo "nameserver ::1" >> /etc/resolv.conf
meuip=($(hostname -I | awk '{print $1}'))
echo "nameserver $meuip" >> /etc/resolv.conf

# Instalar e Configurar o Grafana
apt install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_11.0.0_amd64.deb
dpkg -i grafana_11.0.0_amd64.deb
[ ! -f /etc/grafana/grafana.ini ] && { cp -p -f Apps/UnboundDashboard/confs/grafana.ini /etc/grafana/grafana.ini; chown root:root /etc/grafana/grafana.ini; }
if ! systemctl daemon-reload &>/dev/null; then
	systemctl enable grafana-server.service &>/dev/null
	systemctl start grafana-server.service &>/dev/null
fi

# Instalar e Configurar o Prometheus
apt install prometheus prometheus-node-exporter
[ ! -f /etc/prometheus/prometheus.yml ] && { cp -p -f Apps/UnboundDashboard/confs/prometheus.yml /etc/prometheus/prometheus.yml; chown root:root /etc/prometheus/prometheus.yml; }
if ! systemctl is-enabled prometheus.service &>/dev/null; then
	systemctl restart prometheus.service &>/dev/null
fi

# Copiar e COnfigurar o Unbound-Exporter
[ ! -f /usr/local/bin/unbound-exporter ] && { cp -p -f Apps/UnboundDashboard/compiles/unbound-exporter /usr/local/bin/; chown root:root /usr/local/bin/unbound-exporter; chmod +x /usr/local/bin/unbound-exporter; }
[ ! -f /etc/systemd/system/prometheus-unbound-exporter.service ] && { cp -p -f Apps/UnboundDashboard/confs/prometheus-unbound-exporter.service /etc/systemd/system/; chown root:root /etc/systemd/system/prometheus-unbound-exporter.service; }
if ! systemctl status prometheus-unbound-exporter.service &>/dev/null; then
	systemctl enable prometheus-unbound-exporter.service &>/dev/null
	systemctl start prometheus-unbound-exporter.service &>/dev/null
fi

# Instalar e Configurar o Loki e Promtail
dpkg -i Apps/UnboundDashboard/compiles/loki_2.9.8_amd64.deb
dpkg -i Apps/UnboundDashboard/compiles/promtail_2.9.8_amd64.deb
[ ! -f /etc/loki/config.yml ] && { cp -p -f Apps/UnboundDashboard/confs/loki_config.yml /etc/loki/config.yml; chown root:root /etc/loki/config.yml; }
[ ! -f /etc/promtail/config.yml ] && { cp -p -f Apps/UnboundDashboard/confs/promtail_config.yml /etc/promtail/config.yml; chown root:root /etc/promtail/config.yml; }
if ! systemctl restart loki.service &>/dev/null; then
	systemctl restart promtail.service &>/dev/null
fi

# Copiar e Configurar o Unbound Logrotate
[ ! -f /etc/logrotate.d/unbound ] && { cp -p -f Apps/UnboundDashboard/confs/logrotate_unbound /etc/logrotate.d/unbound; chown root:root /etc/logrotate.d/unbound; }






































# Compilação Unbound DNS Server (root)
sudo useradd -c "DNS Server Unbound" -M unbound
sudo usermod -L unbound
sudo usermod -a -G unbound unbound
wget https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz
tar xzf unbound-latest.tar.gz
cd unbound-{version#}
./configure --build=x86_64-linux-gnu --prefix=/usr --includedir=\${prefix}/include --infodir=\${prefix}/share/info --libdir=\${prefix}/lib/x86_64-linux-gnu --mandir=\${prefix}/share/man --localstatedir=/var --runstatedir=/run --sysconfdir=/etc --with-conf-file=/etc/unbound/unbound.conf --with-run-dir=/var/lib/unbound --with-chroot-dir= --with-dnstap-socket-path=/run/dnstap.sock --enable-ipset --enable-checking --with-libevent --with-libhiredis --with-libnghttp2 --with-pidfile=/run/unbound.pid --with-pythonmodule --with-pyunbound --with-rootkey-file=/var/lib/unbound/root.key --disable-dependency-tracking --disable-flto --disable-maintainer-mode --disable-option-checking --disable-rpath --disable-silent-rules --enable-cachedb --enable-dnstap --enable-subnet --enable-systemd --enable-tfo-client --enable-tfo-server
make && make install
sudo mkdir /var/lib/unbound
sudo chown -R unbound:unbound /var/lib/unbound/
curl -s https://www.internic.net/domain/root.zone | grep "^\.\s\+[0-9]\+\s\+IN\s\+DNSKEY" > root.key
sudo unbound-anchor
sudo mv root.key /var/lib/unbound/
wget -O root.hints https://www.internic.net/domain/named.root
sudo mv root.hints /var/lib/unbound/
crontab -e
##########
1 0 1 */6 * wget -O root.hints https://www.internic.net/domain/named.root
2 0 1 */6 * sudo mv root.hints /var/lib/unbound/
##########
sudo touch /var/lib/unbound/unbound.logs
sudo chown -R unbound:unbound /var/lib/unbound/unbound.logs
wget https://raw.githubusercontent.com/trinib/AdGuard-WireGuard-Unbound-Cloudflare/main/unbound.conf
sudo mv unbound.conf /etc/unbound/unbound.conf.d/
# dnssec
sudo chown -R unbound:unbound /etc/unbound
sudo /usr/sbin/unbound-anchor -a /etc/unbound/root.key -v
# remote control
sudo /usr/sbin/unbound-control-setup
# create /lib/systemd/system/unbound.service, content:
[Unit]
Description=DNS Server Unbound
Documentation=man:unbound(8)
Requires=network.target
After=network.target
Before=network-online.target nss-lookup.target
Wants=nss-lookup.target

[Service]
ExecStartPre=/usr/sbin/unbound-anchor -a /etc/unbound/root.key -v
ExecStart=/usr/sbin/unbound -d -v
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=360

[Install]
WantedBy=multi-user.target
##########
ln -s /etc/unbound/unbound_control.key /var/lib/unbound/unbound_control.key
ln -s /etc/unbound/unbound_control.pem /var/lib/unbound/unbound_control.pem
ln -s /etc/unbound/unbound_server.key /var/lib/unbound/unbound_server.key
ln -s /etc/unbound/unbound_server.pem /var/lib/unbound/unbound_server.pem




# Systemctl Habilitar e Iniciar o Unbound como Serviço
sudo systemctl daemon-reload
sudo systemctl enable unbound.service
sudo systemctl start unbound.service

# Habilitar TCP Fast Open  (root)
sudo nano /etc/sysctl.conf

###################################################################
# Unbound: Habilitar TCP Fast Open - Reduz a latência da rede
net.ipv4.tcp_fastopen=3
###################################################################
# Redis: Modo de Superalocação de Memória Virtual do Kernel
# 0 Supercomprometimento heurístico (padrão)
# 1 Sempre se comprometa demais, nunca verifique
# 2 Sempre verifique, nunca se comprometa demais
vm.overcommit_memory=1

sudo mkdir -p /opt/unbound/blocklists
sudo wget -O /opt/unbound/blocklists/unbound.block.conf https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts


# Instalação do Grafana
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update && sudo apt install -y grafana
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server
sudo systemctl enable grafana-server.service