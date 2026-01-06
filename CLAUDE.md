# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Host Setup (Before Opening in VS Code)

### macOS
```bash
# Run the setup script
bash .devcontainer/host-setup/setup-macos.sh

# Or manually ensure you have:
# - Docker Desktop (with VirtioFS enabled for performance)
# - VS Code with Dev Containers extension
# - Git
```

### Linux (Ubuntu/Debian/Fedora/Arch)
```bash
# Run the setup script
bash .devcontainer/host-setup/setup-linux.sh

# Or manually ensure you have:
# - Docker Engine (with your user in the docker group)
# - VS Code with Dev Containers extension
# - Git
```

### Windows (WSL2)
1. Install WSL2 with Ubuntu: `wsl --install`
2. Install Docker Desktop with WSL2 backend enabled
3. Install VS Code with Dev Containers extension
4. Clone this repo inside WSL2 (not Windows filesystem)
5. Open folder in VS Code from WSL2

### After Host Setup
1. Open this folder in VS Code: `code .`
2. Click "Reopen in Container" when prompted (or Command Palette → "Dev Containers: Reopen in Container")
3. Wait for container build (~5-10 minutes first time)

## Project Overview

This is a **devcontainer configuration** that creates a fully self-contained Docker-based development environment for the Auto-Claude project. When opened in VS Code (or other devcontainer-compatible editors), it automatically:

1. Clones the Auto-Claude repository from `github.com/AndyMik90/Auto-Claude` (develop branch)
2. Sets up Node.js 22.x and Python 3.12 environments
3. Installs all dependencies (npm packages and Python venv)
4. Spins up FalkorDB for the memory layer
5. Configures Claude Code CLI

## Key Scripts

**Host Setup** (`.devcontainer/host-setup/`) - Run on your machine before opening in VS Code:

| Script | Purpose |
|--------|---------|
| `setup-macos.sh` | Installs Docker Desktop, VS Code, Dev Containers extension on macOS |
| `setup-linux.sh` | Installs Docker, VS Code, Dev Containers extension on Linux (Ubuntu/Debian/Fedora/Arch) |

**Container Scripts** (`.devcontainer/scripts/`) - Run automatically or manually inside container:

| Script | Purpose |
|--------|---------|
| `setup.sh` | One-time setup: clones repo, installs deps, creates Python venv |
| `start.sh` | Runs on every container start: fixes permissions, activates venv, shows status |
| `update.sh` | Pulls latest changes and reinstalls dependencies |
| `reset.sh` | Interactive script to clean node_modules, Python venv, or full re-clone |

## Container Architecture

- **auto-claude service**: Main development container (Ubuntu 24.04)
- **falkordb service**: FalkorDB database for memory layer (port 6379)

Volume mounts for performance on Windows:
- `node-modules-*`: Separate volumes for node_modules (root, frontend, backend)
- `claude-config/claude-history`: Persist Claude CLI config between rebuilds
- `falkordb-data`: Persist database data

## Ports

| Port | Service |
|------|---------|
| 3000 | Frontend |
| 8000 | Backend API |
| 5173 | Vite Dev Server |
| 6379 | FalkorDB |

## Environment Variables

Required:
- `CLAUDE_CODE_OAUTH_TOKEN`: Set in host environment for Claude authentication

Container-set:
- `GRAPHITI_ENABLED=true`
- `FALKORDB_HOST=falkordb`
- `FALKORDB_PORT=6379`
- `AUTO_CLAUDE_DIR=/workspace/auto-claude`

## Common Commands (inside container)

```bash
# Navigate to Auto-Claude project
cd /workspace/auto-claude

# Start development servers
npm run dev

# Build and run the Electron app
npm start

# Backend CLI (activate venv first)
cd apps/backend
source .venv/bin/activate
python run.py --spec 001

# Update to latest code
bash /workspace/.devcontainer/scripts/update.sh

# Reset environment
bash /workspace/.devcontainer/scripts/reset.sh
```

## Notes

- The `auto-claude/` directory is the cloned Auto-Claude repo; this devcontainer repo only contains the setup configuration
- Python venv is at `/workspace/auto-claude/apps/backend/.venv`
- If not authenticated, run `claude login` after container starts
