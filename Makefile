# Docker Compose wrapper
DC = docker compose

fetch_jars:
	bash download_jars.sh

run_unity:
	docker exec -it unity /bin/bash

run_trino: 
	docker exec -it trino /bin/trino

up_airflow: 
	$(DC) up -d airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

stop_airflow: 
	$(DC) stop airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

start_airflow: 
	$(DC) start airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

down_airflow: 
	$(DC) down airflow-apiserver airflow-scheduler airflow-dag-processor airflow-triggerer

# run_airflow_help: 
# 	$(DC) run airflow-cli "--help"

spark_submit:
	docker exec spark spark-submit --master spark://spark:7077 --deploy-mode client ./apps/$(app)

stop_spark: 
	$(DC) stop spark spark-history spark-worker

start_spark: 
	$(DC) start spark spark-history spark-worker

down_spark: 
	$(DC) down spark spark-history spark-worker

down_spark_worker: 
	$(DC) down spark-worker

up_spark:
	make down_spark_worker && $(DC) up -d spark-worker

up_spark_scaled:
	make down_spark_worker && $(DC) up -d spark-worker --scale spark-worker=3
