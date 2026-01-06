#!/bin/bash
# Post-start script - runs every time the container starts

set -e

echo "🔄 Starting Auto-Claude environment..."

# ============================================
# Verify Services
# ============================================
echo "🔍 Checking services..."

# Check FalkorDB connection
if redis-cli -h falkordb ping > /dev/null 2>&1; then
    echo "  ✓ FalkorDB is running"
else
    echo "  ⚠ FalkorDB not responding - Memory Layer may not work"
fi

# ============================================
# Activate Python Environment
# ============================================
if [ -d "/workspace/apps/backend/.venv" ]; then
    source /workspace/apps/backend/.venv/bin/activate
    echo "  ✓ Python virtual environment activated"
fi

# ============================================
# Claude Code Status
# ============================================
echo "🤖 Claude Code status:"
if command -v claude &> /dev/null; then
    echo "  ✓ Claude Code CLI installed: $(claude --version 2>/dev/null || echo 'version unknown')"
    
    # Check authentication
    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo "  ✓ OAuth token configured"
    elif [ -f ~/.claude/credentials.json ]; then
        echo "  ✓ Credentials file found"
    else
        echo "  ⚠ Not authenticated - run: claude login"
    fi
else
    echo "  ✗ Claude Code CLI not found"
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
echo "    npm test           Run tests"
echo ""
echo "  Claude Code:"
echo "    claude             Start interactive session"
echo "    claude --help      Show CLI options"
echo ""
echo "  Backend CLI:"
echo "    cd apps/backend"
echo "    python run.py --spec 001"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
