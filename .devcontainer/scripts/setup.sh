#!/bin/bash
#===============================================================================
# Auto-Claude Development Environment Setup
# This script runs once after container creation
# It handles: repo clone, dependencies, Python venv, configuration
#===============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AUTO_CLAUDE_REPO="https://github.com/AndyMik90/Auto-Claude.git"
AUTO_CLAUDE_BRANCH="develop"
AUTO_CLAUDE_DIR="/workspace/auto-claude"

#-------------------------------------------------------------------------------
# Helper functions
#-------------------------------------------------------------------------------
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

#-------------------------------------------------------------------------------
# Fix Permissions for Mounted Volumes
#-------------------------------------------------------------------------------
fix_permissions() {
    log_section "Fixing Permissions"
    
    # Fix Claude config directory permissions
    # This is needed because Docker volumes may be created as root
    CLAUDE_DIRS=(
        "/home/vscode/.claude"
        "/home/vscode/.claude-code"
    )
    
    for dir in "${CLAUDE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            # Check if we own it
            if [ ! -w "$dir" ]; then
                log_info "Fixing permissions on $dir..."
                sudo chown -R vscode:vscode "$dir" 2>/dev/null || {
                    log_warn "Could not fix permissions on $dir (may need manual sudo)"
                }
            fi
        else
            # Create with correct ownership
            mkdir -p "$dir" 2>/dev/null || sudo mkdir -p "$dir"
            sudo chown -R vscode:vscode "$dir" 2>/dev/null || true
        fi
    done
    
    log_success "Permissions configured"
}

#-------------------------------------------------------------------------------
# Clone Auto-Claude Repository
#-------------------------------------------------------------------------------
clone_repository() {
    log_section "Cloning Auto-Claude Repository"
    
    if [ -d "$AUTO_CLAUDE_DIR/.git" ]; then
        log_info "Repository already exists, pulling latest changes..."
        cd "$AUTO_CLAUDE_DIR"
        git fetch origin
        git pull origin "$AUTO_CLAUDE_BRANCH" || log_warn "Pull failed, using existing code"
    else
        log_info "Cloning from $AUTO_CLAUDE_REPO..."
        
        # Remove directory if it exists but isn't a git repo
        if [ -d "$AUTO_CLAUDE_DIR" ]; then
            rm -rf "$AUTO_CLAUDE_DIR"
        fi
        
        git clone --branch "$AUTO_CLAUDE_BRANCH" "$AUTO_CLAUDE_REPO" "$AUTO_CLAUDE_DIR"
        log_success "Repository cloned successfully"
    fi
    
    cd "$AUTO_CLAUDE_DIR"
    log_success "Current branch: $(git branch --show-current)"
    log_success "Latest commit: $(git log -1 --oneline)"
}

#-------------------------------------------------------------------------------
# Setup Node.js Dependencies
#-------------------------------------------------------------------------------
setup_nodejs() {
    log_section "Setting up Node.js Dependencies"
    
    cd "$AUTO_CLAUDE_DIR"
    
    # Root dependencies
    if [ -f "package.json" ]; then
        log_info "Installing root dependencies..."
        npm install || log_warn "Root npm install had issues"
        log_success "Root dependencies installed"
    fi
    
    # Frontend dependencies
    if [ -f "apps/frontend/package.json" ]; then
        log_info "Installing frontend dependencies..."
        cd "$AUTO_CLAUDE_DIR/apps/frontend"
        npm install || log_warn "Frontend npm install had issues"
        log_success "Frontend dependencies installed"
        cd "$AUTO_CLAUDE_DIR"
    fi
    
    # Backend Node dependencies (if any)
    if [ -f "apps/backend/package.json" ]; then
        log_info "Installing backend Node dependencies..."
        cd "$AUTO_CLAUDE_DIR/apps/backend"
        npm install || log_warn "Backend npm install had issues"
        cd "$AUTO_CLAUDE_DIR"
    fi
}

#-------------------------------------------------------------------------------
# Setup Python Environment
#-------------------------------------------------------------------------------
setup_python() {
    log_section "Setting up Python Environment"
    
    BACKEND_DIR="$AUTO_CLAUDE_DIR/apps/backend"
    VENV_DIR="$BACKEND_DIR/.venv"
    
    if [ ! -d "$BACKEND_DIR" ]; then
        log_warn "Backend directory not found at $BACKEND_DIR"
        log_info "Creating minimal Python environment in $AUTO_CLAUDE_DIR/.venv"
        VENV_DIR="$AUTO_CLAUDE_DIR/.venv"
    fi
    
    cd "$(dirname "$VENV_DIR")"
    
    # Clean up broken venv
    if [ -d ".venv" ] && [ ! -f ".venv/bin/activate" ]; then
        log_warn "Removing incomplete venv..."
        rm -rf .venv
    fi
    
    # Create virtual environment
    if [ ! -d ".venv" ]; then
        log_info "Creating Python virtual environment..."
        python3.12 -m venv .venv || python3 -m venv .venv || {
            log_error "Failed to create venv"
            return 1
        }
        log_success "Virtual environment created"
    else
        log_info "Virtual environment already exists"
    fi
    
    # Activate venv
    source .venv/bin/activate
    log_success "Virtual environment activated"
    
    # Upgrade pip
    log_info "Upgrading pip..."
    pip install --upgrade pip wheel setuptools
    
    # Install requirements
    if [ -f "requirements.txt" ]; then
        log_info "Installing Python dependencies from requirements.txt..."
        pip install -r requirements.txt || log_warn "Some dependencies failed to install"
        log_success "Python dependencies installed"
    fi
    
    # Install dev requirements if they exist
    if [ -f "requirements-dev.txt" ]; then
        log_info "Installing dev dependencies..."
        pip install -r requirements-dev.txt || log_warn "Some dev dependencies failed"
    fi
    
    cd "$AUTO_CLAUDE_DIR"
}

