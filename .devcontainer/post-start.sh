#!/bin/bash
# Post-start script - runs every time the container starts

echo "🔄 Starting Auto-Claude environment..."

# ============================================
# Verify Services
# ============================================
echo "🔍 Checking services..."

# Check FalkorDB connection
if command -v redis-cli &> /dev/null; then
    if redis-cli -h falkordb ping > /dev/null 2>&1; then
        echo "  ✓ FalkorDB is running"
    else
        echo "  ⚠ FalkorDB not responding - Memory Layer may not work"
    fi
else
    echo "  ℹ redis-cli not installed, skipping FalkorDB check"
fi

# ============================================
# Activate Python Environment
# ============================================
VENV_PATHS=(
    "/workspace/apps/backend/.venv"
    "/workspace/.venv"
)

VENV_ACTIVATED=false
for venv_path in "${VENV_PATHS[@]}"; do
    if [ -f "$venv_path/bin/activate" ]; then
        source "$venv_path/bin/activate"
        echo "  ✓ Python virtual environment activated: $venv_path"
        VENV_ACTIVATED=true
        break
    fi
done

if [ "$VENV_ACTIVATED" = false ]; then
    echo "  ℹ No Python venv found (will use system Python)"
fi

# ============================================
# Claude Code Status
# ============================================
echo "🤖 Claude Code status:"
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo 'version unknown')
    echo "  ✓ Claude Code CLI installed: $CLAUDE_VERSION"
    
    # Check authentication
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "  ✓ OAuth token configured (from environment)"
    elif [ -f ~/.claude/credentials.json ]; then
        echo "  ✓ Credentials file found"
    else
        echo "  ⚠ Not authenticated - run: claude login"
    fi
else
    echo "  ⚠ Claude Code CLI not found - run: npm install -g @anthropic-ai/claude-code"
fi

# ============================================
# Display helpful info
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Auto-Claude Dev Container Ready"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Workspace:  /workspace"
echo "  Frontend:   http://localhost:3000"
echo "  Backend:    http://localhost:8000"
echo "  FalkorDB:   localhost:6379"
echo ""
echo "  Commands:"
echo "    npm run dev        Start development mode"
echo "    npm start          Build and run app"
echo "    claude             Start Claude Code"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
