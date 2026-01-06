#!/bin/bash
#===============================================================================
# Auto-Claude DevContainer - Linux Host Setup
# Run this script on your Linux machine BEFORE opening the project in VS Code
# Supports: Ubuntu/Debian, Fedora/RHEL, Arch Linux
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
echo -e "${BLUE}║     Auto-Claude DevContainer - Linux Setup                ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

#-------------------------------------------------------------------------------
# Detect Linux Distribution
#-------------------------------------------------------------------------------
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
        VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$DISTRIB_ID
        VERSION=$DISTRIB_RELEASE
    else
        DISTRO="unknown"
    fi

    echo -e "${BLUE}🐧 Detected: ${NC}$DISTRO $VERSION"
}

#-------------------------------------------------------------------------------
# Package manager helpers
#-------------------------------------------------------------------------------
install_debian() {
    sudo apt-get update
    sudo apt-get install -y "$@"
}

install_fedora() {
    sudo dnf install -y "$@"
}

install_arch() {
    sudo pacman -S --noconfirm "$@"
}

install_package() {
    case $DISTRO in
        ubuntu|debian|pop|linuxmint)
            install_debian "$@"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            install_fedora "$@"
            ;;
        arch|manjaro|endeavouros)
            install_arch "$@"
            ;;
        *)
            echo -e "${RED}✗${NC} Unsupported distribution: $DISTRO"
            echo -e "  Please install manually: $@"
            return 1
            ;;
    esac
}

#-------------------------------------------------------------------------------
# Check/Install Docker
#-------------------------------------------------------------------------------
install_docker() {
    echo -e "${BLUE}🐳 Checking Docker...${NC}"

    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version)
        echo -e "  ${GREEN}✓${NC} $DOCKER_VERSION"
    else
        echo -e "  ${YELLOW}→${NC} Installing Docker..."

        case $DISTRO in
            ubuntu|debian|pop|linuxmint)
                # Remove old versions
                sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

                # Install prerequisites
                sudo apt-get update
                sudo apt-get install -y ca-certificates curl gnupg

                # Add Docker's official GPG key
                sudo install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                sudo chmod a+r /etc/apt/keyrings/docker.gpg

                # Set up repository
                echo \
                    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
                    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

                # Install Docker
                sudo apt-get update
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;

            fedora)
                sudo dnf -y install dnf-plugins-core
                sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;

            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm docker docker-compose
                ;;

            *)
                echo -e "${RED}✗${NC} Please install Docker manually for $DISTRO"
                echo -e "  Visit: https://docs.docker.com/engine/install/"
                return 1
                ;;
        esac

        echo -e "  ${GREEN}✓${NC} Docker installed"
    fi

    # Start and enable Docker service
    echo -e "${BLUE}🔧 Configuring Docker service...${NC}"
    sudo systemctl start docker
    sudo systemctl enable docker
    echo -e "  ${GREEN}✓${NC} Docker service enabled"

    # Add current user to docker group
    if ! groups $USER | grep -q docker; then
        echo -e "  ${YELLOW}→${NC} Adding $USER to docker group..."
        sudo usermod -aG docker $USER
        echo -e "  ${YELLOW}⚠${NC} You may need to log out and back in for group changes to take effect"
        echo -e "  ${YELLOW}→${NC} Or run: newgrp docker"
    else
        echo -e "  ${GREEN}✓${NC} User already in docker group"
    fi
}

