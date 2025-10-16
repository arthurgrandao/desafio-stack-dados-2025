import os

# ---------------------------------------------------------
# Superset Configuration usando variáveis de ambiente
# ---------------------------------------------------------

# Chave secreta para segurança
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY', 'your-secret-key-here')

# SQLAlchemy Database URI - Metadatabase do Superset (Postgres)
SQLALCHEMY_DATABASE_URI = os.environ.get(
    'SUPERSET_SQLALCHEMY_DATABASE_URI',
    'sqlite:////app/superset_home/superset.db' # Padrão
)

# Porta onde o Superset irá rodar
SUPERSET_WEBSERVER_PORT = int(os.environ.get('SUPERSET_PORT', 8088))

# ---------------------------------------------------------
# Superset Configuration padrão
# ---------------------------------------------------------

# Ambiente
# -----------------------
SUPERSET_ENV = "development"

# Configurações de sessão
# -----------------------
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SECURE = False  # Mude para True se usar HTTPS
SESSION_COOKIE_SAMESITE = 'Lax'

# Configurações de segurança
# --------------------------
WTF_CSRF_ENABLED = True
WTF_CSRF_EXEMPT_LIST = []
WTF_CSRF_TIME_LIMIT = None
