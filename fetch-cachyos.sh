#!/bin/bash

set -e

REPO_API="https://api.github.com/repos/CachyOS/linux-cachyos/contents"
RAW_BASE="https://raw.githubusercontent.com/CachyOS/linux-cachyos/master"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST="$SCRIPT_DIR/original"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "Fetching CachyOS kernel variants from GitHub..."
echo ""

# Get all linux-cachyos* folders from the repo root
mapfile -t FOLDERS < <(curl -fsSL "$REPO_API/" | grep '"name".*linux-cachyos' | sed 's/.*"name": "\(.*\)".*/\1/')

if [[ ${#FOLDERS[@]} -eq 0 ]]; then
    echo -e "${RED}✗ Failed to fetch folder list from GitHub${NC}"
    exit 1
fi

mkdir -p "$DEST"

for folder in "${FOLDERS[@]}"; do
    echo -e "  ${YELLOW}→${NC} $folder"
    mkdir -p "$DEST/$folder"

    for file in PKGBUILD config; do
        url="$RAW_BASE/$folder/$file"
        if curl -fsSL "$url" -o "$DEST/$folder/$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} $file"
        else
            echo -e "    ${RED}✗${NC} $file (not found)"
            rm -f "$DEST/$folder/$file"
        fi
    done
    echo ""
done

echo -e "${GREEN}Done.${NC} Files saved to: $DEST"
