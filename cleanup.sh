#!/bin/bash
set -e

# Colors
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Auto-Claude Dev Container - Full Cleanup                  ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}--> Stopping containers and removing all volumes/networks...${NC}"

# Go to the script's directory to ensure docker-compose can find the file
cd "$(dirname "$0")"

docker compose down --volumes --remove-orphans

echo ""
echo -e "${BLUE}--> Docker components removed successfully.${NC}"
echo "You can now safely delete this project folder (e.g., 'rm -rf $(pwd)')"
echo ""