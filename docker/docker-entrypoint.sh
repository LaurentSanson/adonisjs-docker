#!/bin/sh
set -e

# ==============================================================================
# Helper: run the right install command for the chosen package manager
# ==============================================================================
pkg_install() {
    case "${PKG_MANAGER:-npm}" in
        pnpm) pnpm install ;;
        yarn) yarn install ;;
        *)    npm install ;;
    esac
}

# ==============================================================================
# Helper: create a new AdonisJS project with the configured options
# ==============================================================================
pkg_create_adonis() {
    local kit="${ADONIS_KIT:-web}"
    local db="${ADONIS_DB:-postgres}"
    local auth="${ADONIS_AUTH:-session}"

    # Build common flags
    local flags="--kit=${kit}"

    # Database and auth flags apply to web, api, and inertia kits (not slim)
    if [ "$kit" != "slim" ]; then
        flags="${flags} --db=${db} --auth-guard=${auth}"
    fi

    # Inertia-specific flags
    if [ "$kit" = "inertia" ]; then
        flags="${flags} --adapter=${ADONIS_INERTIA_ADAPTER:-react}"
        if [ "${ADONIS_INERTIA_SSR:-false}" = "true" ]; then
            flags="${flags} --ssr"
        else
            flags="${flags} --no-ssr"
        fi
    fi

    echo "Creating AdonisJS project with: ${flags}"

    case "${PKG_MANAGER:-npm}" in
        pnpm)
            # shellcheck disable=SC2086
            pnpm create adonisjs@latest tmp ${flags}
            ;;
        yarn)
            # shellcheck disable=SC2086
            yarn create adonisjs@latest tmp ${flags}
            ;;
        *)
            # Use npx --yes to auto-confirm package installation in non-interactive environments
            # shellcheck disable=SC2086
            npx --yes create-adonisjs@latest tmp ${flags}
            ;;
    esac
}

# ==============================================================================
# Phase 1: Create AdonisJS project if not exists
# ==============================================================================
if [ ! -f "package.json" ]; then
    echo '---------------------------------------------'
    echo 'No package.json found. Creating new AdonisJS application...'
    echo "  Kit:          ${ADONIS_KIT:-web}"
    echo "  Database:     ${ADONIS_DB:-postgres}"
    echo "  Auth Guard:   ${ADONIS_AUTH:-session}"
    echo "  Pkg Manager:  ${PKG_MANAGER:-npm}"
    if [ "${ADONIS_KIT:-web}" = "inertia" ]; then
        echo "  Inertia:      ${ADONIS_INERTIA_ADAPTER:-react} (SSR: ${ADONIS_INERTIA_SSR:-false})"
    fi
    echo '---------------------------------------------'

    rm -Rf tmp/
    pkg_create_adonis

    cp -Rp tmp/. .
    rm -Rf tmp/

    echo 'AdonisJS application created successfully!'
fi

# ==============================================================================
# Phase 2: Install dependencies if needed
# ==============================================================================
if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules 2>/dev/null)" ]; then
    echo 'node_modules is empty. Installing dependencies...'
    pkg_install
fi

# ==============================================================================
# Phase 3: Auto-detect database defaults
# ==============================================================================
# Set DB_PORT based on database type if not explicitly set
if [ -z "$DB_PORT" ]; then
    case "${ADONIS_DB:-postgres}" in
        postgres) export DB_PORT=5432 ;;
        mysql)    export DB_PORT=3306 ;;
        mssql)    export DB_PORT=1433 ;;
    esac
fi

# MSSQL uses 'sa' as default user
if [ "${ADONIS_DB:-postgres}" = "mssql" ] && [ "${DB_USER:-adonis}" = "adonis" ]; then
    export DB_USER=sa
fi

# ==============================================================================
# Phase 4: Wait for database (skip for sqlite)
# ==============================================================================
if [ "${ADONIS_DB:-postgres}" != "sqlite" ]; then
    DB_HOST="${DB_HOST:-database}"

    echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."

    ATTEMPTS_LEFT_TO_REACH_DATABASE=60
    until [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ] || nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do
        sleep 1
        ATTEMPTS_LEFT_TO_REACH_DATABASE=$((ATTEMPTS_LEFT_TO_REACH_DATABASE - 1))
        echo "Still waiting for database... ${ATTEMPTS_LEFT_TO_REACH_DATABASE} attempts left."
    done

    if [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ]; then
        echo 'The database is not up or not reachable.'
        exit 1
    else
        echo 'The database is now ready and reachable.'
    fi
fi

# ==============================================================================
# Phase 5: Run migrations if they exist
# ==============================================================================
if [ -d "database/migrations" ] && [ "$(ls -A database/migrations/ 2>/dev/null)" ]; then
    echo 'Running database migrations...'
    node ace migration:run --force 2>/dev/null || true
fi

echo 'Starting AdonisJS application...'

exec "$@"
