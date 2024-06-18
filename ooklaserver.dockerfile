FROM ubuntu:bionic

WORKDIR /var/www

# Atualização do Sistema
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Instalação do Ookla Server
RUN wget https://install.speedtest.net/ooklaserver/ooklaserver.sh && \
    chmod a+x ooklaserver.sh && \
    ./ooklaserver.sh install -f

# Instalação do 


# Expose the default port
EXPOSE 8080 5060

CMD ["./ooklaserver.sh", "start"]