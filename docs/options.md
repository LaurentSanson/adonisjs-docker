# Configuration Options

All AdonisJS project options are passed as environment variables. They are only used on the **first run** when the project is scaffolded.

## Starter Kits (`ADONIS_KIT`)

| Value | Description |
|-------|-------------|
| `web` | Full-featured web app with server-side rendering, database, auth |
| `api` | JSON API server with database, auth, CORS |
| `slim` | Bare minimum AdonisJS setup (no database, no auth) |
| `inertia` | SPA with server-side routing (React/Vue/Solid/Svelte) |

## Database (`ADONIS_DB`)

| Value | Docker Service | Default Port |
|-------|---------------|-------------|
| `postgres` | PostgreSQL 16 Alpine | 5432 |
| `mysql` | MySQL 8.0 | 3306 |
| `mssql` | SQL Server 2022 | 1433 |
| `sqlite` | _(none)_ | _(none)_ |

When changing the database, you must also set `COMPOSE_PROFILES` to match:

```bash
ADONIS_DB=mysql COMPOSE_PROFILES=mysql docker compose up --wait
```

For SQLite, no database service is needed:

```bash
ADONIS_DB=sqlite COMPOSE_PROFILES= docker compose up --wait
```

## Auth Guard (`ADONIS_AUTH`)

| Value | Description |
|-------|-------------|
| `session` | Cookie-based sessions (best for web apps) |
| `access_tokens` | Bearer token auth (best for APIs) |
| `basic_auth` | HTTP Basic authentication |

## Package Manager (`PKG_MANAGER`)

| Value | Lock File | Description |
|-------|-----------|-------------|
| `npm` | `package-lock.json` | Default Node.js package manager |
| `pnpm` | `pnpm-lock.yaml` | Fast, efficient disk usage |
| `yarn` | `yarn.lock` | Yarn classic |

## Inertia Options

Only used when `ADONIS_KIT=inertia`:

| Variable | Values | Default |
|----------|--------|---------|
| `ADONIS_INERTIA_ADAPTER` | `react`, `vue`, `solid`, `svelte` | `react` |
| `ADONIS_INERTIA_SSR` | `true`, `false` | `false` |

## Database Connection Variables

These are passed to the AdonisJS application at runtime:

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `database` | Hostname (Docker network alias) |
| `DB_PORT` | _(auto)_ | Port (auto-detected from `ADONIS_DB`) |
| `DB_USER` | `adonis` | Database user (`sa` for MSSQL) |
| `DB_PASSWORD` | `!ChangeMe!` | Database password |
| `DB_DATABASE` | `adonis` | Database name |
