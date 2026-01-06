#Requires -Version 5.1
<#
.SYNOPSIS
    Auto-Claude Dev Container - Quick Setup Script for Windows
.DESCRIPTION
    Downloads and sets up the Auto-Claude VS Code Dev Container environment.
    Run with: irm https://raw.githubusercontent.com/vipasane/autoclaude-VSCode-docker/main/setup.ps1 | iex
.NOTES
    Requires: Docker Desktop, VS Code, Dev Containers extension
#>

[CmdletBinding()]
param(
    [string]$InstallPath = "$env:USERPROFILE\AutoClaude",
    [switch]$NoOpen,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration
$RepoUrl = "https://github.com/vipasane/autoclaude-VSCode-docker/archive/refs/heads/main.zip"
$TempZip = Join-Path $env:TEMP "autoclaude-setup.zip"
$TempExtract = Join-Path $env:TEMP "autoclaude-extract"

# Colors
function Write-Header {
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║     Auto-Claude Dev Container - Quick Setup                   ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host "[$Step] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "      ✓ " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Error-Message {
    param([string]$Message)
    Write-Host "      ✗ " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

# Main setup
function Install-AutoClaude {
    Write-Header

    # Step 1: Check prerequisites
    Write-Step "1/5" "Checking prerequisites..."

    # Check Docker
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        Write-Error-Message "Docker is not installed or not in PATH"
        Write-Host ""
        Write-Host "  Please install Docker Desktop from:" -ForegroundColor Yellow
        Write-Host "  https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
        Write-Host ""
        return $false
    }
    Write-Success "Docker found"

    # Check VS Code
    $code = Get-Command code -ErrorAction SilentlyContinue
    if (-not $code) {
        Write-Error-Message "VS Code is not installed or not in PATH"
        Write-Host ""
        Write-Host "  Please install VS Code from:" -ForegroundColor Yellow
        Write-Host "  https://code.visualstudio.com/" -ForegroundColor Cyan
        Write-Host ""
        return $false
    }
    Write-Success "VS Code found"

    # Check if Docker is running
    try {
        $null = docker info 2>&1
        Write-Success "Docker is running"
    } catch {
        Write-Error-Message "Docker is not running. Please start Docker Desktop."
        return $false
    }

    # Step 2: Determine install path
    Write-Host ""
    Write-Step "2/5" "Setting up installation directory..."
    
    if (Test-Path $InstallPath) {
        if (-not $Force) {
            Write-Host "      Directory already exists: " -NoNewline
            Write-Host $InstallPath -ForegroundColor Yellow
            $confirm = Read-Host "      Overwrite? (y/n)"
            if ($confirm -ne 'y' -and $confirm -ne 'Y') {
                Write-Host "      Aborted." -ForegroundColor Yellow
                return $false
            }
        }
        Remove-Item -Recurse -Force $InstallPath
    }
    
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Success "Install path: $InstallPath"

    # Step 3: Download
    Write-Host ""
    Write-Step "3/5" "Downloading repository..."
    
    try {
        # Remove old temp files
        if (Test-Path $TempZip) { Remove-Item $TempZip -Force }
        if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force }

        # Download
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $RepoUrl -OutFile $TempZip -UseBasicParsing
        Write-Success "Downloaded successfully"
    } catch {
        Write-Error-Message "Failed to download: $_"
        return $false
    }

    # Step 4: Extract
    Write-Host ""
    Write-Step "4/5" "Extracting files..."
    
    try {
        Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force
        
        # GitHub creates a subfolder with branch name, move contents up
        $extractedFolder = Get-ChildItem -Path $TempExtract -Directory | Select-Object -First 1
        Get-ChildItem -Path $extractedFolder.FullName | Move-Item -Destination $InstallPath -Force
        
        # Cleanup
        Remove-Item $TempZip -Force
        Remove-Item $TempExtract -Recurse -Force
        
        Write-Success "Extracted to: $InstallPath"
    } catch {
        Write-Error-Message "Failed to extract: $_"
        return $false
    }

    # Step 5: Open in VS Code
    Write-Host ""
    Write-Step "5/5" "Opening in VS Code..."
    
    if (-not $NoOpen) {
        Set-Location $InstallPath
        code .
        Write-Success "VS Code launched"
    } else {
        Write-Success "Skipped (use -NoOpen)"
    }

    # Done!
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║                     Setup Complete!                           ║" -ForegroundColor Green
    Write-Host "  ╠═══════════════════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host "  ║                                                               ║" -ForegroundColor Green
    Write-Host "  ║  " -ForegroundColor Green -NoNewline
    Write-Host "VS Code should now open. When prompted:" -NoNewline
    Write-Host "                      ║" -ForegroundColor Green
    Write-Host "  ║                                                               ║" -ForegroundColor Green
    Write-Host "  ║  " -ForegroundColor Green -NoNewline
    Write-Host "  1. Click " -NoNewline
    Write-Host '"Reopen in Container"' -ForegroundColor Yellow -NoNewline
    Write-Host "                             ║" -ForegroundColor Green
    Write-Host "  ║  " -ForegroundColor Green -NoNewline
    Write-Host "  2. Wait for setup (5-10 min first time)" -NoNewline
    Write-Host "                   ║" -ForegroundColor Green
    Write-Host "  ║  " -ForegroundColor Green -NoNewline
    Write-Host "  3. Run: " -NoNewline
    Write-Host "claude login" -ForegroundColor Cyan -NoNewline
    Write-Host "                                      ║" -ForegroundColor Green
    Write-Host "  ║  " -ForegroundColor Green -NoNewline
    Write-Host "  4. Run: " -NoNewline
    Write-Host "cd /workspace/auto-claude && npm run dev" -ForegroundColor Cyan -NoNewline
    Write-Host "    ║" -ForegroundColor Green
    Write-Host "  ║                                                               ║" -ForegroundColor Green
    Write-Host "  ╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "  Install location: " -NoNewline
    Write-Host $InstallPath -ForegroundColor Cyan
    Write-Host ""

    return $true
}

# Run
Install-AutoClaude
