# Makefile for AdonisJS Docker
# Usage: make [target]

.PHONY: help build up down logs shell test lint clean

# Default target
.DEFAULT_GOAL := help

# Resolve COMPOSE_PROFILES from ADONIS_DB if not set
ADONIS_DB ?= postgres
COMPOSE_PROFILES ?= $(ADONIS_DB)
export COMPOSE_PROFILES

# Colors
YELLOW := \033[1;33m
GREEN := \033[0;32m
NC := \033[0m

help: ## Show this help
	@echo "$(GREEN)AdonisJS Docker$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make [target]"
	@echo ""
	@echo "$(YELLOW)Quick start:$(NC)"
	@echo "  make up                                    # Default: web kit + postgres"
	@echo "  ADONIS_KIT=api make up                     # API starter kit"
	@echo "  ADONIS_DB=mysql make up                    # Use MySQL"
	@echo "  PKG_MANAGER=pnpm ADONIS_KIT=api make up    # Use pnpm + API kit"
	@echo ""
	@echo "$(YELLOW)Targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

build: ## Build Docker images
	docker compose build --pull --no-cache

up: ## Start containers
	docker compose up -d --wait

start: build up ## Build and start the containers

up-logs: ## Start containers and follow logs
	docker compose up

down: ## Stop and remove containers
	docker compose down --remove-orphans

down-v: ## Stop containers and remove volumes
	docker compose down --remove-orphans -v

logs: ## Show container logs
	docker compose logs -f

logs-app: ## Show app container logs
	docker compose logs -f app

shell: ## Open a shell in the app container
	docker compose exec app sh

ace: ## Run an ace command (usage: make ace CMD="make:controller User")
	docker compose exec app node ace $(CMD)

test: ## Run tests
	docker compose exec app node ace test

lint: ## Run linter (if configured)
	docker compose exec app npm run lint 2>/dev/null || echo "No lint script found"

clean: ## Remove all containers, volumes, and images
	docker compose down --remove-orphans -v --rmi all

ps: ## Show running containers
	docker compose ps

restart: ## Restart containers
	docker compose restart

restart-app: ## Restart app container
	docker compose restart app

# Database targets
db-seed: ## Run database seeders
	docker compose exec app node ace db:seed

db-migrate: ## Run database migrations
	docker compose exec app node ace migration:run

db-rollback: ## Rollback last migration
	docker compose exec app node ace migration:rollback

db-fresh: ## Drop all tables and re-run migrations
	docker compose exec app node ace migration:fresh

db-shell: ## Open database shell (PostgreSQL by default)
	@if [ "$${ADONIS_DB:-postgres}" = "mysql" ]; then \
		docker compose exec mysql mysql -u$${DB_USER:-adonis} -p$${DB_PASSWORD:-!ChangeMe!} $${DB_DATABASE:-adonis}; \
	elif [ "$${ADONIS_DB:-postgres}" = "mssql" ]; then \
		echo "Use: docker compose exec mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$${DB_PASSWORD}'"; \
	else \
		docker compose exec postgres psql -U$${DB_USER:-adonis} -d $${DB_DATABASE:-adonis}; \
	fi

# Production targets
prod-build: ## Build production image
	docker compose -f compose.yaml -f compose.prod.yaml build

prod-up: ## Start production containers
	docker compose -f compose.yaml -f compose.prod.yaml up -d --wait

prod-down: ## Stop production containers
	docker compose -f compose.yaml -f compose.prod.yaml down --remove-orphans
