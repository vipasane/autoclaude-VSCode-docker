# Auto-Claude VS Code Dev Container Setup

This folder contains everything needed to run Auto-Claude in an isolated Docker container using VS Code Remote Development.

## Prerequisites

| Requirement | Installation |
|-------------|--------------|
| Docker Desktop | [Download](https://www.docker.com/products/docker-desktop/) - Enable WSL 2 backend |
| VS Code | [Download](https://code.visualstudio.com/) |
| Dev Containers Extension | Install `ms-vscode-remote.remote-containers` in VS Code |
| Claude Pro/Max subscription | Required for Claude Code CLI |

## Quick Start (Windows)

### 1. Configure Docker Desktop

Open Docker Desktop and ensure:
- **Settings → General**: ✓ "Use WSL 2 based engine"
- **Settings → Resources → WSL Integration**: Enable for your distro

### 2. Clone and Setup

```powershell
# Clone repository
git clone https://github.com/AndyMik90/Auto-Claude.git
cd Auto-Claude

# Copy the .devcontainer folder (if not already present)
# The files should be placed in: Auto-Claude/.devcontainer/
```

### 3. Set OAuth Token (Optional but Recommended)

Get your Claude Code OAuth token:

```powershell
# In a terminal with Claude Code installed
claude setup-token
```

Set it as an environment variable in Windows:

```powershell
# PowerShell (current session)
$env:CLAUDE_CODE_OAUTH_TOKEN = "your-token-here"

# Or set permanently via System Properties → Environment Variables
```

### 4. Open in VS Code

1. Open VS Code
2. **File → Open Folder** → Select the `Auto-Claude` folder
3. VS Code should detect `.devcontainer` and prompt:
   
   > "Folder contains a Dev Container configuration file. Reopen folder to develop in a container?"

4. Click **"Reopen in Container"**

   Or use Command Palette: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

5. Wait for the container to build (first time takes 5-10 minutes)

### 5. Verify Setup

Once the container is running, open a terminal in VS Code:

```bash
# Check Claude Code
claude --version

# Check Python
python --version

# Check Node
node --version

# Test FalkorDB connection
redis-cli -h falkordb ping
```

## File Structure

```
.devcontainer/
├── devcontainer.json    # VS Code dev container configuration
├── docker-compose.yml   # Docker services (app + FalkorDB)
├── Dockerfile           # Container image definition
├── post-create.sh       # Runs once after container creation
├── post-start.sh        # Runs each time container starts
└── README.md            # This file
```

## Usage

### Development Mode

```bash
# Start both frontend and backend in dev mode
npm run dev

# Or run them separately:
cd apps/frontend && npm run dev
cd apps/backend && python run.py
```

### Claude Code CLI

```bash
# Interactive mode
claude

# With a prompt
claude "Create a new React component for user authentication"

# Continue previous conversation
claude --continue
```

### Backend CLI (Autonomous Tasks)

```bash
cd apps/backend

# Create a spec interactively
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
| 6379 | FalkorDB | Memory Layer database |

## Volumes & Persistence

Data persists across container restarts:

| Volume | Purpose |
|--------|---------|
| `claude-config` | Claude CLI configuration & auth |
| `claude-history` | Conversation history |
| `auto-claude-venv` | Python virtual environment |
| `auto-claude-node-modules` | Node.js dependencies |
| `falkordb-data` | Memory Layer data |

## Troubleshooting

### Container won't start

```powershell
# Check Docker is running
docker info

# Check for port conflicts
netstat -ano | findstr :3000
netstat -ano | findstr :8000
```

### Slow file operations

Windows + Docker can have slow file I/O. The setup uses cached mounts and volume-based node_modules to mitigate this.

### Claude Code authentication fails

```bash
# Inside the container
claude logout
claude login
```

### FalkorDB connection issues

```bash
# Check if FalkorDB container is running
docker ps | grep falkordb

# Restart FalkorDB
docker restart auto-claude-falkordb
```

### Reset everything

```powershell
# Remove all Auto-Claude volumes and containers
docker-compose -f .devcontainer/docker-compose.yml down -v
docker volume rm auto-claude-node-modules auto-claude-venv claude-config claude-history falkordb-data

# Rebuild from scratch
# In VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

## Security Notes

- The container runs as non-root user `vscode`
- Your host filesystem is only exposed via the workspace mount
- FalkorDB runs in a separate container on an isolated network
- Claude Code credentials persist in a Docker volume (not on host)

## Customization

### Add VS Code Extensions

Edit `devcontainer.json` → `customizations.vscode.extensions`:

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

### Change Python Version

Edit `Dockerfile` and `devcontainer.json` features.

---

For more information, see the [Auto-Claude documentation](https://github.com/AndyMik90/Auto-Claude).
