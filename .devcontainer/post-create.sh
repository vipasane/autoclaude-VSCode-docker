#!/bin/bash
# Post-create script - runs once after the container is created

set -e

echo "🚀 Setting up Auto-Claude development environment..."

# Navigate to workspace
cd /workspace

# ============================================
# Node.js Dependencies
# ============================================
echo "📦 Installing Node.js dependencies..."

# Install root dependencies
if [ -f "package.json" ]; then
    npm install
fi

# Install frontend dependencies
if [ -f "apps/frontend/package.json" ]; then
    echo "  → Installing frontend dependencies..."
    cd apps/frontend
    npm install
    cd /workspace
fi

# ============================================
# Python Environment
# ============================================
echo "🐍 Setting up Python environment..."

cd /workspace/apps/backend

# Create virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    python3.12 -m venv .venv
fi

# Activate and install dependencies
source .venv/bin/activate

# Install Python dependencies
if [ -f "requirements.txt" ]; then
    pip install --upgrade pip
    pip install -r requirements.txt
fi

# Install dev dependencies if they exist
if [ -f "requirements-dev.txt" ]; then
    pip install -r requirements-dev.txt
fi

cd /workspace

# ============================================
# Claude Code Setup
# ============================================
echo "🤖 Configuring Claude Code CLI..."

# Create Claude config directory
mkdir -p ~/.claude

# Check if OAuth token is set
if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    echo "  ✓ OAuth token detected"
else
    echo "  ⚠ No OAuth token found. Run 'claude login' after container starts."
fi

# ============================================
# Git Configuration (inside container)
# ============================================
echo "🔧 Configuring Git..."

# Safe directory for mounted workspace
git config --global --add safe.directory /workspace

# ============================================
# Create .env file if it doesn't exist
# ============================================
if [ ! -f "apps/backend/.env" ]; then
    echo "📝 Creating .env file from example..."
    if [ -f "apps/backend/.env.example" ]; then
        cp apps/backend/.env.example apps/backend/.env
        echo "  → Created apps/backend/.env - please configure it"
    fi
fi

# ============================================
# Pre-build Electron dependencies (optional)
# ============================================
echo "⚡ Preparing Electron environment..."
cd /workspace/apps/frontend
npx electron-rebuild 2>/dev/null || echo "  → Electron rebuild skipped (headless mode)"
cd /workspace

echo ""
echo "✅ Auto-Claude development environment is ready!"
echo ""
echo "Quick start commands:"
echo "  npm run dev          - Start development servers"
echo "  npm start            - Build and run the app"
echo "  claude --help        - Claude Code CLI help"
echo ""
