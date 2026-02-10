# syntax=docker/dockerfile:1

# Build arguments
ARG NODE_VERSION=22
ARG PKG_MANAGER=npm

# ==============================================================================
# Base stage
# ==============================================================================
FROM node:${NODE_VERSION}-alpine AS base

# Enable corepack for pnpm/yarn support
RUN corepack enable

# Set working directory
WORKDIR /app

# Install system dependencies
# hadolint ignore=DL3018
RUN apk add --no-cache \
    dumb-init \
    curl \
    netcat-openbsd

# ==============================================================================
# Dependencies stage
# ==============================================================================
FROM base AS deps

ARG PKG_MANAGER

# Copy lock files (whichever exists for the chosen package manager)
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

# Install dependencies based on package manager
# hadolint ignore=DL3060
RUN --mount=type=cache,id=npm,target=/root/.npm \
    --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store \
    --mount=type=cache,id=yarn,target=/usr/local/share/.cache/yarn \
    if [ "$PKG_MANAGER" = "pnpm" ]; then \
      pnpm install --frozen-lockfile 2>/dev/null || pnpm install; \
    elif [ "$PKG_MANAGER" = "yarn" ]; then \
      yarn install --frozen-lockfile 2>/dev/null || yarn install; \
    else \
      npm ci 2>/dev/null || npm install; \
    fi

# ==============================================================================
# Development stage
# ==============================================================================
FROM base AS dev

ENV NODE_ENV=development

# Copy entrypoint script
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# Expose port (AdonisJS default)
EXPOSE 3333

# Health check (start-period allows time for project creation and dependency installation)
HEALTHCHECK --interval=10s --timeout=5s --start-period=180s --retries=3 \
    CMD curl -f http://localhost:${PORT:-3333}/health || curl -f http://localhost:${PORT:-3333}/ || exit 1

ENTRYPOINT ["docker-entrypoint"]
CMD ["node", "ace", "serve", "--hmr"]

# ==============================================================================
# Build stage
# ==============================================================================
FROM deps AS build

COPY . .

# Build AdonisJS for production
RUN node ace build

# Install production-only dependencies in the build output
ARG PKG_MANAGER
WORKDIR /app/build
# hadolint ignore=DL3060
RUN --mount=type=cache,id=npm,target=/root/.npm \
    --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store \
    --mount=type=cache,id=yarn,target=/usr/local/share/.cache/yarn \
    if [ "$PKG_MANAGER" = "pnpm" ]; then \
      pnpm install --prod; \
    elif [ "$PKG_MANAGER" = "yarn" ]; then \
      yarn install --production; \
    else \
      npm ci --omit=dev 2>/dev/null || npm install --omit=dev; \
    fi

# ==============================================================================
# Production stage
# ==============================================================================
FROM base AS prod

ENV NODE_ENV=production

# Copy built application
COPY --from=build /app/build /app

# Expose port
EXPOSE 3333

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${PORT:-3333}/health || curl -f http://localhost:${PORT:-3333}/ || exit 1

# Use dumb-init to handle PID 1
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "bin/server.js"]
