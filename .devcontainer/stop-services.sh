#!/bin/bash

echo "🛑 Stopping Apache Superset services..."

# Function to stop processes by pattern
stop_process() {
    local pattern="$1"
    local name="$2"
    
    if pgrep -f "$pattern" > /dev/null 2>&1; then
        echo "⏹️  Stopping $name..."
        pkill -f "$pattern" || true
        
        # Wait for graceful shutdown
        sleep 2
        
        # Force kill if still running
        if pgrep -f "$pattern" > /dev/null 2>&1; then
            echo "🔨 Force stopping $name..."
            pkill -9 -f "$pattern" || true
        fi
        
        echo "✅ $name stopped"
    else
        echo "⚠️  $name is not running"
    fi
}

# Stop all Superset services
stop_process "npm run dev-server" "Frontend Dev Server"
stop_process "npm run storybook" "Storybook"
stop_process "flask run" "Superset Backend"
stop_process "superset.tasks.celery_app:app worker" "Celery Worker"
stop_process "superset.tasks.celery_app:app beat" "Celery Beat"

# Stop websocket server
stop_process "npm run dev" "WebSocket Server"

# Clean up any remaining Node processes
stop_process "node.*webpack" "Webpack processes"

# Remove celery pid file
rm -f /tmp/celerybeat.pid

echo ""
echo "✅ All services have been stopped!"
echo "🔄 To restart services: bash .devcontainer/start-services.sh"