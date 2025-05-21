#!/bin/bash
set -e

echo "🚀 Starting Apache Superset services..."

# Function to check if a process is running
is_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

# Function to start a service in the background
start_service() {
    local name="$1"
    local command="$2"
    local logfile="/app/superset_home/logs/${name}.log"
    
    # Create logs directory if it doesn't exist
    mkdir -p /app/superset_home/logs
    
    if is_running "$command"; then
        echo "✅ $name is already running"
    else
        echo "▶️  Starting $name..."
        nohup bash -c "$command" > "$logfile" 2>&1 &
        echo "📝 Logs available at: $logfile"
    fi
}

# Wait for dependencies
echo "⏳ Checking service dependencies..."

# Install PostgreSQL client if needed
if ! command -v pg_isready >/dev/null 2>&1; then
    echo "Installing PostgreSQL client tools..."
    apt-get update && apt-get install -y postgresql-client >/dev/null 2>&1
fi

# Install Redis client if needed
if ! command -v redis-cli >/dev/null 2>&1; then
    echo "Installing Redis client tools..."
    apt-get update && apt-get install -y redis-tools >/dev/null 2>&1
fi

# Wait for PostgreSQL with timeout
DB_READY=false
TIMEOUT=120  # 2 minutes timeout
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
        echo "⏳ Waiting for PostgreSQL..."
        sleep 5
    fi
done

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
        echo "⏳ Waiting for Redis..."
        sleep 5
    fi
done
echo "✅ Dependencies are ready!"

# Ensure we're in the app directory
cd /app

# Activate virtual environment
if [ -f "/app/.venv/bin/activate" ]; then
    . /app/.venv/bin/activate
else
    echo "⚠️  Virtual environment not found, creating one..."
    python3 -m venv /app/.venv
    . /app/.venv/bin/activate
    pip install --upgrade uv
    uv pip install -r requirements/development.txt
    uv pip install -e .
    uv pip install -e .[postgres]
fi

# Start Celery worker
start_service "Celery Worker" "celery --app=superset.tasks.celery_app:app worker -O fair -l INFO --concurrency=2"

# Start Celery beat scheduler  
start_service "Celery Beat" "rm -f /tmp/celerybeat.pid && celery --app=superset.tasks.celery_app:app beat --pidfile /tmp/celerybeat.pid -l INFO -s /app/superset_home/celerybeat-schedule"

# Start the websocket server
start_service "WebSocket Server" "cd /app/superset-websocket && npm install && npm run dev"

# Start Superset backend
start_service "Superset Backend" "flask run -p 8088 --with-threads --reload --debugger --host=0.0.0.0"

# Give backend a moment to start
sleep 5

# Start frontend development server
echo "▶️  Starting Frontend Development Server..."
cd /app/superset-frontend

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    npm ci
fi

# Start the dev server
if is_running "npm run dev-server"; then
    echo "✅ Frontend dev server is already running"
else
    echo "🎯 Starting webpack dev server on port 9000..."
    # Start dev server in background
    nohup npm run dev-server > /app/superset_home/logs/frontend.log 2>&1 &
    echo "📝 Frontend logs available at: /app/superset_home/logs/frontend.log"
fi

echo ""
echo "🎉 All services have been started!"
echo ""
echo "🔧 Service Status:"
echo "  - Backend:    http://localhost:8088 (Flask dev server with hot reload)"
echo "  - Frontend:   http://localhost:9000 (Webpack dev server with hot reload)"  
echo "  - WebSocket:  http://localhost:8080"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis:      localhost:6379"
echo ""
echo "👤 Login credentials: admin/admin"
echo ""
echo "📝 Service logs are available in /app/superset_home/logs/"
echo "🔄 Code changes will automatically trigger reloads"
echo ""
echo "🛠️  To stop all services: bash .devcontainer/stop-services.sh"