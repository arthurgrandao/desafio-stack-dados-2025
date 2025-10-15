from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

# Defina o DAG
with DAG(
    dag_id="test_dag_connection",
    start_date=datetime(2025, 10, 15),
    schedule=None,  # execução manual
    catchup=False,
    tags=["test"],
) as dag:

    # Operador que testa a conexão e faz uma gravação simples
    test_connection = SQLExecuteQueryOperator(
        task_id="test_connection",
        conn_id="analytics",
        sql="""
            CREATE TABLE IF NOT EXISTS test_table (
                id SERIAL PRIMARY KEY,
                num INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            INSERT INTO test_table (num) VALUES (FLOOR(RANDOM() * 100001)::INTEGER);
        """,
    )

    test_connection
