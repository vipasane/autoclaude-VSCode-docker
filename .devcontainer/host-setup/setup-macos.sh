#!/bin/bash
#===============================================================================
# Auto-Claude DevContainer - macOS Host Setup
# Run this script on your Mac BEFORE opening the project in VS Code
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Auto-Claude DevContainer - macOS Setup                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

#-------------------------------------------------------------------------------
# Check macOS version
#-------------------------------------------------------------------------------
echo -e "${BLUE}🍎 Checking macOS...${NC}"
SW_VERS=$(sw_vers -productVersion)
echo -e "  ${GREEN}✓${NC} macOS $SW_VERS"

#-------------------------------------------------------------------------------
# Check/Install Homebrew
#-------------------------------------------------------------------------------
echo -e "${BLUE}🍺 Checking Homebrew...${NC}"
if command -v brew &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Homebrew installed"
else
    echo -e "  ${YELLOW}→${NC} Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo -e "  ${GREEN}✓${NC} Homebrew installed"
fi

#-------------------------------------------------------------------------------
# Check/Install Docker Desktop
#-------------------------------------------------------------------------------
echo -e "${BLUE}🐳 Checking Docker Desktop...${NC}"
if [ -d "/Applications/Docker.app" ]; then
    echo -e "  ${GREEN}✓${NC} Docker Desktop installed"

    # Check if Docker is running
    if docker info &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker is running"
    else
        echo -e "  ${YELLOW}⚠${NC} Docker is not running"
        echo -e "  ${YELLOW}→${NC} Starting Docker Desktop..."
        open -a Docker
        echo -e "  ${YELLOW}→${NC} Waiting for Docker to start (this may take a minute)..."

        # Wait for Docker to be ready
        COUNTER=0
        while ! docker info &> /dev/null; do
            sleep 2
            COUNTER=$((COUNTER + 1))
            if [ $COUNTER -gt 60 ]; then
                echo -e "  ${RED}✗${NC} Docker failed to start. Please start it manually."
                exit 1
            fi
        done
        echo -e "  ${GREEN}✓${NC} Docker is now running"
    fi
else
    echo -e "  ${YELLOW}→${NC} Installing Docker Desktop..."
    brew install --cask docker
    echo -e "  ${GREEN}✓${NC} Docker Desktop installed"
    echo -e "  ${YELLOW}→${NC} Starting Docker Desktop..."
    open -a Docker
    echo ""
    echo -e "  ${YELLOW}⚠ Please complete Docker Desktop setup wizard, then re-run this script${NC}"
    exit 0
fi

#-------------------------------------------------------------------------------
# Check/Install VS Code
#-------------------------------------------------------------------------------
echo -e "${BLUE}📝 Checking VS Code...${NC}"
if [ -d "/Applications/Visual Studio Code.app" ] || command -v code &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} VS Code installed"
else
    echo -e "  ${YELLOW}→${NC} Installing VS Code..."
    brew install --cask visual-studio-code
    echo -e "  ${GREEN}✓${NC} VS Code installed"
fi

#-------------------------------------------------------------------------------
# Check/Install Dev Containers Extension
#-------------------------------------------------------------------------------
echo -e "${BLUE}🧩 Checking Dev Containers extension...${NC}"
if code --list-extensions 2>/dev/null | grep -q "ms-vscode-remote.remote-containers"; then
    echo -e "  ${GREEN}✓${NC} Dev Containers extension installed"
else
    echo -e "  ${YELLOW}→${NC} Installing Dev Containers extension..."
    code --install-extension ms-vscode-remote.remote-containers
    echo -e "  ${GREEN}✓${NC} Dev Containers extension installed"
fi

#-------------------------------------------------------------------------------
# Check/Install Git
#-------------------------------------------------------------------------------
echo -e "${BLUE}📦 Checking Git...${NC}"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    echo -e "  ${GREEN}✓${NC} $GIT_VERSION"
else
    echo -e "  ${YELLOW}→${NC} Installing Git..."
    brew install git
    echo -e "  ${GREEN}✓${NC} Git installed"
fi

#-------------------------------------------------------------------------------
# Docker Performance Settings for macOS
#-------------------------------------------------------------------------------
echo -e "${BLUE}⚡ Docker Performance Tips for macOS...${NC}"
echo -e "  ${YELLOW}→${NC} For best performance, ensure Docker Desktop has:"
echo -e "     • At least 4GB RAM allocated (8GB recommended)"
echo -e "     • VirtioFS file sharing enabled (Settings > General)"
echo -e "     • Use the 'gRPC FUSE' or 'VirtioFS' file sharing option"

#-------------------------------------------------------------------------------
# Claude OAuth Token Setup
#-------------------------------------------------------------------------------
echo ""
echo -e "${BLUE}🔐 Claude OAuth Token Setup...${NC}"
if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    echo -e "  ${GREEN}✓${NC} CLAUDE_CODE_OAUTH_TOKEN is set"
else
    echo -e "  ${YELLOW}⚠${NC} CLAUDE_CODE_OAUTH_TOKEN not set"
    echo ""
    echo -e "  To set it permanently, add to your ~/.zshrc or ~/.bash_profile:"
    echo -e "  ${YELLOW}export CLAUDE_CODE_OAUTH_TOKEN=\"your-token-here\"${NC}"
    echo ""
    echo -e "  Or you can run 'claude login' inside the container after setup."
fi

#-------------------------------------------------------------------------------
# Summary
#-------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✓ macOS Setup Complete!                               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BLUE}Next Steps:${NC}"
echo ""
echo -e "  1. Open this folder in VS Code:"
echo -e "     ${YELLOW}code .${NC}"
echo ""
echo -e "  2. When prompted, click 'Reopen in Container'"
echo -e "     Or use Command Palette: 'Dev Containers: Reopen in Container'"
echo ""
echo -e "  3. Wait for container to build (first time takes ~5-10 minutes)"
echo ""
echo -e "  4. Start developing:"
echo -e "     ${YELLOW}cd /workspace/auto-claude${NC}"
echo -e "     ${YELLOW}npm run dev${NC}"
echo ""
