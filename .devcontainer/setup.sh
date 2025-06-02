#!/bin/bash
set -e

echo "🚀 Setting up Apache Superset development environment..."

# Ensure we're in the right directory
cd /app

# Install superset in editable mode now that source is mounted
echo "📦 Installing Superset in development mode..."

# Find the virtual environment (could be in different locations due to mounting)
if [ -f "/app/.venv/bin/activate" ]; then
    VENV_PATH="/app/.venv"
elif [ -f "/usr/local/lib/python*/dist-packages/virtualenv" ]; then
    # Create new venv since the old one might be overwritten
    python3 -m venv /app/.venv
    VENV_PATH="/app/.venv"
else
    # Create new venv
    python3 -m venv /app/.venv
    VENV_PATH="/app/.venv"
fi

. $VENV_PATH/bin/activate

# Install dependencies if not already installed
if ! python -c "import uv" 2>/dev/null; then
    pip install --upgrade uv
fi

# Install development requirements if needed
if ! python -c "import superset" 2>/dev/null; then
    uv pip install -r requirements/development.txt
fi

uv pip install -e .
uv pip install -e .[postgres]
echo "✅ Superset installed in development mode!"

# Wait for services to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
# Install postgresql-client if not available
if ! command -v pg_isready >/dev/null 2>&1; then
    echo "Installing PostgreSQL client tools..."
    apt-get update && apt-get install -y postgresql-client >/dev/null 2>&1
fi

# Wait for PostgreSQL with timeout
DB_READY=false
TIMEOUT=180  # 3 minutes timeout
START_TIME=$(date +%s)

while [ "$DB_READY" = false ]; do
    if pg_isready -h db -p 5432 -U superset -q 2>/dev/null; then
        DB_READY=true
        echo "✅ PostgreSQL is ready!"
    else
        CURRENT_TIME=$(date +%s)
        if [ $((CURRENT_TIME - START_TIME)) -gt $TIMEOUT ]; then
            echo "⚠️ Timed out waiting for PostgreSQL. Continuing anyway..."
            break
        fi
        echo "⏳ Waiting for PostgreSQL... ($(($TIMEOUT - CURRENT_TIME + START_TIME))s remaining)"
        sleep 5
    fi
done

echo "⏳ Waiting for Redis to be ready..."
# Install redis-tools if not available
if ! command -v redis-cli >/dev/null 2>&1; then
    echo "Installing Redis client tools..."
    apt-get update && apt-get install -y redis-tools >/dev/null 2>&1
fi

# Wait for Redis with timeout
REDIS_READY=false
START_TIME=$(date +%s)

while [ "$REDIS_READY" = false ]; do
    if redis-cli -h redis -p 6379 ping > /dev/null 2>&1; then
        REDIS_READY=true
        echo "✅ Redis is ready!"
    else
        CURRENT_TIME=$(date +%s)
        if [ $((CURRENT_TIME - START_TIME)) -gt $TIMEOUT ]; then
            echo "⚠️ Timed out waiting for Redis. Continuing anyway..."
            break
        fi
        echo "⏳ Waiting for Redis... ($(($TIMEOUT - CURRENT_TIME + START_TIME))s remaining)"
        sleep 5
    fi
done

# Install psql if not available
if ! command -v psql >/dev/null 2>&1; then
    echo "Installing PostgreSQL client tools..."
    apt-get update && apt-get install -y postgresql-client >/dev/null 2>&1
fi

# Check if database is already initialized
if ! PGPASSWORD=superset psql -h db -U superset -d superset -c "SELECT 1 FROM ab_user LIMIT 1;" > /dev/null 2>&1; then
    echo "🔧 Initializing Superset database..."

    # Run database migrations
    echo "📊 Running database migrations..."
    superset db upgrade

    # Create admin user
    echo "👤 Creating admin user..."
    superset fab create-admin \
        --username admin \
        --email admin@superset.com \
        --password admin \
        --firstname Superset \
        --lastname Admin

    # Initialize roles and permissions
    echo "🔐 Setting up roles and permissions..."
    superset init

    # Load example data if requested
    if [ "${SUPERSET_LOAD_EXAMPLES:-yes}" = "yes" ]; then
        echo "📈 Loading example data..."
        superset load_examples
    fi

    echo "✅ Database initialization complete!"
else
    echo "✅ Database already initialized, skipping setup"
fi

# Install frontend dependencies if not already installed
if [ ! -d "/app/superset-frontend/node_modules/.bin" ]; then
    echo "📦 Installing frontend dependencies..."

    # Ensure node_modules directory has correct ownership
    if [ ! -w "/app/superset-frontend/node_modules" ]; then
        echo "Fixing node_modules directory permissions..."
        sudo mkdir -p /app/superset-frontend/node_modules
        sudo chown -R $(id -u):$(id -g) /app/superset-frontend/node_modules
    fi

    cd /app/superset-frontend
    npm ci
    cd /app
    echo "✅ Frontend dependencies installed!"
else
    echo "✅ Frontend dependencies already installed"
fi

# Set up git hooks if not already installed
if [ ! -f "/app/.git/hooks/pre-commit" ]; then
    echo "🔨 Installing pre-commit hooks..."
    pre-commit install
    echo "✅ Pre-commit hooks installed!"
fi

echo "🎉 Setup complete! Your development environment is ready."
echo ""
echo "🔧 Available services:"
echo "  - Superset Backend: http://localhost:8088 (admin/admin)"
echo "  - Frontend Dev Server: http://localhost:9000"
echo "  - WebSocket Server: http://localhost:8080"
echo "  - PostgreSQL: localhost:5432 (superset/superset)"
echo "  - Redis: localhost:6379"
echo ""
echo "💡 To start the services, run: bash .devcontainer/start-services.sh"
