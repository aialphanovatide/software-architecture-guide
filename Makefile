.PHONY: docker-build docker-up docker-down docker-logs start restart help

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

# Combined commands
start: docker-build docker-up
	@echo "Docker container is running at http://localhost:8000"

restart: docker-down docker-up
	@echo "Docker container has been restarted at http://localhost:8000"

help:
	@echo "Available commands:"
	@echo "  build          : Build Docker image"
	@echo "  up             : Start Docker container"
	@echo "  down           : Stop Docker container"
	@echo "  logs           : View Docker logs"
	@echo "  start          : Build and start Docker container"
	@echo "  restart        : Restart Docker container" 