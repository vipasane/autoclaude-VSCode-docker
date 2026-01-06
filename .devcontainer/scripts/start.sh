#!/bin/bash
#===============================================================================
# Auto-Claude Development Environment Startup
# This script runs every time the container starts
# It handles: permission fixes, service checks, venv activation, status display
#===============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
AUTO_CLAUDE_DIR="/workspace/auto-claude"

#-------------------------------------------------------------------------------
# Fix Permissions (runs every start to handle volume mount issues)
#-------------------------------------------------------------------------------
fix_permissions() {
    # Fix Claude config directory permissions silently
    CLAUDE_DIRS=(
        "/home/vscode/.claude"
        "/home/vscode/.claude-code"
    )
    
    for dir in "${CLAUDE_DIRS[@]}"; do
        if [ -d "$dir" ] && [ ! -w "$dir" ]; then
            sudo chown -R vscode:vscode "$dir" 2>/dev/null || true
        elif [ ! -d "$dir" ]; then
            mkdir -p "$dir" 2>/dev/null || {
                sudo mkdir -p "$dir" 2>/dev/null
                sudo chown -R vscode:vscode "$dir" 2>/dev/null
            }
        fi
    done
}

#-------------------------------------------------------------------------------
# Check Services
#-------------------------------------------------------------------------------
check_services() {
    echo -e "${BLUE}🔍 Checking services...${NC}"
    
    # Check FalkorDB
    if redis-cli -h falkordb ping > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} FalkorDB is running"
        FALKORDB_STATUS="${GREEN}● Running${NC}"
    else
        echo -e "  ${YELLOW}⚠${NC} FalkorDB not responding"
        FALKORDB_STATUS="${YELLOW}○ Not responding${NC}"
    fi
}

#-------------------------------------------------------------------------------
# Activate Python Environment
#-------------------------------------------------------------------------------
activate_python() {
    echo -e "${BLUE}🐍 Python environment...${NC}"
    
    VENV_PATHS=(
        "$AUTO_CLAUDE_DIR/apps/backend/.venv"
        "$AUTO_CLAUDE_DIR/.venv"
    )
    
    PYTHON_STATUS="${YELLOW}○ Not found${NC}"
    
    for venv_path in "${VENV_PATHS[@]}"; do
        if [ -f "$venv_path/bin/activate" ]; then
            source "$venv_path/bin/activate"
            echo -e "  ${GREEN}✓${NC} Activated: $venv_path"
            PYTHON_VERSION=$(python --version 2>&1)
            PYTHON_STATUS="${GREEN}● $PYTHON_VERSION${NC}"
            
            # Export for child processes
            export VIRTUAL_ENV="$venv_path"
            export PATH="$venv_path/bin:$PATH"
            break
        fi
    done
    
    if [ "$PYTHON_STATUS" = "${YELLOW}○ Not found${NC}" ]; then
        echo -e "  ${YELLOW}⚠${NC} No venv found, using system Python"
        PYTHON_VERSION=$(python3 --version 2>&1)
        PYTHON_STATUS="${YELLOW}○ System: $PYTHON_VERSION${NC}"
    fi
}

#-------------------------------------------------------------------------------
# Check Claude Code
#-------------------------------------------------------------------------------
check_claude() {
    echo -e "${BLUE}🤖 Claude Code...${NC}"
    
    if command -v claude &> /dev/null; then
        CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1 || echo "unknown")
        echo -e "  ${GREEN}✓${NC} Installed: $CLAUDE_VERSION"
        CLAUDE_STATUS="${GREEN}● $CLAUDE_VERSION${NC}"
        
        # Check authentication
        if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
            echo -e "  ${GREEN}✓${NC} OAuth token configured"
            AUTH_STATUS="${GREEN}● Authenticated${NC}"
        elif [ -f ~/.claude/credentials.json ]; then
            echo -e "  ${GREEN}✓${NC} Credentials file found"
            AUTH_STATUS="${GREEN}● Authenticated${NC}"
        else
            echo -e "  ${YELLOW}⚠${NC} Not authenticated - run: claude login"
            AUTH_STATUS="${YELLOW}○ Not authenticated${NC}"
        fi
    else
        echo -e "  ${RED}✗${NC} Not found"
        CLAUDE_STATUS="${RED}○ Not installed${NC}"
        AUTH_STATUS="${RED}○ N/A${NC}"
    fi
}

#-------------------------------------------------------------------------------
# Check Repository
#-------------------------------------------------------------------------------
check_repository() {
    echo -e "${BLUE}📁 Repository...${NC}"
    
    if [ -d "$AUTO_CLAUDE_DIR/.git" ]; then
        cd "$AUTO_CLAUDE_DIR"
        BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
        COMMIT=$(git log -1 --oneline 2>/dev/null || echo "unknown")
        echo -e "  ${GREEN}✓${NC} Branch: $BRANCH"
        echo -e "  ${GREEN}✓${NC} Commit: $COMMIT"
        REPO_STATUS="${GREEN}● Ready${NC}"
    else
        echo -e "  ${YELLOW}⚠${NC} Repository not found at $AUTO_CLAUDE_DIR"
        echo -e "  ${YELLOW}⚠${NC} Run: bash .devcontainer/scripts/setup.sh"
        REPO_STATUS="${YELLOW}○ Not cloned${NC}"
    fi
}

#-------------------------------------------------------------------------------
# Display Status Dashboard
#-------------------------------------------------------------------------------
display_dashboard() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Auto-Claude Development Environment                 ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}Service Status${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    Repository:    $REPO_STATUS                            "
    echo -e "${CYAN}║${NC}    FalkorDB:      $FALKORDB_STATUS                         "
    echo -e "${CYAN}║${NC}    Python:        $PYTHON_STATUS                   "
    echo -e "${CYAN}║${NC}    Claude Code:   $CLAUDE_STATUS              "
    echo -e "${CYAN}║${NC}    Auth:          $AUTH_STATUS                  "
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}URLs${NC}                                                        ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    Frontend:      ${GREEN}http://localhost:3000${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    Backend API:   ${GREEN}http://localhost:8000${NC}                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    FalkorDB:      ${GREEN}localhost:6379${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}Quick Commands${NC}                                              ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${YELLOW}cd /workspace/auto-claude${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${YELLOW}npm run dev${NC}        Start dev servers                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${YELLOW}npm start${NC}          Build and run                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}    ${YELLOW}claude${NC}             Claude Code CLI                       ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${GREEN}🔄 Starting Auto-Claude environment...${NC}"
    echo ""
    
    fix_permissions   # Fix permissions first (silent)
    check_services
    activate_python
    check_claude
    check_repository
    display_dashboard
    
    # Change to Auto-Claude directory if it exists
    if [ -d "$AUTO_CLAUDE_DIR" ]; then
        cd "$AUTO_CLAUDE_DIR"
    fi
}

# Run main
main "$@"
