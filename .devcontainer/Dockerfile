# Superset DevContainer Dockerfile
FROM python:3.11.11

LABEL dev.containers.image.vendor="Apache Superset"
LABEL dev.containers.image.authors="Superset Development Team"
LABEL dev.containers.image.description="Development container for Apache Superset"

ARG DEV_MODE="true"
ARG INCLUDE_CHROMIUM="false"
ARG INCLUDE_FIREFOX="false"
ARG BUILD_TRANSLATIONS="false"

ENV SUPERSET_HOME="/app/superset_home" \
    HOME="/app/superset_home" \
    SUPERSET_ENV="development" \
    FLASK_APP="superset.app:create_app()" \
    FLASK_DEBUG=1 \
    PYTHONPATH="/app:/app/docker/pythonpath_dev" \
    SUPERSET_PORT="8088" \
    DEV_MODE="${DEV_MODE}"

# Install system dependencies
COPY docker/apt-install.sh /app/docker/
RUN apt-get update && apt-get install -y \
    curl \
    git \
    pkg-config \
    default-libmysqlclient-dev \
    libsasl2-dev \
    libsasl2-modules-gssapi-mit \
    libpq-dev \
    libecpg-dev \
    libldap2-dev \
    build-essential \
    postgresql-client \
    redis-tools \
    sudo \
    zstd \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=superset
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create superset user with specified UID/GID (matching typical host values)
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -d ${SUPERSET_HOME} -m --no-log-init --shell /bin/bash $USERNAME \
    && mkdir -p /app \
    && chmod -R 1777 ${SUPERSET_HOME} \
    && chown -R $USERNAME:$USERNAME ${SUPERSET_HOME} \
    && chown -R $USERNAME:$USERNAME /app \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install uv for faster Python package management
RUN pip install --no-cache-dir --upgrade uv

# Set up Python vvenvl environment
RUN uv venv /app/.venv
ENV PATH="/app/.venv/bin:${PATH}"

# Install Python dependencies
WORKDIR /app
COPY requirements/ requirements/
COPY pyproject.toml setup.py MANIFEST.in README.md ./
COPY superset-frontend/package.json superset-frontend/
COPY scripts/check-env.py scripts/

# Create required static directory and files early
RUN mkdir -p superset/static && \
    echo '{"version": "dev", "sha": "unknown", "branch": "dev"}' > superset/static/version_info.json

# Copy application code
COPY docker docker
COPY superset superset
COPY superset-frontend superset-frontend
COPY superset-websocket superset-websocket

# Ensure node_modules directory has the right permissions
RUN mkdir -p /app/superset-frontend/node_modules && \
    chown -R superset:superset /app/superset-frontend/node_modules

# Install Python dependencies using uv
RUN . /app/.venv/bin/activate && \
    uv pip install -r requirements/development.txt

# Note: tests directory will be mounted from the host in docker-compose.yml

# Make scripts executable
RUN chmod +x docker/*.sh && \
    chown -R superset:superset /app

USER superset
WORKDIR /app

# Expose ports
EXPOSE 8088 9000 8080

CMD ["sleep", "infinity"]
