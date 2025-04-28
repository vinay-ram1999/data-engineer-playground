# Docker Compose wrapper
DC = docker compose

# Required env vars for .env file validation
REQUIRED_ENV_VARS = AWS_REGION MINIO_REGION MINIO_USER_USERNAME MINIO_USER_PASSWORD AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_S3_ENDPOINT ICEBERG_BUCKET DELTA_LAKE_BUCKET ICEBERG_ENDPOINT DELTA_LAKE_ENDPOINT NESSIE_URI TRINO_URL DB_NAME DB_USERNAME DB_PASSWORD DB_JDBC_URI AIRFLOW_UID AIRFLOW_API_SERVER_URL AIRFLOW_USER_USERNAME AIRFLOW_USER_PASSWORD

# --- Service Mapping ---
# Maps user-friendly names (used with S variable) to actual docker compose service names.
SERVICES_NESSIE = nessie
SERVICES_MINIO = minio
SERVICES_SPARK = spark
SERVICES_TRINO = trino
# SERVICES_ALL is intentionally empty, meaning 'no specific services passed' to docker compose
SERVICES_ALL =

# List valid service group names for help and validation
VALID_SERVICES = nessie minio spark trino all

# Descriptions for each service group (used in help message)
DESC_NESSIE = Nessie Catalog with PostgreSQL database as storage (Depends on PostgreSQL)
DESC_MINIO = MinIO S3-compatible storage
DESC_SPARK = Spark cluster with Jupyter Notebook (Depends on Nessie, MinIO)
DESC_TRINO = Trino distributed SQL query engine for big data analytics
DESC_ALL = All core services

# --- Makefile Configuration ---
# Default target when running 'make' without arguments
.DEFAULT_GOAL := help

# Includes aliases and standalone targets visible in 'make' list/completion.
.PHONY: help down_all \
        nessie minio spark trino all \
        start_nessie start_minio start_spark start_trino start_all \
        stop_nessie stop_minio stop_spark stop_trino stop_all

# --- Generic Command Logic (Internal Targets) ---
# Macro to check if S variable is set and is a valid service group name
define check_service
ifeq ($(strip $(S)),)
	@echo "Error: S variable is required for this command."
	@echo "Usage: make <command> S=<name>" # Referencing the concept of generic commands
	@echo "Valid names: $(VALID_SERVICES)"
	@exit 1
endif
# Check if S is one of the valid service group names
ifeq ($(strip $(filter $(S), $(VALID_SERVICES))),)
	@echo "Error: Invalid S name: '$(S)'"
	@echo "Valid names: $(VALID_SERVICES)"
	@exit 1
endif
# COMPOSE_SERVICES variable is defined based on S being valid
endef

# Variable to map the user-provided S name to actual docker compose service names.
# For S=all, this will resolve to an empty string.
COMPOSE_SERVICES = $(value SERVICES_$(shell echo $(S) | tr 'a-z' 'A-Z'))

_up: _check_env
	$(eval $(call check_service))
	@echo "Executing UP for $(S) services ($(COMPOSE_SERVICES))..."
	$(DC) up -d $(COMPOSE_SERVICES)

_start:
	$(eval $(call check_service))
	@echo "Executing START for $(S) services ($(COMPOSE_SERVICES))...."
	$(DC) start $(COMPOSE_SERVICES)

_stop:
	$(eval $(call check_service))
	@echo "Executing STOP for $(S) services ($(COMPOSE_SERVICES))...."
	$(DC) stop $(COMPOSE_SERVICES)

_down:
	$(eval $(call check_service))
	@echo "Executing DOWN for $(S) services ($(COMPOSE_SERVICES))...."
	$(DC) down $(COMPOSE_SERVICES)


# --- Help Text Generation ---
# Formatted list of service names and their descriptions for generic commands
FORMATTED_SERVICE_DESCRIPTIONS = $(foreach service,$(VALID_SERVICES),\
  $(eval _UPPER_SERVICE = $(shell echo $(service) | tr 'a-z' 'A-ZA-Z'))\
  $(eval _DESC_VARNAME = DESC_$(_UPPER_SERVICE))\
  $(eval _SERVICE_DESC = $(value $(_DESC_VARNAME)))\
  printf "  %-10s : %s\n" $(service) "$(_SERVICE_DESC)";\
)

