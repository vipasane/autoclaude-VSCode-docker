# Auto-Claude Dev Container
# Optimized for VS Code Remote Development on Windows + Docker Desktop

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for Electron and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    curl \
    wget \
    # Python dependencies
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    # Electron/GUI dependencies (for headless testing)
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libasound2t64 \
    libxtst6 \
    libgbm1 \
    libdrm2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libpango-1.0-0 \
    libcairo2 \
    # Git and utilities
    git \
    jq \
    ripgrep \
    fd-find \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Install pnpm (Auto-Claude uses it)
RUN npm install -g pnpm

# Install Python tools
RUN pip3 install --break-system-packages \
    uv \
    ruff \
    black \
    pytest \
    pytest-asyncio

# Create workspace directory
RUN mkdir -p /workspace && chown vscode:vscode /workspace

# Set up Python virtual environment location
ENV VIRTUAL_ENV=/workspace/apps/backend/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Switch to non-root user
USER vscode

# Set working directory
WORKDIR /workspace

# Default command
CMD ["sleep", "infinity"]
