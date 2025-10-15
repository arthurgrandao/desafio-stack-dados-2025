#!/bin/bash
set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Iniciando configuração do PostgreSQL${NC}"
echo -e "${GREEN}========================================${NC}"

# Verifica variáveis de ambiente
for var in AIRFLOW_PSQL_USER AIRFLOW_PSQL_PASS SUPERSET_PSQL_USER SUPERSET_PSQL_PASS; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}ERRO: Variável $var não definida${NC}"
        exit 1
    fi
done

# Criar usuários
echo -e "${YELLOW}Criando usuários...${NC}"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER $AIRFLOW_PSQL_USER WITH PASSWORD '$AIRFLOW_PSQL_PASS';
    CREATE USER $SUPERSET_PSQL_USER WITH PASSWORD '$SUPERSET_PSQL_PASS';
EOSQL
echo -e "${GREEN}✓ Usuários criados${NC}"

# Criar bancos e schemas
declare -A bancos_schemas=(
    ["airflow_meta"]="airflow"
    ["superset_meta"]="superset"
    ["analytics"]="analytics"
)

for db in "${!bancos_schemas[@]}"; do
    schema=${bancos_schemas[$db]}
    echo -e "${YELLOW}Criando banco $db e schema $schema...${NC}"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE DATABASE $db;
EOSQL
    if [ "$db" != "analytics" ]; then
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" <<-EOSQL
            CREATE SCHEMA IF NOT EXISTS $schema AUTHORIZATION $POSTGRES_USER;
EOSQL
    fi
    echo -e "${GREEN}✓ Banco $db e schema $schema criado${NC}"
done

# Conceder privilégios nos schemas específicos
echo -e "${YELLOW}Concedendo privilégios nos schemas...${NC}"

# airflow_meta
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "airflow_meta" <<-EOSQL
    GRANT USAGE, CREATE ON SCHEMA airflow TO $AIRFLOW_PSQL_USER;

    -- Privilégios em objetos existentes (se houver)
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA airflow TO $AIRFLOW_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA airflow TO $AIRFLOW_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA airflow TO $AIRFLOW_PSQL_USER;

    -- DEFAULT PRIVILEGES para novos objetos
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA airflow
        GRANT ALL ON TABLES TO $AIRFLOW_PSQL_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA airflow
        GRANT ALL ON SEQUENCES TO $AIRFLOW_PSQL_USER;
EOSQL

# superset_meta
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "superset_meta" <<-EOSQL
    GRANT USAGE, CREATE ON SCHEMA superset TO $SUPERSET_PSQL_USER;

    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA superset TO $SUPERSET_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA superset TO $SUPERSET_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA superset TO $SUPERSET_PSQL_USER;

    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA superset
        GRANT ALL ON TABLES TO $SUPERSET_PSQL_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA superset
        GRANT ALL ON SEQUENCES TO $SUPERSET_PSQL_USER;
EOSQL

# Banco analytics compartilhado
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "analytics" <<-EOSQL
    -- Dar CONNECT ao banco
    GRANT CONNECT ON DATABASE analytics TO $AIRFLOW_PSQL_USER;
    GRANT CONNECT ON DATABASE analytics TO $SUPERSET_PSQL_USER;

    -- Schema default (public)
    GRANT USAGE, CREATE ON SCHEMA public TO $AIRFLOW_PSQL_USER;
    GRANT USAGE, CREATE ON SCHEMA public TO $SUPERSET_PSQL_USER;

    -- Objetos existentes
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $AIRFLOW_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $SUPERSET_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $AIRFLOW_PSQL_USER;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $SUPERSET_PSQL_USER;

    -- DEFAULT PRIVILEGES
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA public
        GRANT ALL ON TABLES TO $AIRFLOW_PSQL_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA public
        GRANT ALL ON TABLES TO $SUPERSET_PSQL_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA public
        GRANT ALL ON SEQUENCES TO $AIRFLOW_PSQL_USER;
    ALTER DEFAULT PRIVILEGES FOR ROLE $POSTGRES_USER IN SCHEMA public
        GRANT ALL ON SEQUENCES TO $SUPERSET_PSQL_USER;
EOSQL

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Configuração concluída com sucesso!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

exec "$@"
