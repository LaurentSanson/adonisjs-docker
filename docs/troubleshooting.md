# Troubleshooting

## Common Issues

### Container fails to start / health check timeout

The first run takes longer because it scaffolds the AdonisJS project and installs dependencies. The health check has a 180s start period to account for this.

Check the logs:

```bash
docker compose logs -f app
```

### Database connection refused

Ensure the database service is running and healthy:

```bash
docker compose ps
```

Verify that `COMPOSE_PROFILES` matches `ADONIS_DB`:

```bash
# Wrong: database service won't start
ADONIS_DB=mysql docker compose up

# Correct: profile activates the mysql service
ADONIS_DB=mysql COMPOSE_PROFILES=mysql docker compose up
```

### Permission issues with mounted volumes

If you see permission errors, ensure the project files are owned by your user:

```bash
sudo chown -R $(id -u):$(id -g) .
```

### Port already in use

Change the exposed port:

```bash
PORT=4000 docker compose up --wait
```

Note: The application inside the container always listens on port 3333. Only the host-side mapping changes.

### Starting fresh

Remove all containers, volumes, and images:

```bash
make clean
```

Or manually:

```bash
docker compose down -v --rmi all
rm -rf node_modules package.json
```

### MSSQL password requirements

MSSQL requires a strong password (8+ chars, uppercase, lowercase, digit, special char). The default `Adonis123!` meets this requirement, but if you change `DB_PASSWORD` for MSSQL, ensure it meets these criteria.
