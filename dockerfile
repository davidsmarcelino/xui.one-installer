FROM ubuntu:24.04

# 1. Instala dependencias
RUN apt-get update && \
    apt-get install -y sudo wget unzip dos2unix python-is-python3 python3-dev mariadb-server libxml2 && \
    apt-get clean

# 2. Prepara usuario e pastas
RUN useradd -m -d /home/xui -s /bin/bash xui && \
    usermod -aG sudo xui && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# 3. Copia arquivos
COPY original_xui/database.sql /database.sql
COPY original_xui/xui.tar.gz /xui.tar.gz
COPY install.python3.py /install.python3.py

# 4. Script que inicia o Banco ANTES de rodar o Python
RUN echo '#!/bin/bash\n\
service mariadb start\n\
echo "Aguardando MySQL iniciar..."\n\
sleep 15\n\
\n\
if [ -f "/home/xui/status" ]; then\n\
    echo "XUI ja instalado. Iniciando..."\n\
    /home/xui/service start\n\
else\n\
    echo "Instalacao limpa iniciando..."\n\
    python3 /install.python3.py\n\
fi\n\
tail -f /dev/null' > /wrapper.sh

RUN chmod +x /wrapper.sh

CMD ["/wrapper.sh"]
