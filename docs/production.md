# Production Deployment

## Building for Production

The production image uses a multi-stage build to create a minimal, optimized image:

```bash
docker compose -f compose.yaml -f compose.prod.yaml build
```

Or:

```bash
make prod-build
```

The production Dockerfile stages:

1. **base** - Node.js Alpine with system dependencies
2. **deps** - Install all dependencies
3. **build** - Build with `node ace build`, then install production-only dependencies
4. **prod** - Minimal image with only the build output

## Starting in Production

```bash
docker compose -f compose.yaml -f compose.prod.yaml up -d --wait
```

Or:

```bash
make prod-up
```

## Environment Variables

Set these for production:

```bash
NODE_ENV=production
APP_KEY=your-secret-key        # Generate with: node ace generate:key
DB_PASSWORD=strong-password
```

## Scaling

```bash
APP_REPLICAS=3 docker compose -f compose.yaml -f compose.prod.yaml up -d --wait
```

## Resource Limits

Default production resource limits (configurable in `compose.prod.yaml`):

| Service | CPU Limit | Memory Limit |
|---------|-----------|-------------|
| app | 1 | 512M |
| postgres/mysql | 1 | 1G |
| mssql | 2 | 2G |
