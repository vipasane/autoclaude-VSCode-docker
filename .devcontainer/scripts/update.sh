#!/bin/bash
#===============================================================================
# Auto-Claude Update Script
# Pulls latest changes and reinstalls dependencies
#===============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

AUTO_CLAUDE_DIR="/workspace/auto-claude"

echo -e "${BLUE}🔄 Updating Auto-Claude...${NC}"
echo ""

cd "$AUTO_CLAUDE_DIR"

# Store current branch
CURRENT_BRANCH=$(git branch --show-current)

# Fetch and pull
echo -e "${BLUE}📥 Fetching latest changes...${NC}"
git fetch origin

echo -e "${BLUE}📥 Pulling $CURRENT_BRANCH...${NC}"
git pull origin "$CURRENT_BRANCH"

# Reinstall Node dependencies
echo -e "${BLUE}📦 Updating Node dependencies...${NC}"
npm install

if [ -d "apps/frontend" ]; then
    cd apps/frontend
    npm install
    cd "$AUTO_CLAUDE_DIR"
fi

# Update Python dependencies
if [ -f "apps/backend/.venv/bin/activate" ]; then
    echo -e "${BLUE}🐍 Updating Python dependencies...${NC}"
    source apps/backend/.venv/bin/activate
    if [ -f "apps/backend/requirements.txt" ]; then
        pip install -r apps/backend/requirements.txt
    fi
fi

echo ""
echo -e "${GREEN}✓ Update complete!${NC}"
echo -e "  Current commit: $(git log -1 --oneline)"
