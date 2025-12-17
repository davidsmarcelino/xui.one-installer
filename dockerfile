FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instala dependencias (Adicionado libjpeg-turbo8)
RUN apt-get update && \
    apt-get install -y sudo wget unzip dos2unix python3 python3-pip python3-dev mariadb-server libxml2 libssl1.1 libcurl4 net-tools libpng16-16 libzip-dev libjpeg-turbo8 && \
    apt-get clean

# 2. Cria usuário e pastas
RUN useradd -m -d /home/xui -s /bin/bash xui && \
    usermod -aG sudo xui && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# 3. Copia arquivos
COPY original_xui/database.sql /database.sql
COPY original_xui/xui.tar.gz /xui.tar.gz
COPY install.python3.py /install.python3.py

# 4. Script de inicialização
RUN echo '#!/bin/bash\n\
# Limpa locks antigos do mysql se existirem\n\
rm -f /var/run/mysqld/mysqld.sock\n\
service mysql start\n\
echo "Aguardando MySQL iniciar..."\n\
sleep 10\n\
\n\
if [ -f "/home/xui/status" ]; then\n\
    echo "XUI ja instalado. Corrigindo permissoes..."\n\
    chmod -R 777 /home/xui/bin\n\
    echo "Iniciando XUI..."\n\
    /home/xui/service start\n\
else\n\
    echo "Instalacao limpa iniciando..."\n\
    python3 /install.python3.py\n\
fi\n\
tail -f /dev/null' > /wrapper.sh

RUN chmod +x /wrapper.sh

CMD ["/wrapper.sh"]