# Formatted list for 'Start' aliases (nessie, minio, spark, all)
FORMATTED_START_ALIASES = $(foreach service,$(VALID_SERVICES),\
  printf "  %-15s : Start %s service(s)\n" $(service) "$(service)";\
)

# Formatted list for 'Start existing' aliases (start_nessie, ...)
FORMATTED_START_EXISTING_ALIASES = $(foreach service,$(VALID_SERVICES),\
  printf "  %-15s : Start existing %s service(s)\n" start_$(service) "$(service)";\
)

# Formatted list for 'Stop' aliases (stop_nessie, ...)
FORMATTED_STOP_ALIASES = $(foreach service,$(VALID_SERVICES),\
  printf "  %-15s : Stop %s service(s)\n" stop_$(service) "$(service)";\
)


# --- Targets ---
help:
	@echo "Available Service Names and their Descriptions:"
	@$(FORMATTED_SERVICE_DESCRIPTIONS) # Prints service names and their *long* descriptions
	@echo ""

	@echo "Usage: make <alias>"
	@echo ""

	@echo "Aliases:" # <-- Added Aliases header back
	@echo "[uses 'docker compose up -d']"
	@$(FORMATTED_START_ALIASES) # <-- Prints Start aliases
	@echo "" # Separator
	@echo "[uses 'docker compose start']"
	@$(FORMATTED_START_EXISTING_ALIASES) # <-- Prints Start existing aliases
	@echo "" # Separator
	@echo "[uses 'docker compose stop']"
	@$(FORMATTED_STOP_ALIASES) # <-- Prints Stop aliases
	@echo "" # Separator
	@printf "  %-15s : %s\n" "down_all" "Stop and remove ALL project resources [full cleanup]";
	@printf "  %-15s : %s\n" "run_trino" "Opens Trino command line interface";
	@printf "  %-15s : Shows this help message\n" "help"; # Add help itself as an alias
	@echo "" # Separator

	@echo "For status, logs, and other container information, use standard docker commands (e.g., 'docker compose ps', 'docker compose logs <service>')."

### Removed from the help menu
#@echo "Generic Commands [require S=<service_name>]:"
#@echo "  Use these with a service name [S=<name>] to perform actions."
#@echo "  Example: make up S=minio | make down S=spark"
#@echo ""
#@echo "  _up       : Start services [S=all acts on all services]"
#@echo "  _start    : Start existing containers [S=all acts on all services]"
#@echo "  _stop     : Stop running containers [S=all acts on all services]"
#@echo "  _down     : Stop and remove containers [selective by default, S=all performs full cleanup]"
#@echo ""

# Verify that .env exists and contains all REQUIRED_ENV_VARS
_check_env:
	@if [ ! -f .env ]; then \
	  echo "Error: .env file not found."; \
	  exit 1; \
	fi
	@echo "Found .env, checking required variables..."
	@for VAR in $(REQUIRED_ENV_VARS); do \
	  grep -E "^$$VAR=" .env > /dev/null || { \
	    echo "Error: Required variable '$$VAR' not set in .env"; \
	    exit 1; \
	  }; \
	done
	@echo ".env check passed."


# --- Aliases ---
# These targets set the S variable and call the appropriate internal generic target
nessie: _up
nessie: S = nessie

minio: _up
minio: S = minio

spark: _up
spark: S = spark

trino: _up
trino: S = trino

all: _up
all: S = all

# Start aliases
start_nessie: _start
start_nessie: S = nessie

start_minio: _start
start_minio: S = minio

start_spark: _start
start_spark: S = spark

start_trino: _start
start_trino: S = trino

start_all: _start
start_all: S = all

# Stop aliases
stop_nessie: _stop
stop_nessie: S = nessie

stop_minio: _stop
stop_minio: S = minio

stop_spark: _stop
stop_spark: S = spark

stop_trino: _stop
stop_trino: S = trino

stop_all: _stop
stop_all: S = all

# Special target for full project down (stops and removes everything)
down_all:
	@echo "Stopping and removing ALL services defined in docker-compose.yml..."
	$(DC) down

run_trino:
	docker exec -it trino /bin/trino