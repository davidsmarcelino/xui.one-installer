FROM ubuntu:24.04

# Instala dependencias, incluindo a libxml2 que faltava
RUN apt-get update && \
    apt-get install -y sudo wget unzip dos2unix python-is-python3 python3-dev mariadb-server libxml2 && \
    apt-get clean

# Cria o usuário XUI forçadamente para ele sempre existir
RUN useradd -m -d /home/xui -s /bin/bash xui && \
    usermod -aG sudo xui

# Copia os arquivos do repositório
COPY original_xui/database.sql /database.sql
COPY original_xui/xui.tar.gz /xui.tar.gz
COPY install.python3.py /install.python3.py
COPY wrapper.sh /wrapper.sh

# Dá permissão e ajusta o script de boot
RUN chmod +x /wrapper.sh

# Garante que o script rode
CMD ["/wrapper.sh"]
