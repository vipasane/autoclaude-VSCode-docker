# Auto-Claude VS Code Dev Container

A fully automated, self-contained development environment for [Auto-Claude](https://github.com/AndyMik90/Auto-Claude).

## Features

- **One-click setup** — Just open in VS Code and everything installs automatically
- **Auto-clones repository** — No manual git clone needed
- **Isolated environment** — Runs entirely in Docker
- **FalkorDB included** — Memory Layer works out of the box
- **Persistent data** — Node modules, Python venv, and Claude config survive rebuilds
- **Windows optimized** — Volume mounts for better I/O performance

## Prerequisites

| Requirement | Installation |
|-------------|--------------|
| Docker Desktop | [Download](https://www.docker.com/products/docker-desktop/) — Enable WSL 2 backend |
| VS Code | [Download](https://code.visualstudio.com/) |
| Dev Containers Extension | Install `ms-vscode-remote.remote-containers` in VS Code |
| Claude Pro/Max subscription | Required for Claude Code CLI |

## Quick Start

### 1. Create Project Folder

```powershell
# Create a new folder for the project
mkdir C:\AutoClaude
cd C:\AutoClaude

# Create .devcontainer folder
mkdir .devcontainer
mkdir .devcontainer\scripts
```

### 2. Copy Files

Copy these files to `C:\AutoClaude\.devcontainer\`:
- `devcontainer.json`
- `docker-compose.yml`
- `Dockerfile`
- `scripts/setup.sh`
- `scripts/start.sh`
- `scripts/update.sh`
- `scripts/reset.sh`

Or clone this repository directly.

### 3. (Optional) Set OAuth Token

Get your Claude Code OAuth token:

```powershell
# If Claude Code is installed locally
claude setup-token
```

Set as Windows environment variable:

```powershell
# PowerShell (permanent)
[System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_OAUTH_TOKEN", "your-token", "User")

# Or set via: System Properties → Environment Variables
```

### 4. Open in VS Code

1. Open VS Code
2. **File → Open Folder** → Select `C:\AutoClaude`
3. Click **"Reopen in Container"** when prompted

   Or: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

4. Wait for setup (first time takes 5-10 minutes)

### 5. Start Coding!

```bash
# Navigate to Auto-Claude
cd /workspace/auto-claude

# Start development servers
npm run dev

# Or use Claude Code
claude
```

## What Gets Installed

The setup script automatically:

1. ✅ Clones Auto-Claude repository from GitHub
2. ✅ Installs all Node.js dependencies
3. ✅ Creates Python virtual environment
4. ✅ Installs Python dependencies
5. ✅ Creates backend `.env` configuration
6. ✅ Configures Git safe directories
7. ✅ Starts FalkorDB for Memory Layer

## File Structure

```
C:\AutoClaude\
├── .devcontainer/
│   ├── devcontainer.json      # VS Code configuration
│   ├── docker-compose.yml     # Docker services
│   ├── Dockerfile             # Container image
│   └── scripts/
│       ├── setup.sh           # Initial setup (runs once)
│       ├── start.sh           # Startup checks (runs each time)
│       ├── update.sh          # Pull latest changes
│       └── reset.sh           # Clean and reinstall
└── auto-claude/               # ← Created automatically
    ├── apps/
    │   ├── frontend/
    │   └── backend/
    └── ...
```

## Available Scripts

Run these from the VS Code terminal:

| Script | Description |
|--------|-------------|
| `bash .devcontainer/scripts/setup.sh` | Re-run full setup |
| `bash .devcontainer/scripts/update.sh` | Pull latest changes & update deps |
| `bash .devcontainer/scripts/reset.sh` | Interactive reset (node/python/full) |

## Commands Reference

### Development

```bash
# Navigate to project
cd /workspace/auto-claude

# Start all dev servers
npm run dev

# Start frontend only
cd apps/frontend && npm run dev

# Start backend only
cd apps/backend
source .venv/bin/activate
python run.py
```

### Claude Code

```bash
# Interactive mode
claude

# With prompt
claude "Help me create a new feature"

# Continue previous conversation
claude --continue

# Authenticate (if not using OAuth token)
claude login
```

### Backend CLI (Autonomous Tasks)

```bash
cd /workspace/auto-claude/apps/backend
source .venv/bin/activate

# Create spec interactively
python spec_runner.py --interactive

# Run autonomous build
python run.py --spec 001

# Review and merge
python run.py --spec 001 --review
python run.py --spec 001 --merge
```

## Port Mappings

| Port | Service | Description |
|------|---------|-------------|
| 3000 | Frontend | Electron/React dev server |
| 8000 | Backend | Python API server |
| 5173 | Vite | Hot Module Replacement |
| 6379 | FalkorDB | Memory Layer database |

## Troubleshooting

### Container won't start

```powershell
# Check Docker is running
docker info

# Check for port conflicts
netstat -ano | findstr :3000
netstat -ano | findstr :6379
```

### Setup script fails

```bash
# Re-run setup manually
bash .devcontainer/scripts/setup.sh

# Check logs
cat /tmp/setup.log
```

### FalkorDB not responding

```bash
# Check container status
docker ps | grep falkordb

# Restart FalkorDB
docker restart auto-claude-falkordb

# Check logs
docker logs auto-claude-falkordb
```

### Python venv issues

```bash
# Reset Python environment
bash .devcontainer/scripts/reset.sh
# Select option 2
```

### Clean rebuild

```powershell
# In PowerShell, remove all volumes
docker volume rm autoclaude-node-modules-root
docker volume rm autoclaude-node-modules-frontend
docker volume rm autoclaude-falkordb-data

# In VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container Without Cache"
```

## Security Notes

- Container runs as non-root user `vscode`
- Host filesystem only exposed via workspace mount
- FalkorDB runs in separate container on isolated network
- Claude credentials stored in Docker volume (not on host)

## Customization

### Change Auto-Claude Branch

Edit `scripts/setup.sh`:

```bash
AUTO_CLAUDE_BRANCH="main"  # Change from "develop"
```

### Add VS Code Extensions

Edit `devcontainer.json`:

```json
"extensions": [
  "your.extension-id"
]
```

### Add System Packages

Edit `Dockerfile`:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here
```

Then rebuild: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

---

## Links

- [Auto-Claude Repository](https://github.com/AndyMik90/Auto-Claude)
- [VS Code Dev Containers Docs](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