#-------------------------------------------------------------------------------
# Check/Install VS Code
#-------------------------------------------------------------------------------
install_vscode() {
    echo -e "${BLUE}📝 Checking VS Code...${NC}"

    if command -v code &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} VS Code installed"
    else
        echo -e "  ${YELLOW}→${NC} Installing VS Code..."

        case $DISTRO in
            ubuntu|debian|pop|linuxmint)
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
                sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                rm -f packages.microsoft.gpg
                sudo apt-get update
                sudo apt-get install -y code
                ;;

            fedora|rhel|centos)
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                sudo dnf install -y code
                ;;

            arch|manjaro|endeavouros)
                # Use yay or paru if available, otherwise manual
                if command -v yay &> /dev/null; then
                    yay -S --noconfirm visual-studio-code-bin
                elif command -v paru &> /dev/null; then
                    paru -S --noconfirm visual-studio-code-bin
                else
                    echo -e "  ${YELLOW}→${NC} Install from AUR: visual-studio-code-bin"
                    echo -e "  ${YELLOW}→${NC} Or download from: https://code.visualstudio.com/"
                fi
                ;;

            *)
                echo -e "${YELLOW}→${NC} Download VS Code from: https://code.visualstudio.com/"
                ;;
        esac

        if command -v code &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} VS Code installed"
        fi
    fi
}

#-------------------------------------------------------------------------------
# Check/Install Dev Containers Extension
#-------------------------------------------------------------------------------
install_devcontainers_extension() {
    echo -e "${BLUE}🧩 Checking Dev Containers extension...${NC}"

    if command -v code &> /dev/null; then
        if code --list-extensions 2>/dev/null | grep -q "ms-vscode-remote.remote-containers"; then
            echo -e "  ${GREEN}✓${NC} Dev Containers extension installed"
        else
            echo -e "  ${YELLOW}→${NC} Installing Dev Containers extension..."
            code --install-extension ms-vscode-remote.remote-containers
            echo -e "  ${GREEN}✓${NC} Dev Containers extension installed"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} VS Code not found, skipping extension install"
    fi
}

#-------------------------------------------------------------------------------
# Check/Install Git
#-------------------------------------------------------------------------------
install_git() {
    echo -e "${BLUE}📦 Checking Git...${NC}"

    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        echo -e "  ${GREEN}✓${NC} $GIT_VERSION"
    else
        echo -e "  ${YELLOW}→${NC} Installing Git..."

        case $DISTRO in
            ubuntu|debian|pop|linuxmint)
                install_debian git
                ;;
            fedora|rhel|centos|rocky|almalinux)
                install_fedora git
                ;;
            arch|manjaro|endeavouros)
                install_arch git
                ;;
        esac

        echo -e "  ${GREEN}✓${NC} Git installed"
    fi
}

#-------------------------------------------------------------------------------
# Claude OAuth Token Setup
#-------------------------------------------------------------------------------
setup_oauth_info() {
    echo ""
    echo -e "${BLUE}🔐 Claude OAuth Token Setup...${NC}"

    if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo -e "  ${GREEN}✓${NC} CLAUDE_CODE_OAUTH_TOKEN is set"
    else
        echo -e "  ${YELLOW}⚠${NC} CLAUDE_CODE_OAUTH_TOKEN not set"
        echo ""
        echo -e "  To set it permanently, add to your ~/.bashrc or ~/.zshrc:"
        echo -e "  ${YELLOW}export CLAUDE_CODE_OAUTH_TOKEN=\"your-token-here\"${NC}"
        echo ""
        echo -e "  Or you can run 'claude login' inside the container after setup."
    fi
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    detect_distro
    echo ""

    install_git
    install_docker
    install_vscode
    install_devcontainers_extension
    setup_oauth_info

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✓ Linux Setup Complete!                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BLUE}Next Steps:${NC}"
    echo ""

    if ! groups $USER | grep -q docker; then
        echo -e "  ${YELLOW}0. Log out and back in (or run 'newgrp docker') for docker access${NC}"
        echo ""
    fi

    echo -e "  1. Open this folder in VS Code:"
    echo -e "     ${YELLOW}code .${NC}"
    echo ""
    echo -e "  2. When prompted, click 'Reopen in Container'"
    echo -e "     Or use Command Palette (Ctrl+Shift+P): 'Dev Containers: Reopen in Container'"
    echo ""
    echo -e "  3. Wait for container to build (first time takes ~5-10 minutes)"
    echo ""
    echo -e "  4. Start developing:"
    echo -e "     ${YELLOW}cd /workspace/auto-claude${NC}"
    echo -e "     ${YELLOW}npm run dev${NC}"
    echo ""
}

main "$@"
