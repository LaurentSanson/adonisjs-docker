# Makefile

The Makefile provides shortcuts for the most common tasks. To view all available
commands, run `make`.

For example, in the [getting started section](/README.md#getting-started), the
`docker compose` commands can be replaced by:

1. Run `make build` to build fresh images
2. Run `make up` to start in detached mode (no logs)
3. Run `make down` to stop the Docker containers

## Available Targets

### Docker

| Command | Description |
|---------|-------------|
| `make build` | Build Docker images (pull latest, no cache) |
| `make up` | Start containers in detached mode |
| `make start` | Build and start the containers |
| `make down` | Stop containers and remove orphans |
| `make down-v` | Stop containers and remove volumes |
| `make logs` | Show live logs (all containers) |
| `make logs-app` | Show live logs (app container only) |
| `make shell` | Open a shell in the app container |
| `make ps` | Show running containers |
| `make restart` | Restart all containers |
| `make restart-app` | Restart the app container |
| `make clean` | Remove all containers, volumes, and images |

### AdonisJS

| Command | Description |
|---------|-------------|
| `make ace c="make:controller User"` | Run an ace command |
| `make test` | Run tests |
| `make test c="--tags unit"` | Run tests with options |
| `make lint` | Run the linter |

### Database

| Command | Description |
|---------|-------------|
| `make db-migrate` | Run database migrations |
| `make db-rollback` | Rollback the last migration |
| `make db-fresh` | Drop all tables and re-run migrations |
| `make db-seed` | Run database seeders |
| `make db-shell` | Open a database CLI shell |

### Production

| Command | Description |
|---------|-------------|
| `make prod-build` | Build production images |
| `make prod-up` | Start production containers |
| `make prod-down` | Stop production containers |

## Configuration

The Makefile respects the following environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ADONIS_DB` | `postgres` | Database driver (auto-sets `COMPOSE_PROFILES`) |
| `PKG_MANAGER` | `npm` | Package manager used for `make lint` (`npm`, `pnpm`, `yarn`) |

Examples:

```bash
# Use MySQL
ADONIS_DB=mysql make up

# Use pnpm for lint
PKG_MANAGER=pnpm make lint
```

## Template

Copy this into a `Makefile` at the root of your project:

<details>
<summary>View full Makefile</summary>

```makefile
# Executables (local)
DOCKER_COMP = docker compose

# Resolve COMPOSE_PROFILES from ADONIS_DB if not set
ADONIS_DB ?= postgres
COMPOSE_PROFILES ?= $(ADONIS_DB)
export COMPOSE_PROFILES

# Docker containers
APP_CONT = $(DOCKER_COMP) exec app

# Executables
PKG_MANAGER ?= npm
ACE         = $(APP_CONT) node ace
PKG_RUN     = $(APP_CONT) $(PKG_MANAGER) run

# Production compose files
PROD_COMP = $(DOCKER_COMP) -f compose.yaml -f compose.prod.yaml

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start down logs shell ace test lint clean ps restart \
                db-seed db-migrate db-rollback db-fresh db-shell \
                prod-build prod-up prod-down

## —— 🐳 The AdonisJS Docker Makefile 🐳 ——————————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the containers in detached mode (no logs)
	@$(DOCKER_COMP) up -d --wait

start: build up ## Build and start the containers

down: ## Stop the containers
	@$(DOCKER_COMP) down --remove-orphans

down-v: ## Stop containers and remove volumes
	@$(DOCKER_COMP) down --remove-orphans -v

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

logs-app: ## Show live logs for the app container
	@$(DOCKER_COMP) logs --tail=0 --follow app

shell: ## Open a shell in the app container
	@$(APP_CONT) sh

ps: ## Show running containers
	@$(DOCKER_COMP) ps

restart: ## Restart all containers
	@$(DOCKER_COMP) restart

restart-app: ## Restart the app container
	@$(DOCKER_COMP) restart app

clean: ## Remove all containers, volumes, and images
	@$(DOCKER_COMP) down --remove-orphans -v --rmi all

## —— AdonisJS 🎵 ——————————————————————————————————————————————————————————————
ace: ## Run an ace command, pass the parameter "c=" to run a given command, example: make ace c="make:controller User"
	@$(eval c ?=)
	@$(ACE) $(c)

test: ## Run tests, pass the parameter "c=" to add options, example: make test c="--tags unit"
	@$(eval c ?=)
	@$(ACE) test $(c)

lint: ## Run the linter
	@$(PKG_RUN) lint

## —— Database 🗄️ —————————————————————————————————————————————————————————————
db-seed: ## Run database seeders
	@$(ACE) db:seed

db-migrate: ## Run database migrations
	@$(ACE) migration:run

db-rollback: ## Rollback the last migration
	@$(ACE) migration:rollback

db-fresh: ## Drop all tables and re-run migrations
	@$(ACE) migration:fresh

db-shell: ## Open a database shell
	@if [ "$${ADONIS_DB:-postgres}" = "mysql" ]; then \
		$(DOCKER_COMP) exec mysql mysql -u$${DB_USER:-adonis} -p$${DB_PASSWORD:-!ChangeMe!} $${DB_DATABASE:-adonis}; \
	elif [ "$${ADONIS_DB:-postgres}" = "mssql" ]; then \
		echo "Use: docker compose exec mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$$DB_PASSWORD'"; \
	else \
		$(DOCKER_COMP) exec postgres psql -U$${DB_USER:-adonis} -d $${DB_DATABASE:-adonis}; \
	fi

## —— Production 🚀 ———————————————————————————————————————————————————————————
prod-build: ## Build production images
	@$(PROD_COMP) build

prod-up: ## Start production containers
	@$(PROD_COMP) up -d --wait

prod-down: ## Stop production containers
	@$(PROD_COMP) down --remove-orphans
```

</details>

## Adding and Modifying Jobs

Makefiles require tabs for indentation. If your project uses an `.editorconfig`,
make sure it includes:

```editorconfig
[Makefile]
indent_style = tab
```

> [!NOTE]
>
> If you are using Windows, you have to install [chocolatey.org](https://chocolatey.org/)
> or use WSL to use the `make` command.
