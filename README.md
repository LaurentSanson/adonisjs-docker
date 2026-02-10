# AdonisJS Docker

A Docker-based development and production environment for [AdonisJS](https://adonisjs.com/) v6.

## Getting Started

1. If not already done, [install Docker Compose](https://docs.docker.com/compose/install/) (v2.10+)
2. Run `docker compose build --pull --no-cache` to build fresh images
3. Run `docker compose up --wait` to set up and start a fresh AdonisJS project
4. Open `https://localhost:3333` in your favorite web browser
5. Run `docker compose down --remove-orphans` to stop the Docker containers.

**That's it.** The first run will automatically scaffold a new AdonisJS project using the default options (web kit, PostgreSQL, session auth, npm).

## Using an Existing Project

Clone your AdonisJS project into this directory (or copy the Docker files into your project). As long as `package.json` exists, the entrypoint will skip project creation and just install dependencies.

```bash
git clone https://github.com/your/adonis-project .
docker compose up --wait
```

## Documentation

- [Configuration Options](docs/options.md) — starter kits, database, auth, package manager, inertia
- [Makefile](docs/makefile.md) — shortcut commands for common tasks
- [Production](docs/production.md) — building and deploying for production
- [Troubleshooting](docs/troubleshooting.md) — common issues and solutions

## License

MIT