#-------------------------------------------------------------------------------
# Setup Environment Configuration
#-------------------------------------------------------------------------------
setup_environment() {
    log_section "Setting up Environment Configuration"
    
    # Backend .env
    if [ -d "$AUTO_CLAUDE_DIR/apps/backend" ]; then
        if [ ! -f "$AUTO_CLAUDE_DIR/apps/backend/.env" ]; then
            if [ -f "$AUTO_CLAUDE_DIR/apps/backend/.env.example" ]; then
                log_info "Creating backend .env from example..."
                cp "$AUTO_CLAUDE_DIR/apps/backend/.env.example" "$AUTO_CLAUDE_DIR/apps/backend/.env"
                
                # Add FalkorDB configuration
                echo "" >> "$AUTO_CLAUDE_DIR/apps/backend/.env"
                echo "# Added by devcontainer setup" >> "$AUTO_CLAUDE_DIR/apps/backend/.env"
                echo "FALKORDB_HOST=falkordb" >> "$AUTO_CLAUDE_DIR/apps/backend/.env"
                echo "FALKORDB_PORT=6379" >> "$AUTO_CLAUDE_DIR/apps/backend/.env"
                echo "GRAPHITI_ENABLED=true" >> "$AUTO_CLAUDE_DIR/apps/backend/.env"
                
                log_success "Backend .env created"
            else
                log_info "Creating minimal backend .env..."
                cat > "$AUTO_CLAUDE_DIR/apps/backend/.env" << 'EOF'
# Auto-Claude Backend Configuration
# Created by devcontainer setup

# FalkorDB (Memory Layer)
FALKORDB_HOST=falkordb
FALKORDB_PORT=6379
GRAPHITI_ENABLED=true

# Claude Code OAuth Token (set via environment variable)
# CLAUDE_CODE_OAUTH_TOKEN=your-token-here
EOF
                log_success "Minimal backend .env created"
            fi
        else
            log_info "Backend .env already exists"
        fi
    fi
}

#-------------------------------------------------------------------------------
# Setup Git Configuration
#-------------------------------------------------------------------------------
setup_git() {
    log_section "Configuring Git"
    
    # Mark workspace as safe
    git config --global --add safe.directory /workspace
    git config --global --add safe.directory "$AUTO_CLAUDE_DIR"
    
    log_success "Git safe directories configured"
    
    # Set default branch name for new repos
    git config --global init.defaultBranch main
}

#-------------------------------------------------------------------------------
# Verify Claude Code Installation
#-------------------------------------------------------------------------------
verify_claude() {
    log_section "Verifying Claude Code CLI"
    
    if command -v claude &> /dev/null; then
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        log_success "Claude Code CLI installed: $CLAUDE_VERSION"
        
        if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
            log_success "OAuth token configured (from environment)"
        else
            log_warn "No OAuth token found"
            log_info "Run 'claude login' to authenticate"
        fi
    else
        log_error "Claude Code CLI not found"
        log_info "Installing Claude Code CLI..."
        npm install -g @anthropic-ai/claude-code
    fi
}

#-------------------------------------------------------------------------------
# Verify Services
#-------------------------------------------------------------------------------
verify_services() {
    log_section "Verifying Services"
    
    # Check FalkorDB
    if redis-cli -h falkordb ping > /dev/null 2>&1; then
        log_success "FalkorDB is running and accessible"
    else
        log_warn "FalkorDB not responding (Memory Layer may not work)"
    fi
}

#-------------------------------------------------------------------------------
# Main Setup
#-------------------------------------------------------------------------------
main() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Auto-Claude Development Environment Setup             ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Run setup steps
    fix_permissions      # NEW: Fix volume permissions first
    clone_repository
    setup_nodejs
    setup_python
    setup_environment
    setup_git
    verify_claude
    verify_services
    
    # Final summary
    log_section "Setup Complete!"
    
    echo ""
    echo -e "  ${GREEN}Auto-Claude directory:${NC} $AUTO_CLAUDE_DIR"
    echo ""
    echo -e "  ${BLUE}Quick Start Commands:${NC}"
    echo "    cd $AUTO_CLAUDE_DIR"
    echo "    npm run dev          # Start development servers"
    echo "    npm start            # Build and run app"
    echo "    claude               # Start Claude Code CLI"
    echo ""
    echo -e "  ${BLUE}Backend CLI:${NC}"
    echo "    cd $AUTO_CLAUDE_DIR/apps/backend"
    echo "    source .venv/bin/activate"
    echo "    python run.py --spec 001"
    echo ""
    
    if [ -z "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
        echo -e "  ${YELLOW}⚠ Remember to authenticate:${NC}"
        echo "    claude login"
        echo ""
    fi
}

# Run main function
main "$@"
