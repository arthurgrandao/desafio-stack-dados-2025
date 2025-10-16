FROM apache/superset:latest-dev

USER superset

# Copiar arquivo de configuração customizado
COPY superset_config.py /app/pythonpath/superset_config.py

# Copiar script de inicialização
COPY init.sh /app/init.sh

# Definir variáveis de ambiente para o Superset encontrar o config
ENV PYTHONPATH=/app/pythonpath:$PYTHONPATH
ENV SUPERSET_CONFIG_PATH=/app/pythonpath/superset_config.py

CMD ["/bin/bash", "/app/init.sh"]
