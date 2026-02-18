.PHONY: help elk-up elk-down elk-restart apps-up apps-down apps-restart apps-scale all-up-2x logs-elk logs-apps logs-python logs-dotnet logs-go logs-nodejs logs-rust clean status check-elk check-apps all-up all-down

# Default scaling factor (used by apps-scale and all-up-2x)
SCALE ?= 2

help:
	@echo "ELK Logging Project - Available Commands"
	@echo "========================================="
	@echo ""
	@echo "ELK Stack Management:"
	@echo "  make elk-up          - Start ELK Stack (Elasticsearch, Logstash, Kibana)"
	@echo "  make elk-down        - Stop ELK Stack"
	@echo "  make elk-restart     - Restart ELK Stack"
	@echo "  make check-elk       - Check ELK Stack health"
	@echo ""
	@echo "Applications Management:"
	@echo "  make apps-up         - Start all applications"
	@echo "  make apps-down       - Stop all applications"
	@echo "  make apps-restart    - Restart all applications"
	@echo "  make check-apps      - Check applications status"
	@echo ""
	@echo "Logs:"
	@echo "  make logs-elk        - View ELK Stack logs"
	@echo "  make logs-apps       - View all applications logs"
	@echo "  make logs-python     - View Python app logs"
	@echo "  make logs-dotnet     - View .NET app logs"
	@echo "  make logs-go         - View Go app logs"
	@echo "  make logs-nodejs     - View Node.js app logs"
	@echo "  make logs-rust       - View Rust app logs"
	@echo ""
	@echo "Combined Operations:"
	@echo "  make all-up          - Start everything (ELK + Apps)"
	@echo "  make all-down        - Stop everything"
	@echo "  make status          - Show status of all services"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           - Stop all services and remove volumes"
	@echo "  make clean-all       - Clean everything including images"
	@echo ""

# ELK Stack commands
elk-up:
	@echo "Starting ELK Stack..."
	cd elk-stack && docker compose up -d
	@echo "Waiting for services to be healthy..."
	@sleep 10
	@echo "ELK Stack started!"
	@echo "Elasticsearch: http://localhost:9200"
	@echo "Kibana: http://localhost:5601"
	@echo "Logstash: localhost:5000 (TCP)"

elk-down:
	@echo "Stopping ELK Stack..."
	cd elk-stack && docker compose down

elk-restart:
	@echo "Restarting ELK Stack..."
	cd elk-stack && docker compose restart

# Applications commands
apps-up:
	@echo "Starting applications..."
	cd applications && docker compose up -d
	@echo "Applications started!"

# Scale all app services. Usage: make apps-scale [SCALE=3]
apps-scale:
		@echo "Scaling application services to $(SCALE) replicas..."
		cd applications && docker compose up -d \
			--scale python-app=$(SCALE) \
			--scale dotnet-app=$(SCALE) \
			--scale go-app=$(SCALE) \
			--scale nodejs-app=$(SCALE) \
			--scale rust-app=$(SCALE)
		@echo "Applications scaled!"

apps-down:
	@echo "Stopping applications..."
	cd applications && docker compose down

apps-restart:
	@echo "Restarting applications..."
	cd applications && docker compose restart

# Build applications
apps-build:
	@echo "Building application images..."
	cd applications && docker compose build

# Combined commands
all-up: elk-up
	@echo "Waiting for ELK Stack to be ready..."
	@sleep 30
	@$(MAKE) apps-up
	@echo ""
	@echo "All services started!"
	@echo "Access Kibana at: http://localhost:5601"

# Start ELK then start apps with scaling. Usage: make all-up-2x [SCALE=3]
all-up-2x: elk-up
	@echo "Waiting for ELK Stack to be ready..."
	@sleep 30
	@$(MAKE) apps-scale SCALE=$(SCALE)
	@echo ""
	@echo "All services (scaled to $(SCALE)x) started!"
	@echo "Access Kibana at: http://localhost:5601"

all-down: apps-down elk-down
	@echo "All services stopped!"

# Logs
logs-elk:
	cd elk-stack && docker compose logs -f

logs-apps:
	cd applications && docker compose logs -f

logs-python:
	docker logs -f python-app

logs-dotnet:
	docker logs -f dotnet-app

logs-go:
	docker logs -f go-app

logs-nodejs:
	docker logs -f nodejs-app

logs-rust:
	docker logs -f rust-app

# Status checks
check-elk:
	@echo "Checking ELK Stack health..."
	@echo ""
	@echo "Elasticsearch:"
	@curl -s http://localhost:9200/_cluster/health?pretty || echo "Elasticsearch not responding"
	@echo ""
	@echo "Kibana:"
	@curl -s http://localhost:5601/api/status || echo "Kibana not responding"
	@echo ""
	@echo "Docker containers:"
	@docker ps --filter "name=elasticsearch" --filter "name=logstash" --filter "name=kibana"

check-apps:
	@echo "Checking applications..."
	@docker ps --filter "name=python-app" --filter "name=dotnet-app" --filter "name=go-app" --filter "name=nodejs-app" --filter "name=rust-app"

status: check-elk check-apps

# Clean
clean:
	@echo "Stopping all services and removing volumes..."
	cd applications && docker compose down -v 2>/dev/null || true
	cd elk-stack && docker compose down -v
	@echo "Cleaned!"

clean-all: clean
	@echo "Removing Docker images..."
	docker images | grep -E 'applications|elk-stack' | awk '{print $$3}' | xargs docker rmi -f 2>/dev/null || true
	@echo "All cleaned!"

# Development helpers
kibana-open:
	@echo "Opening Kibana in browser..."
	@which xdg-open > /dev/null && xdg-open http://localhost:5601 || open http://localhost:5601 || echo "Please open http://localhost:5601 in your browser"

elasticsearch-indices:
	@echo "Elasticsearch indices:"
	@curl -s http://localhost:9200/_cat/indices?v

elasticsearch-health:
	@echo "Elasticsearch cluster health:"
	@curl -s http://localhost:9200/_cluster/health?pretty
