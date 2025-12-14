#!make
SERVICE_NAME = gsn_duplicati
CONTAINER_NAME = $(SERVICE_NAME)
DOCKER_COMPOSE_TAG = $(SERVICE_NAME)_1

# Docker Compose Commands
build:
	@echo "🔨 Building duplicati service..."
	docker compose build

run:
	@echo "🚀 Starting duplicati service..."
	docker compose up -d

down-rm:
	docker compose -f ./docker-compose.yml down --remove-orphans --rmi all --volumes
