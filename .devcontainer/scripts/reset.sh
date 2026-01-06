#!/bin/bash
#===============================================================================
# Auto-Claude Reset Script
# Cleans up and reinstalls everything from scratch
#===============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

AUTO_CLAUDE_DIR="/workspace/auto-claude"

echo -e "${YELLOW}⚠ This will reset your Auto-Claude installation${NC}"
echo ""
echo "What would you like to reset?"
echo "  1) Node modules only (keeps code and Python venv)"
echo "  2) Python venv only (keeps code and node modules)"
echo "  3) Full reset (re-clone repository)"
echo "  4) Cancel"
echo ""
read -p "Select option (1-4): " choice

case $choice in
    1)
        echo -e "${BLUE}🧹 Cleaning node_modules...${NC}"
        rm -rf "$AUTO_CLAUDE_DIR/node_modules"
        rm -rf "$AUTO_CLAUDE_DIR/apps/frontend/node_modules"
        rm -rf "$AUTO_CLAUDE_DIR/apps/backend/node_modules"
        
        echo -e "${BLUE}📦 Reinstalling...${NC}"
        cd "$AUTO_CLAUDE_DIR"
        npm install
        [ -d "apps/frontend" ] && cd apps/frontend && npm install
        
        echo -e "${GREEN}✓ Node modules reset complete${NC}"
        ;;
    
    2)
        echo -e "${BLUE}🧹 Cleaning Python venv...${NC}"
        rm -rf "$AUTO_CLAUDE_DIR/apps/backend/.venv"
        rm -rf "$AUTO_CLAUDE_DIR/.venv"
        
        echo -e "${BLUE}🐍 Recreating venv...${NC}"
        cd "$AUTO_CLAUDE_DIR/apps/backend" 2>/dev/null || cd "$AUTO_CLAUDE_DIR"
        python3.12 -m venv .venv
        source .venv/bin/activate
        pip install --upgrade pip
        [ -f "requirements.txt" ] && pip install -r requirements.txt
        
        echo -e "${GREEN}✓ Python venv reset complete${NC}"
        ;;
    
    3)
        echo -e "${RED}⚠ This will delete all local changes!${NC}"
        read -p "Are you sure? (yes/no): " confirm
        
        if [ "$confirm" = "yes" ]; then
            echo -e "${BLUE}🧹 Removing Auto-Claude directory...${NC}"
            rm -rf "$AUTO_CLAUDE_DIR"
            
            echo -e "${BLUE}📥 Re-running setup...${NC}"
            bash /workspace/.devcontainer/scripts/setup.sh
        else
            echo "Cancelled"
        fi
        ;;
    
    4)
        echo "Cancelled"
        exit 0
        ;;
    
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
