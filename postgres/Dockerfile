FROM postgres:latest

# Copia script de inicialização para o entrypoint do conteiner
COPY ./init.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/init.sh