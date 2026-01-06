@echo off
REM ============================================================================
REM Auto-Claude Dev Container - Quick Setup Script for Windows
REM Downloads, extracts, and opens the project in VS Code
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo  ╔═══════════════════════════════════════════════════════════════╗
echo  ║     Auto-Claude Dev Container - Quick Setup                   ║
echo  ╚═══════════════════════════════════════════════════════════════╝
echo.

REM Configuration
set "REPO_URL=https://github.com/vipasane/autoclaude-VSCode-docker/archive/refs/heads/main.zip"
set "INSTALL_DIR=%USERPROFILE%\AutoClaude"
set "TEMP_ZIP=%TEMP%\autoclaude-setup.zip"

REM Check for required tools
echo [1/5] Checking prerequisites...

where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Docker is not installed or not in PATH
    echo  Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    echo.
    pause
    exit /b 1
)

where code >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: VS Code is not installed or not in PATH
    echo  Please install VS Code from: https://code.visualstudio.com/
    echo.
    pause
    exit /b 1
)

echo       Docker: OK
echo       VS Code: OK

REM Ask for installation directory
echo.
echo [2/5] Choose installation directory
echo       Default: %INSTALL_DIR%
echo.
set /p "CUSTOM_DIR=Press Enter for default, or type a new path: "

if not "%CUSTOM_DIR%"=="" (
    set "INSTALL_DIR=%CUSTOM_DIR%"
)

REM Check if directory exists
if exist "%INSTALL_DIR%" (
    echo.
    echo  WARNING: Directory already exists: %INSTALL_DIR%
    set /p "OVERWRITE=Overwrite? (y/n): "
    if /i not "!OVERWRITE!"=="y" (
        echo  Aborted.
        pause
        exit /b 0
    )
    rmdir /s /q "%INSTALL_DIR%" 2>nul
)

REM Download repository
echo.
echo [3/5] Downloading Auto-Claude Dev Container...

curl -L -o "%TEMP_ZIP%" "%REPO_URL%" 2>nul
if %errorlevel% neq 0 (
    echo  ERROR: Failed to download. Check your internet connection.
    pause
    exit /b 1
)

echo       Downloaded successfully

REM Extract
echo.
echo [4/5] Extracting files...

REM Create install directory
mkdir "%INSTALL_DIR%" 2>nul

REM Extract using PowerShell (built into Windows)
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP%\autoclaude-extract' -Force"

REM Move contents (GitHub adds a folder with branch name)
for /d %%i in ("%TEMP%\autoclaude-extract\*") do (
    xcopy /s /e /h /y "%%i\*" "%INSTALL_DIR%\" >nul
)

REM Cleanup
del "%TEMP_ZIP%" 2>nul
rmdir /s /q "%TEMP%\autoclaude-extract" 2>nul

echo       Extracted to: %INSTALL_DIR%

REM Open in VS Code
echo.
echo [5/5] Opening in VS Code...
echo.

cd /d "%INSTALL_DIR%"
code .

echo  ╔═══════════════════════════════════════════════════════════════╗
echo  ║                     Setup Complete!                           ║
echo  ╠═══════════════════════════════════════════════════════════════╣
echo  ║                                                               ║
echo  ║  VS Code should now open. When prompted:                      ║
echo  ║                                                               ║
echo  ║    1. Click "Reopen in Container"                             ║
echo  ║    2. Wait for setup to complete (5-10 minutes first time)    ║
echo  ║    3. Run: claude login                                       ║
echo  ║    4. Run: cd /workspace/auto-claude ^&^& npm run dev             ║
echo  ║                                                               ║
echo  ╚═══════════════════════════════════════════════════════════════╝
echo.

pause
