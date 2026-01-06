# Auto-Claude Dev Container
# Fully self-contained development environment
# Just open in VS Code and everything sets up automatically

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build essentials
    build-essential \
    curl \
    wget \
    ca-certificates \
    gnupg \
    # Python
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    # Redis CLI for FalkorDB
    redis-tools \
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
    unzip \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x (required by Auto-Claude >= 2.7)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install global npm packages
RUN npm install -g \
    @anthropic-ai/claude-code \
    pnpm

# Install Python tools globally
RUN pip3 install --break-system-packages \
    uv \
    ruff \
    black \
    pytest \
    pytest-asyncio

# Create workspace directory
RUN mkdir -p /workspace && chown vscode:vscode /workspace

# PRE-CREATE Claude directories with correct ownership
# This ensures they exist before volume mounts, preventing permission issues
RUN mkdir -p /home/vscode/.claude \
    && mkdir -p /home/vscode/.claude/todos \
    && mkdir -p /home/vscode/.claude/debug \
    && mkdir -p /home/vscode/.claude-code \
    && chown -R vscode:vscode /home/vscode/.claude \
    && chown -R vscode:vscode /home/vscode/.claude-code

# Switch to non-root user
USER vscode

# Set working directory
WORKDIR /workspace

# Default command
CMD ["sleep", "infinity"]
