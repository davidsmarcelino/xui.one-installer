FROM ubuntu:24.04

# 1. Instala dependencias essenciais e a libxml2 que faltava
RUN apt-get update && \
    apt-get install -y sudo wget unzip dos2unix python-is-python3 python3-dev mariadb-server libxml2 && \
    apt-get clean

# 2. Cria o usuário XUI manualmente para evitar o erro "unknown user"
RUN useradd -m -d /home/xui -s /bin/bash xui && \
    usermod -aG sudo xui

# 3. Copia apenas os arquivos que realmente existem no GitHub
COPY original_xui/database.sql /database.sql
COPY original_xui/xui.tar.gz /xui.tar.gz
COPY install.python3.py /install.python3.py

# 4. Cria o script de inicialização (wrapper.sh) via código
RUN echo '#!/bin/bash\n\
if [ -f "/home/xui/status" ]; then\n\
    echo "XUI ja instalado, iniciando servico..."\n\
    service mariadbd start\n\
    /home/xui/service start\n\
else\n\
    echo "Iniciando instalacao limpa..."\n\
    service mariadbd start\n\
    python3 /install.python3.py\n\
fi\n\
tail -f /dev/null' > /wrapper.sh

# 5. Dá permissão de execução ao script criado
RUN chmod +x /wrapper.sh

# 6. Define o comando de entrada
CMD ["/wrapper.sh"]
