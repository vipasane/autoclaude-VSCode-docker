#!/bin/bash
#===============================================================================
# Auto-Claude DevContainer - macOS Prerequisites Check
# This script checks if all prerequisites are installed and provides
# installation commands for anything missing. It does NOT install anything.
#===============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Auto-Claude DevContainer - macOS Prerequisites        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

MISSING=()
COMMANDS=()

#-------------------------------------------------------------------------------
# Check macOS
#-------------------------------------------------------------------------------
echo -e "${BLUE}🍎 Checking macOS...${NC}"
if [[ "$OSTYPE" == "darwin"* ]]; then
    SW_VERS=$(sw_vers -productVersion)
    echo -e "  ${GREEN}✓${NC} macOS $SW_VERS"
else
    echo -e "  ${RED}✗${NC} This script is for macOS only"
    exit 1
fi

#-------------------------------------------------------------------------------
# Check Homebrew
#-------------------------------------------------------------------------------
echo -e "${BLUE}🍺 Checking Homebrew...${NC}"
if command -v brew &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Homebrew installed"
else
    echo -e "  ${RED}✗${NC} Homebrew not found"
    MISSING+=("Homebrew")
    COMMANDS+=('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
fi

#-------------------------------------------------------------------------------
# Check Docker Desktop
#-------------------------------------------------------------------------------
echo -e "${BLUE}🐳 Checking Docker Desktop...${NC}"
if [ -d "/Applications/Docker.app" ]; then
    echo -e "  ${GREEN}✓${NC} Docker Desktop installed"

    if docker info &> /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Docker is running"
    else
        echo -e "  ${YELLOW}⚠${NC} Docker is installed but not running"
        echo -e "  ${YELLOW}→${NC} Please start Docker Desktop from Applications"
    fi
else
    echo -e "  ${RED}✗${NC} Docker Desktop not found"
    MISSING+=("Docker Desktop")
    if command -v brew &> /dev/null; then
        COMMANDS+=("brew install --cask docker")
    else
        COMMANDS+=("# Install from: https://www.docker.com/products/docker-desktop/")
    fi
fi

#-------------------------------------------------------------------------------
# Check VS Code
#-------------------------------------------------------------------------------
echo -e "${BLUE}📝 Checking VS Code...${NC}"
if [ -d "/Applications/Visual Studio Code.app" ] || command -v code &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} VS Code installed"
else
    echo -e "  ${RED}✗${NC} VS Code not found"
    MISSING+=("VS Code")
    if command -v brew &> /dev/null; then
        COMMANDS+=("brew install --cask visual-studio-code")
    else
        COMMANDS+=("# Install from: https://code.visualstudio.com/")
    fi
fi

#-------------------------------------------------------------------------------
# Check Dev Containers Extension
#-------------------------------------------------------------------------------
echo -e "${BLUE}🧩 Checking Dev Containers extension...${NC}"
if command -v code &> /dev/null; then
    if code --list-extensions 2>/dev/null | grep -q "ms-vscode-remote.remote-containers"; then
        echo -e "  ${GREEN}✓${NC} Dev Containers extension installed"
    else
        echo -e "  ${RED}✗${NC} Dev Containers extension not found"
        MISSING+=("Dev Containers extension")
        COMMANDS+=("code --install-extension ms-vscode-remote.remote-containers")
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Cannot check extensions (VS Code not in PATH)"
fi

#-------------------------------------------------------------------------------
# Check Git
#-------------------------------------------------------------------------------
echo -e "${BLUE}📦 Checking Git...${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "  ${GREEN}✓${NC} $GIT_VERSION"
else
    echo -e "  ${RED}✗${NC} Git not found"
    MISSING+=("Git")
    COMMANDS+=("xcode-select --install  # or: brew install git")
fi

#-------------------------------------------------------------------------------
# Summary
#-------------------------------------------------------------------------------
echo ""

if [ ${#MISSING[@]} -eq 0 ]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✓ All prerequisites are installed!                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BLUE}Next Steps:${NC}"
    echo ""
    echo -e "  1. Clone and open the project:"
    echo -e "     ${YELLOW}git clone https://github.com/vipasane/autoclaude-VSCode-docker.git ~/AutoClaude${NC}"
    echo -e "     ${YELLOW}code ~/AutoClaude${NC}"
    echo ""
    echo -e "  2. Click 'Reopen in Container' when prompted"
    echo ""
else
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║     Missing Prerequisites                                  ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  The following are missing:"
    for item in "${MISSING[@]}"; do
        echo -e "    ${RED}✗${NC} $item"
    done
    echo ""
    echo -e "  ${BLUE}Run these commands to install:${NC}"
    echo ""
    for cmd in "${COMMANDS[@]}"; do
        echo -e "    ${YELLOW}$cmd${NC}"
    done
    echo ""
    echo -e "  Then re-run this script to verify."
    echo ""
fi

#-------------------------------------------------------------------------------
# Docker Performance Tips
#-------------------------------------------------------------------------------
if [ -d "/Applications/Docker.app" ]; then
    echo -e "${BLUE}💡 Docker Performance Tips for macOS:${NC}"
    echo -e "  • Allocate at least 4GB RAM (8GB recommended) in Docker Desktop settings"
    echo -e "  • Enable VirtioFS file sharing (Settings → General → VirtioFS)"
    echo ""
fi

#-------------------------------------------------------------------------------
# Claude OAuth Token Info
#-------------------------------------------------------------------------------
echo -e "${BLUE}🔐 Claude Authentication:${NC}"
if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    echo -e "  ${GREEN}✓${NC} CLAUDE_CODE_OAUTH_TOKEN is set"
else
    echo -e "  ${YELLOW}ℹ${NC} You can authenticate later by running 'claude login' inside the container"
    echo -e "  ${YELLOW}ℹ${NC} Or set CLAUDE_CODE_OAUTH_TOKEN in ~/.zshrc for automatic auth"
fi
echo ""
