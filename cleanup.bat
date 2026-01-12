@echo off
setlocal

echo.
echo  ╔═══════════════════════════════════════════════════════════════╗
echo  ║     Auto-Claude Dev Container - Full Cleanup                  ║
echo  ╚═══════════════════════════════════════════════════════════════╝
echo.

echo [1/2] Stopping containers and removing all volumes/networks...

REM Go to the script's directory to ensure docker-compose can find the file
cd /d "%~dp0"

docker compose down --volumes --remove-orphans

echo.
echo [2/2] Docker components removed successfully.
echo You can now safely delete this project folder.
echo.
pause