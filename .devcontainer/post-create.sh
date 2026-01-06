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
    npm install || echo "  ⚠ Root npm install had issues, continuing..."
fi

# Install frontend dependencies if directory exists
if [ -d "apps/frontend" ] && [ -f "apps/frontend/package.json" ]; then
    echo "  → Installing frontend dependencies..."
    cd apps/frontend
    npm install || echo "  ⚠ Frontend npm install had issues, continuing..."
    cd /workspace
fi

# ============================================
# Python Environment
# ============================================
echo "🐍 Setting up Python environment..."

# Check if apps/backend exists
if [ -d "apps/backend" ]; then
    cd /workspace/apps/backend
    
    # Remove potentially broken venv from volume mount
    if [ -d ".venv" ] && [ ! -f ".venv/bin/activate" ]; then
        echo "  → Removing incomplete venv..."
        rm -rf .venv
    fi
    
    # Create virtual environment
    if [ ! -d ".venv" ]; then
        echo "  → Creating Python virtual environment..."
        python3 -m venv .venv || python3.12 -m venv .venv || {
            echo "  ⚠ Failed to create venv with python3/python3.12, trying python..."
            python -m venv .venv
        }
    fi
    
    # Verify venv was created
    if [ -f ".venv/bin/activate" ]; then
        echo "  ✓ Virtual environment created"
        
        # Activate and install dependencies
        source .venv/bin/activate
        
        # Upgrade pip
        pip install --upgrade pip
        
        # Install Python dependencies
        if [ -f "requirements.txt" ]; then
            echo "  → Installing Python dependencies..."
            pip install -r requirements.txt || echo "  ⚠ Some Python deps failed, continuing..."
        fi
        
        # Install dev dependencies if they exist
        if [ -f "requirements-dev.txt" ]; then
            pip install -r requirements-dev.txt || echo "  ⚠ Some dev deps failed, continuing..."
        fi
    else
        echo "  ⚠ Could not create Python virtual environment"
        echo "  → Attempting global pip install instead..."
        if [ -f "requirements.txt" ]; then
            pip install --break-system-packages -r requirements.txt || echo "  ⚠ Global pip install failed"
        fi
    fi
    
    cd /workspace
else
    echo "  ℹ apps/backend directory not found, skipping Python setup"
    echo "  → Creating a minimal Python environment in /workspace..."
    
    # Create venv in workspace root instead
    if [ ! -d "/workspace/.venv" ]; then
        python3 -m venv /workspace/.venv || python -m venv /workspace/.venv || echo "  ⚠ Could not create venv"
    fi
    
    if [ -f "/workspace/.venv/bin/activate" ]; then
        source /workspace/.venv/bin/activate
        pip install --upgrade pip
        echo "  ✓ Python environment ready at /workspace/.venv"
    fi
fi

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
if [ -d "apps/backend" ] && [ ! -f "apps/backend/.env" ]; then
    echo "📝 Creating .env file from example..."
    if [ -f "apps/backend/.env.example" ]; then
        cp apps/backend/.env.example apps/backend/.env
        echo "  → Created apps/backend/.env - please configure it"
    fi
fi

# ============================================
# Pre-build Electron dependencies (optional)
# ============================================
if [ -d "apps/frontend" ]; then
    echo "⚡ Preparing Electron environment..."
    cd /workspace/apps/frontend
    npx electron-rebuild 2>/dev/null || echo "  → Electron rebuild skipped (headless mode)"
    cd /workspace
fi

echo ""
echo "✅ Auto-Claude development environment setup complete!"
echo ""
echo "Quick start commands:"
echo "  npm run dev          - Start development servers"
echo "  npm start            - Build and run the app"
echo "  claude --help        - Claude Code CLI help"
echo ""
