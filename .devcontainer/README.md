# Apache Superset DevContainer

This devcontainer provides a complete development environment for Apache Superset that includes:

## Features

- **Full Superset development setup** with Python 3.11 and Node.js 20
- **PostgreSQL database** for metadata and examples
- **Redis** for caching and Celery task queue
- **Automatic dependency installation** via uv (fast Python package installer)
- **Hot reload** for both frontend and backend development
- **Pre-configured services** that start automatically
- **Claude Code CLI** for AI-assisted development

## Services

The devcontainer automatically sets up these services:

- **Superset Backend** (port 8088) - Flask development server with hot reload
- **Frontend Dev Server** (port 9000) - Webpack dev server with hot module replacement
- **WebSocket Server** (port 8080) - For async features
- **PostgreSQL** (port 5432) - Database with example data loaded
- **Redis** (port 6379) - Cache and message broker

## Quick Start

1. **Open in VS Code**: Open this repository in VS Code with the Dev Containers extension
2. **Select "Reopen in Container"** when prompted
3. **Wait for setup** - The first time will take several minutes to:
   - Build the container
   - Install Python dependencies
   - Install Node.js dependencies
   - Set up the database with example data
   - Start all services
4. **Access Superset** at http://localhost:9000 (frontend) or http://localhost:8088 (backend)
5. **Login** with username `admin` and password `admin`

## Development Workflow

### Code Changes
- **Backend changes** (Python files) automatically reload the Flask server
- **Frontend changes** (TypeScript/JavaScript) trigger webpack hot module replacement
- **Database changes** can be applied with `superset db upgrade`

### Running Commands
Open a terminal in VS Code and run Superset CLI commands:
```bash
# Database migrations
superset db upgrade

# Load new examples
superset load_examples

# Create a new admin user
superset fab create-admin

# Run tests
pytest tests/unit_tests/
```

### Managing Services
```bash
# Check service status
bash .devcontainer/start-services.sh

# Stop all services
bash .devcontainer/stop-services.sh

# View service logs
less /app/superset_home/logs/*.log
```

## Ports

- `8088` - Superset Backend (Flask development server)
- `9000` - Frontend Development Server (Webpack with HMR)
- `8080` - WebSocket Server
- `5432` - PostgreSQL Database
- `6379` - Redis Cache

## Environment Variables

Key environment variables configured for development:

- `FLASK_DEBUG=1` - Enable Flask debug mode
- `DEV_MODE=true` - Enable development features
- `SUPERSET_LOAD_EXAMPLES=yes` - Load example dashboards and datasets
- `DATABASE_*` - PostgreSQL connection settings
- `REDIS_*` - Redis connection settings

## Troubleshooting

### Services not starting
```bash
# Restart all services
bash .devcontainer/start-services.sh
```

### Database issues
```bash
# Reset the database (removes all data!)
docker volume rm devcontainer_db_home
# Then reopen the container
```

### Frontend build issues
```bash
cd /app/superset-frontend
npm ci
npm run dev-server
```

### Python dependency issues
```bash
# Reinstall dependencies
. /app/.venv/bin/activate
uv pip install -r requirements/development.txt
uv pip install -e .[postgres]
```

## Architecture

The devcontainer uses:
- **Multi-service setup** via Docker Compose
- **Volume mounts** for live code editing
- **Automatic dependency caching** for faster rebuilds
- **Service orchestration** with proper startup dependencies
- **Development-optimized** configurations

This setup mirrors the recommended `docker compose` development workflow from the main documentation but optimized for VS Code devcontainers.
