.PHONY: docker-build docker-up docker-down docker-logs start restart help

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

# Combined commands
start: docker-build docker-up
	@echo "Docker container is running at http://localhost:8000"

restart: docker-down docker-up
	@echo "Docker container has been restarted at http://localhost:8000"

help:
	@echo "Available commands:"
	@echo "  docker-build   : Build Docker image"
	@echo "  docker-up      : Start Docker container"
	@echo "  docker-down    : Stop Docker container"
	@echo "  docker-logs    : View Docker logs"
	@echo "  start          : Build and start Docker container"
	@echo "  restart        : Restart Docker container" 