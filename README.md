# AdonisJS Docker

A Docker-based development and production environment for [AdonisJS](https://adonisjs.com/) v6.

## Getting Started

Run this command to create a new AdonisJS project and start the development environment:

```bash
docker compose up --wait
```

Open https://localhost:3333 in your browser.

**That's it.** The first run will automatically scaffold a new AdonisJS project using the default options (web kit, PostgreSQL, session auth, npm).

## Configuration Options

All options are configured via environment variables, passed on the command line or in an `.env` file. Options are used **on first run only** (when creating the AdonisJS project).

### Starter Kit

```bash
ADONIS_KIT=api docker compose up --wait
```

| Value | Description |
|-------|-------------|
| `web` | Server-rendered web applications (default) |
| `api` | JSON API servers |
| `slim` | Minimal framework setup (no database/auth) |
| `inertia` | Server-driven single-page applications |

### Package Manager

```bash
PKG_MANAGER=pnpm docker compose up --wait
```

| Value | Description |
|-------|-------------|
| `npm` | Node Package Manager (default) |
| `pnpm` | Fast, disk space efficient package manager |
| `yarn` | Yarn package manager |

### Database

```bash
ADONIS_DB=mysql COMPOSE_PROFILES=mysql docker compose up --wait
```

| Value | `COMPOSE_PROFILES` | Description |
|-------|-------------------|-------------|
| `postgres` | `postgres` | PostgreSQL (default) |
| `mysql` | `mysql` | MySQL |
| `mssql` | `mssql` | Microsoft SQL Server |
| `sqlite` | _(empty)_ | SQLite (no database service needed) |

> **Note:** `COMPOSE_PROFILES` must match `ADONIS_DB` to start the correct database service. When using the Makefile, this is handled automatically.

### Auth Guard

```bash
ADONIS_AUTH=access_tokens docker compose up --wait
```

| Value | Description |
|-------|-------------|
| `session` | Session-based authentication (default) |
| `access_tokens` | API token-based authentication |
| `basic_auth` | HTTP Basic authentication |

### Inertia Options (when `ADONIS_KIT=inertia`)

```bash
ADONIS_KIT=inertia ADONIS_INERTIA_ADAPTER=vue ADONIS_INERTIA_SSR=true docker compose up --wait
```

| Variable | Values | Default |
|----------|--------|---------|
| `ADONIS_INERTIA_ADAPTER` | `react`, `vue`, `solid`, `svelte` | `react` |
| `ADONIS_INERTIA_SSR` | `true`, `false` | `false` |

### Combining Options

```bash
PKG_MANAGER=pnpm \
ADONIS_KIT=api \
ADONIS_DB=postgres \
ADONIS_AUTH=access_tokens \
COMPOSE_PROFILES=postgres \
docker compose up --wait
```

Or with the Makefile (auto-resolves `COMPOSE_PROFILES`):

```bash
PKG_MANAGER=pnpm ADONIS_KIT=api ADONIS_AUTH=access_tokens make up
```

## Using the Makefile

```bash
make help          # Show all available targets
make up            # Start containers (defaults)
make down          # Stop containers
make logs          # Follow container logs
make shell         # Open a shell in the app container
make ace CMD="make:controller User"  # Run ace commands
make test          # Run tests
make db-migrate    # Run migrations
make db-seed       # Run seeders
make db-shell      # Open database CLI
```

## Using an Existing Project

Clone your AdonisJS project into this directory (or copy the Docker files into your project). As long as `package.json` exists, the entrypoint will skip project creation and just install dependencies.

```bash
git clone https://github.com/your/adonis-project .
docker compose up --wait
```

## Production

```bash
docker compose -f compose.yaml -f compose.prod.yaml up -d --wait
```

Or with the Makefile:

```bash
make prod-up
```

See [docs/production.md](docs/production.md) for detailed production deployment guidance.

## Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `PKG_MANAGER` | `npm` | Package manager (npm, pnpm, yarn) |
| `ADONIS_KIT` | `web` | Starter kit (web, api, slim, inertia) |
| `ADONIS_DB` | `postgres` | Database driver |
| `ADONIS_AUTH` | `session` | Auth guard |
| `NODE_ENV` | `development` | Node environment |
| `PORT` | `3333` | Application port |
| `APP_KEY` | _(auto)_ | Application encryption key |
| `DB_HOST` | `database` | Database hostname |
| `DB_PORT` | _(auto)_ | Database port (auto-detected from `ADONIS_DB`) |
| `DB_USER` | `adonis` | Database user |
| `DB_PASSWORD` | `!ChangeMe!` | Database password |
| `DB_DATABASE` | `adonis` | Database name |
| `COMPOSE_PROFILES` | `postgres` | Active database service profile |
| `IMAGES_PREFIX` | _(empty)_ | Docker image name prefix |
| `APP_REPLICAS` | `1` | Production replica count |

## License

MIT
