# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

Apache Superset is a modern, enterprise-ready business intelligence web application with a hybrid architecture:

### Core Components
- **Backend (Python/Flask)**: `/superset/` - Core application logic, RESTful APIs, database engines, models, and business logic
- **Frontend (React/TypeScript)**: `/superset-frontend/` - Modern React SPA with extensive visualization capabilities  
- **WebSocket Server (Node.js)**: `/superset-websocket/` - Real-time communication support for live features
- **Database Layer**: SQLAlchemy-based with 40+ database engine integrations
- **Caching**: Redis for query results, metadata, and session management
- **Task Queue**: Celery for async operations (alerts, reports, thumbnails, cache warming)

### Key Directories
- `/superset/` - Python backend (models, views, APIs, CLI commands, database engine specs)
- `/superset-frontend/` - React frontend with plugin architecture for visualizations
- `/superset-websocket/` - Node.js WebSocket service
- `/tests/` - Comprehensive test suites (unit, integration, end-to-end)
- `/docs/` - Documentation built with Docusaurus
- `/docker/` - Development and production Docker configurations

## Development Environment

This project is designed to run in a **VS Code Dev Container** which provides a complete, pre-configured development environment with all services automatically started.

### Quick Start
1. **Open in Dev Container**: VS Code will automatically detect the devcontainer configuration and prompt to reopen in container
2. **Automatic Service Startup**: All services start automatically via the `postStartCommand` in devcontainer.json:
   - Backend (Flask): http://localhost:8088
   - Frontend (Webpack dev server): http://localhost:9000  
   - WebSocket server: http://localhost:8080
   - PostgreSQL: localhost:5432
   - Redis: localhost:6379
3. **Login**: Use admin/admin credentials

### Service Management
```bash
# Restart all services (if needed)
bash .devcontainer/restart-services.sh

# Check service logs
tail -f /app/superset_home/logs/frontend.log     # Frontend logs
tail -f /app/superset_home/logs/backend.log      # Backend logs
tail -f /app/superset_home/logs/celery.log       # Celery logs

# Manual service control (rarely needed)
make flask-app                                    # Just backend
make node-app                                     # Just frontend
```

### Backend Development
```bash
# Environment is automatically configured in devcontainer
# Python virtual environment at /app/.venv is already activated
# Database and example data are loaded automatically

# Database operations (if needed)
superset db upgrade              # Apply new migrations
superset fab create-admin        # Create additional admin users
superset init                    # Reinitialize roles/permissions
superset load-examples           # Reload sample data
```

### Frontend Development
```bash
cd superset-frontend

# Development server runs automatically in devcontainer
# Dependencies are automatically installed via named volume
# Hot reload is enabled by default

# Building (when needed)
npm run build                   # Production build
npm run build-dev               # Development build with source maps

# Quality checks
npm run lint                    # ESLint + TypeScript checking
npm run type                    # TypeScript type checking only
npm run format                  # Prettier formatting
```

### Testing
```bash
# Python tests
pytest tests/unit_tests/                           # Unit tests only
scripts/tests/run.sh                               # All integration tests
pytest tests/integration_tests/specific_test.py   # Run specific test

# Frontend tests
cd superset-frontend
npm run test                                       # Jest tests
npm run test -- path/to/file.test.js             # Specific test file
npm run tdd                                       # Watch mode

# End-to-end tests
npm run build-instrumented                        # Build for Cypress
make build-cypress && make open-cypress           # Interactive E2E testing
```

### Code Quality & Linting
```bash
# Python formatting and linting
make format                     # Format both Python and JS
ruff check .                    # Python linting
ruff format .                   # Python formatting (alternative to black)
mypy superset/                  # Type checking

# Pre-commit hooks (runs automatically on commits)
pre-commit install              # Setup hooks
pre-commit run --all-files      # Manual run
```

### Background Tasks (Celery)
```bash
# Celery worker and beat scheduler start automatically in devcontainer
# Check logs if needed:
tail -f /app/superset_home/logs/celery-worker.log
tail -f /app/superset_home/logs/celery-beat.log

# Manual restart if needed:
bash .devcontainer/restart-services.sh
```

## Development Workflow

1. **Open Dev Container**: VS Code automatically starts all services (backend, frontend, celery, websocket)
2. **Code Changes**: Edit files locally - all services have hot reload enabled
3. **Access Application**: Frontend at http://localhost:9000, API at http://localhost:8088
4. **Testing**: Run appropriate test commands based on changes made
5. **Quality Checks**: Pre-commit hooks run automatically; manual commands available
6. **Database Changes**: Always create migrations for schema changes using `superset db migrate`

## Important Configuration Files

- **.devcontainer/**: VS Code dev container configuration with automatic service startup
- **Makefile**: Primary development commands and shortcuts
- **pyproject.toml**: Python package config, ruff/mypy settings, dependencies
- **superset-frontend/package.json**: Frontend build scripts and dependencies
- **docker-compose.yml**: Development environment orchestration (used by devcontainer)
- **requirements/development.txt**: Python development dependencies

## Architecture Patterns

### Frontend Plugin System
- Visualization plugins in `/superset-frontend/plugins/`
- Plugin registration system allows for custom chart types
- Each plugin exports chart metadata, controls, and rendering logic

### Database Engine Extensibility  
- Engine specs in `/superset/db_engine_specs/`
- Each database type has custom SQL dialect handling, connection logic, and feature support
- Add new databases by creating engine spec classes

### Security & Permissions
- Role-based access control (RBAC) via Flask-AppBuilder
- Fine-grained permissions for dashboards, charts, databases
- Row-level security support for data access control

### API Design
- RESTful APIs following OpenAPI specifications
- Consistent error handling and response formats
- API versioning and backward compatibility considerations

### Async Operations
- Celery tasks for long-running operations
- Query result caching with Redis
- Background reporting and alerting system

## Testing Strategy

- **Unit Tests**: Fast, isolated tests for business logic
- **Integration Tests**: Database interactions, API endpoints, full workflow testing  
- **End-to-End Tests**: Browser automation with Cypress for user workflows
- **Database Tests**: Multiple database engine compatibility testing

When making changes, always run appropriate tests and ensure pre-commit hooks pass before committing.
