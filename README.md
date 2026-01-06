# Auto-Claude VS Code Dev Container

A fully automated, isolated development environment for [Auto-Claude](https://github.com/AndyMik90/Auto-Claude) running in Docker with VS Code Remote Development.

## ⚡ One-Line Quick Start (Windows)

**Open PowerShell and run:**

```powershell
irm https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup.ps1 | iex
```

This will:
1. ✅ Check that Docker and VS Code are installed
2. ✅ Download this repository
3. ✅ Extract to `C:\Users\YourName\AutoClaude`
4. ✅ Open VS Code automatically

Then just click **"Reopen in Container"** when VS Code prompts you!

---

## Features

- ✅ **One-click setup** — Just open in VS Code, everything installs automatically
- ✅ **Auto-clones Auto-Claude** — No manual git commands needed
- ✅ **Fully isolated** — Runs entirely in Docker, keeps your system clean
- ✅ **FalkorDB included** — Memory Layer works out of the box
- ✅ **Persistent data** — Survives container rebuilds
- ✅ **Windows optimized** — Volume mounts for better I/O performance

---

## Prerequisites

| Requirement | Installation |
|-------------|--------------|
| Docker Desktop | [Download](https://www.docker.com/products/docker-desktop/) — Enable WSL 2 backend |
| VS Code | [Download](https://code.visualstudio.com/) |
| Dev Containers Extension | Install `ms-vscode-remote.remote-containers` in VS Code |
| Claude Pro/Max subscription | Required for Claude Code CLI |

---

## Setup Options

### Option 1: One-Line PowerShell (Easiest)

```powershell
irm https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup.ps1 | iex
```

**Custom install path:**
```powershell
$installPath = "D:\MyProjects\AutoClaude"; irm https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup.ps1 -OutFile setup.ps1; .\setup.ps1 -InstallPath $installPath
```

### Option 2: Download Batch File

1. Download [setup-autoclaude.bat](https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup-autoclaude.bat)
2. Double-click to run
3. Follow the prompts

### Option 3: Clone and Disconnect

```powershell
# Clone this repository
git clone https://github.com/vipasane/autoclaude-VSCode-docker.git AutoClaude

# Enter the directory
cd AutoClaude

# Remove git connection (makes it your own project)
Remove-Item -Recurse -Force .git

# Open in VS Code
code .
```

### Option 4: Download ZIP

1. Click **Code** → **Download ZIP** on this page
2. Extract to a folder (e.g., `C:\AutoClaude`)
3. Open the folder in VS Code

### Option 5: Use as Template (GitHub)

1. Click **"Use this template"** button above
2. Create your own repository
3. Clone your new repository

---

## First Time Setup

After opening in VS Code:

1. **Click "Reopen in Container"** when prompted
   
   Or: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

2. **Wait for setup** (first time takes 5-10 minutes)
   - Clones Auto-Claude repository
   - Installs Node.js dependencies
   - Creates Python virtual environment
   - Starts FalkorDB

3. **Authenticate Claude Code** (see below)

4. **Start developing!**
   ```bash
   cd /workspace/auto-claude
   npm run dev
   ```

---

## Claude Code Authentication

You need a **Claude Pro or Max subscription** to use Claude Code.

### Method 1: Login Inside Container (Easiest - No Local Install Needed)

Just run this in the VS Code terminal:

```bash
claude login
```

This opens a browser window. Log in with your Anthropic account and you're done!

> **Note:** Credentials persist in a Docker volume across container restarts.

### Method 2: OAuth Token (For Automation)

If you have Claude Code installed locally:

```powershell
# On your local machine - get your OAuth token
claude setup-token

# Set as permanent environment variable
[System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_OAUTH_TOKEN", "your-token-here", "User")
```

The container automatically picks up this environment variable.

### Method 3: API Key

```bash
# Inside the container
claude config set apiKey your-api-key-here
```

### Verify Authentication

```bash
claude --version
claude "Hello, are you working?"
```

---

## Usage

### Start Development Servers

```bash
cd /workspace/auto-claude
npm run dev
```

### Claude Code CLI

```bash
# Interactive mode
claude

# With a prompt
claude "Help me create a new feature"

# Continue previous conversation
claude --continue
```

### Backend CLI (Autonomous Tasks)

```bash
cd /workspace/auto-claude/apps/backend
source .venv/bin/activate

# Create spec interactively
python spec_runner.py --interactive

# Run autonomous build
python run.py --spec 001
```

---

## Service Status Dashboard

Every time the container starts, you'll see:

```
╔═══════════════════════════════════════════════════════════════╗
║           Auto-Claude Development Environment                 ║
╠═══════════════════════════════════════════════════════════════╣
║  Service Status                                               ║
║    Repository:    ● Ready                                     ║
║    FalkorDB:      ● Running                                   ║
║    Python:        ● Python 3.12.3                             ║
║    Claude Code:   ● 2.0.76                                    ║
║    Auth:          ● Authenticated                             ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Helper Scripts

| Command | Description |
|---------|-------------|
| `bash .devcontainer/scripts/setup.sh` | Re-run full setup |
| `bash .devcontainer/scripts/update.sh` | Pull latest Auto-Claude |
| `bash .devcontainer/scripts/reset.sh` | Interactive reset menu |
| `bash .devcontainer/scripts/start.sh` | Show status dashboard |

---

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 3000 | Frontend | Electron/React dev server |
| 8000 | Backend | Python API server |
| 5173 | Vite | Hot Module Replacement |
| 6379 | FalkorDB | Memory Layer database |

---

## Troubleshooting

### Setup script didn't run automatically

```bash
bash /workspace/.devcontainer/scripts/setup.sh
```

Or: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container Without Cache"

### Claude Code authentication fails

```bash
rm -rf ~/.claude
claude login
```

### FalkorDB not responding

```bash
docker restart auto-claude-falkordb
```

### Full reset

```powershell
# Remove all volumes (PowerShell)
docker volume rm autoclaude-node-modules-root autoclaude-node-modules-frontend autoclaude-falkordb-data autoclaude-claude-config

# Then in VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container Without Cache"
```

---

## Customization

### Change Auto-Claude Branch

Edit `.devcontainer/scripts/setup.sh`:

```bash
AUTO_CLAUDE_BRANCH="main"  # Change from "develop"
```

### Add VS Code Extensions

Edit `.devcontainer/devcontainer.json` and add to the extensions array.

---

## Links

- [Auto-Claude Repository](https://github.com/AndyMik90/Auto-Claude)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Claude Code Docs](https://docs.anthropic.com/claude-code)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## License

This devcontainer setup is provided as-is. Auto-Claude itself is licensed under AGPL-3.0.
