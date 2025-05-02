# Docker Compose wrapper
DC = docker compose

run_trino: 
	docker exec -it trino /bin/trino

up_aiflow: 
	$(DC) up -d airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

stop_aiflow: 
	$(DC) stop airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

start_aiflow: 
	$(DC) start -d airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

down_aiflow: 
	$(DC) down airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

run_airflow_help: 
	$(DC) run airflow-cli "--help"
