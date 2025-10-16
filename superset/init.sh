#!/bin/bash
set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🏗️  Inicializando o Superset...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n${YELLOW}📊 Atualizando banco de dados...${NC}"

superset db upgrade

echo -e "${GREEN}✅ Banco de dados atualizado com sucesso${NC}"
echo -e "\n${YELLOW}👤 Criando usuário admin...${NC}"

superset fab create-admin \
  --username "${SUPERSET_ADMIN_USERNAME:-admin}" \
  --firstname Superset \
  --lastname Admin \
  --email "${SUPERSET_ADMIN_EMAIL:-admin@example.com}" \
  --password "${SUPERSET_ADMIN_PASSWORD:-admin}" || true

echo -e "${GREEN}✅ Usuário admin configurado${NC}"
echo -e "\n${YELLOW}⚙️  Inicializando Superset...${NC}"

superset init

echo -e "${GREEN}✅ Superset inicializado${NC}"
echo -e "\n${YELLOW}🔗 Configurando conexão com PostgreSQL...${NC}"

superset set_database_uri -d "PostgreSQL" -u "${SUPERSET_CONN_ANALYTICS}"

echo -e "${GREEN}✅ Conexão PostgreSQL configurada${NC}"
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 Iniciando o servidor Superset...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

gunicorn -w 4 -b 0.0.0.0:8088 "superset.app:create_app()"

exec "$@"