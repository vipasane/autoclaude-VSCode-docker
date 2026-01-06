#!/bin/bash
#===============================================================================
# Auto-Claude DevContainer - Linux Prerequisites Check
# This script checks if all prerequisites are installed and provides
# installation commands for anything missing. It does NOT install anything.
# Supports: Ubuntu/Debian, Fedora/RHEL, Arch Linux
#===============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Auto-Claude DevContainer - Linux Prerequisites        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

MISSING=()
COMMANDS=()

#-------------------------------------------------------------------------------
# Detect Linux Distribution
#-------------------------------------------------------------------------------
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
        VERSION=$VERSION_ID
        PRETTY_NAME=$PRETTY_NAME
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
        VERSION=$DISTRIB_RELEASE
        PRETTY_NAME="$DISTRIB_ID $DISTRIB_RELEASE"
    else
        DISTRO="unknown"
        PRETTY_NAME="Unknown Linux"
    fi
}

detect_distro
echo -e "${BLUE}🐧 Detected: ${NC}$PRETTY_NAME"
echo ""

#-------------------------------------------------------------------------------
# Check Docker
#-------------------------------------------------------------------------------
echo -e "${BLUE}🐳 Checking Docker...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null)
    echo -e "  ${GREEN}✓${NC} $DOCKER_VERSION"

    if docker info &> /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Docker daemon is running"
    else
        echo -e "  ${YELLOW}⚠${NC} Docker installed but daemon not accessible"
        if ! groups $USER | grep -q docker; then
            echo -e "  ${YELLOW}→${NC} Your user is not in the docker group"
            MISSING+=("Docker group membership")
            COMMANDS+=("sudo usermod -aG docker \$USER && newgrp docker")
        else
            echo -e "  ${YELLOW}→${NC} Try: sudo systemctl start docker"
        fi
    fi
else
    echo -e "  ${RED}✗${NC} Docker not found"
    MISSING+=("Docker")

    case $DISTRO in
        ubuntu|debian|pop|linuxmint)
            COMMANDS+=("# Install Docker on $DISTRO:")
            COMMANDS+=("sudo apt-get update")
            COMMANDS+=("sudo apt-get install -y ca-certificates curl gnupg")
            COMMANDS+=("sudo install -m 0755 -d /etc/apt/keyrings")
            COMMANDS+=("curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg")
            COMMANDS+=("echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \$(. /etc/os-release && echo \$VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list")
            COMMANDS+=("sudo apt-get update")
            COMMANDS+=("sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin")
            COMMANDS+=("sudo usermod -aG docker \$USER && newgrp docker")
            ;;
        fedora)
            COMMANDS+=("# Install Docker on Fedora:")
            COMMANDS+=("sudo dnf -y install dnf-plugins-core")
            COMMANDS+=("sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo")
            COMMANDS+=("sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin")
            COMMANDS+=("sudo systemctl start docker && sudo systemctl enable docker")
            COMMANDS+=("sudo usermod -aG docker \$USER && newgrp docker")
            ;;
        arch|manjaro|endeavouros)
            COMMANDS+=("# Install Docker on Arch:")
            COMMANDS+=("sudo pacman -S docker docker-compose")
            COMMANDS+=("sudo systemctl start docker && sudo systemctl enable docker")
            COMMANDS+=("sudo usermod -aG docker \$USER && newgrp docker")
            ;;
        *)
            COMMANDS+=("# Install Docker: https://docs.docker.com/engine/install/")
            ;;
    esac
fi

#-------------------------------------------------------------------------------
# Check VS Code
#-------------------------------------------------------------------------------
echo -e "${BLUE}📝 Checking VS Code...${NC}"
if command -v code &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} VS Code installed"
else
    echo -e "  ${RED}✗${NC} VS Code not found"
    MISSING+=("VS Code")

    case $DISTRO in
        ubuntu|debian|pop|linuxmint)
            COMMANDS+=("")
            COMMANDS+=("# Install VS Code on $DISTRO:")
            COMMANDS+=("wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg")
            COMMANDS+=("sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg")
            COMMANDS+=("echo \"deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" | sudo tee /etc/apt/sources.list.d/vscode.list")
            COMMANDS+=("rm packages.microsoft.gpg")
            COMMANDS+=("sudo apt-get update && sudo apt-get install -y code")
            ;;
        fedora)
            COMMANDS+=("")
            COMMANDS+=("# Install VS Code on Fedora:")
            COMMANDS+=("sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc")
            COMMANDS+=("echo -e \"[code]\\nname=Visual Studio Code\\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\\nenabled=1\\ngpgcheck=1\\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" | sudo tee /etc/yum.repos.d/vscode.repo")
            COMMANDS+=("sudo dnf install -y code")
            ;;
        arch|manjaro|endeavouros)
            COMMANDS+=("")
            COMMANDS+=("# Install VS Code on Arch (AUR):")
            COMMANDS+=("yay -S visual-studio-code-bin  # or use paru, or download from https://code.visualstudio.com/")
            ;;
        *)
            COMMANDS+=("")
            COMMANDS+=("# Install VS Code: https://code.visualstudio.com/")
            ;;
    esac
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
        COMMANDS+=("")
        COMMANDS+=("# Install Dev Containers extension:")
        COMMANDS+=("code --install-extension ms-vscode-remote.remote-containers")
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Cannot check extensions (VS Code not installed)"
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

    case $DISTRO in
        ubuntu|debian|pop|linuxmint)
            COMMANDS+=("sudo apt-get install -y git")
            ;;
        fedora)
            COMMANDS+=("sudo dnf install -y git")
            ;;
        arch|manjaro|endeavouros)
            COMMANDS+=("sudo pacman -S git")
            ;;
        *)
            COMMANDS+=("# Install git using your package manager")
            ;;
    esac
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
    echo -e "     Or: Ctrl+Shift+P → 'Dev Containers: Reopen in Container'"
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
        if [ -n "$cmd" ]; then
            echo -e "    ${YELLOW}$cmd${NC}"
        else
            echo ""
        fi
    done
    echo ""
    echo -e "  Then re-run this script to verify."
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
    echo -e "  ${YELLOW}ℹ${NC} Or set CLAUDE_CODE_OAUTH_TOKEN in ~/.bashrc for automatic auth"
fi
echo ""
