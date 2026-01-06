#!/bin/bash
#===============================================================================
# Auto-Claude DevContainer - One-Line Installer for macOS & Linux
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup.sh | bash
#
# With custom install path:
#   curl -fsSL https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup.sh | bash -s -- ~/Projects/AutoClaude
#===============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/vipasane/autoclaude-VSCode-docker/archive/refs/heads/main.zip"
DEFAULT_INSTALL_PATH="$HOME/AutoClaude"
INSTALL_PATH="${1:-$DEFAULT_INSTALL_PATH}"

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Auto-Claude DevContainer - Quick Setup                ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

#-------------------------------------------------------------------------------
# Detect OS
#-------------------------------------------------------------------------------
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        echo -e "${BLUE}🍎 Detected: macOS${NC}"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        echo -e "${BLUE}🐧 Detected: Linux${NC}"
    else
        echo -e "${RED}✗ Unsupported OS: $OSTYPE${NC}"
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# Check Prerequisites
#-------------------------------------------------------------------------------
check_prerequisites() {
    echo ""
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

    MISSING=()

    # Check Docker
    if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Docker is installed and running"
    else
        if command -v docker &> /dev/null; then
            echo -e "  ${YELLOW}⚠${NC} Docker is installed but not running"
            MISSING+=("Docker (start it)")
        else
            echo -e "  ${RED}✗${NC} Docker not found"
            MISSING+=("Docker")
        fi
    fi

    # Check VS Code
    if command -v code &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} VS Code is installed"
    else
        echo -e "  ${RED}✗${NC} VS Code not found"
        MISSING+=("VS Code")
    fi

    # Check Dev Containers extension
    if command -v code &> /dev/null; then
        if code --list-extensions 2>/dev/null | grep -q "ms-vscode-remote.remote-containers"; then
            echo -e "  ${GREEN}✓${NC} Dev Containers extension installed"
        else
            echo -e "  ${YELLOW}⚠${NC} Dev Containers extension not found (will try to install)"
        fi
    fi

    # Check git
    if command -v git &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Git is installed"
    else
        echo -e "  ${RED}✗${NC} Git not found"
        MISSING+=("Git")
    fi

    # Check curl or wget
    if command -v curl &> /dev/null || command -v wget &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} curl/wget available"
    else
        echo -e "  ${RED}✗${NC} Neither curl nor wget found"
        MISSING+=("curl or wget")
    fi

    if [ ${#MISSING[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠ Missing prerequisites:${NC}"
        for item in "${MISSING[@]}"; do
            echo -e "  - $item"
        done
        echo ""

        if [[ "$OS" == "macos" ]]; then
            echo -e "Run the full setup script first:"
            echo -e "  ${YELLOW}bash <(curl -fsSL https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/.devcontainer/host-setup/setup-macos.sh)${NC}"
        else
            echo -e "Run the full setup script first:"
            echo -e "  ${YELLOW}bash <(curl -fsSL https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/.devcontainer/host-setup/setup-linux.sh)${NC}"
        fi
        exit 1
    fi
}

#-------------------------------------------------------------------------------
# Download and Extract
#-------------------------------------------------------------------------------
download_repo() {
    echo ""
    echo -e "${BLUE}📥 Downloading Auto-Claude DevContainer...${NC}"
    echo -e "  Install path: ${YELLOW}$INSTALL_PATH${NC}"

    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    TEMP_ZIP="$TEMP_DIR/autoclaude.zip"

    # Download
    if command -v curl &> /dev/null; then
        curl -fsSL "$REPO_URL" -o "$TEMP_ZIP"
    else
        wget -q "$REPO_URL" -O "$TEMP_ZIP"
    fi

    echo -e "  ${GREEN}✓${NC} Downloaded"

    # Check if install path exists
    if [ -d "$INSTALL_PATH" ]; then
        echo -e "  ${YELLOW}⚠${NC} Directory already exists: $INSTALL_PATH"
        read -p "  Overwrite? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "  ${RED}✗${NC} Cancelled"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        rm -rf "$INSTALL_PATH"
    fi

    # Extract
    echo -e "  ${BLUE}→${NC} Extracting..."
    unzip -q "$TEMP_ZIP" -d "$TEMP_DIR"

    # Move to install path (the zip extracts to a subdirectory)
    mv "$TEMP_DIR"/autoclaude-VSCode-docker-* "$INSTALL_PATH"

    # Cleanup
    rm -rf "$TEMP_DIR"

    echo -e "  ${GREEN}✓${NC} Extracted to $INSTALL_PATH"
}

#-------------------------------------------------------------------------------
# Install Dev Containers Extension
#-------------------------------------------------------------------------------
install_extension() {
    if command -v code &> /dev/null; then
        if ! code --list-extensions 2>/dev/null | grep -q "ms-vscode-remote.remote-containers"; then
            echo ""
            echo -e "${BLUE}🧩 Installing Dev Containers extension...${NC}"
            code --install-extension ms-vscode-remote.remote-containers
            echo -e "  ${GREEN}✓${NC} Extension installed"
        fi
    fi
}

#-------------------------------------------------------------------------------
# Open VS Code
#-------------------------------------------------------------------------------
open_vscode() {
    echo ""
    echo -e "${BLUE}📝 Opening VS Code...${NC}"

    cd "$INSTALL_PATH"
    code .

    echo -e "  ${GREEN}✓${NC} VS Code opened"
}

#-------------------------------------------------------------------------------
# Final Instructions
#-------------------------------------------------------------------------------
show_instructions() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✓ Setup Complete!                                     ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BLUE}Next Steps:${NC}"
    echo ""
    echo -e "  1. In VS Code, click ${YELLOW}\"Reopen in Container\"${NC} when prompted"
    echo -e "     Or: Cmd/Ctrl+Shift+P → \"Dev Containers: Reopen in Container\""
    echo ""
    echo -e "  2. Wait for the container to build (~5-10 minutes first time)"
    echo ""
    echo -e "  3. Authenticate Claude Code:"
    echo -e "     ${YELLOW}claude login${NC}"
    echo ""
    echo -e "  4. Start developing:"
    echo -e "     ${YELLOW}cd /workspace/auto-claude${NC}"
    echo -e "     ${YELLOW}npm run dev${NC}"
    echo ""
    echo -e "  ${BLUE}Install Location:${NC} $INSTALL_PATH"
    echo ""
}

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
main() {
    detect_os
    check_prerequisites
    download_repo
    install_extension
    open_vscode
    show_instructions
}

main "$@"
