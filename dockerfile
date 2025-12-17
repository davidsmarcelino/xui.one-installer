FROM ubuntu:20.04

# Evita perguntas de fuso horário durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instala dependencias (Ubuntu 20.04 possui a libssl1.1 necessária)
RUN apt-get update && \
    apt-get install -y sudo wget unzip dos2unix python3 python3-pip python3-dev mariadb-server libxml2 libssl1.1 && \
    apt-get clean

# 2. Cria o usuário e a pasta do Socket do MySQL
RUN useradd -m -d /home/xui -s /bin/bash xui && \
    usermod -aG sudo xui && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# 3. Copia arquivos do GitHub para dentro da imagem
COPY original_xui/database.sql /database.sql
COPY original_xui/xui.tar.gz /xui.tar.gz
COPY install.python3.py /install.python3.py

# 4. Script de inicialização (Wrapper)
RUN echo '#!/bin/bash\n\
# Inicia o MySQL e aguarda\n\
service mariadb start\n\
echo "Aguardando MySQL iniciar..."\n\
sleep 10\n\
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
