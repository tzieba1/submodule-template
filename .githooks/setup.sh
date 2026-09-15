#!/usr/bin/env bash
#
# Setup script for submodule-template based repositories
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Setting up submodule repository...${NC}"

# Configure git hooks
git config core.hooksPath .githooks
echo -e "${GREEN}✓${NC} Git hooks configured"

# Ensure VERSION file exists
if [[ ! -f "$REPO_ROOT/VERSION" ]]; then
    echo "0.1.0" > "$REPO_ROOT/VERSION"
    echo -e "${GREEN}✓${NC} VERSION file created (0.1.0)"
fi

# Ensure template meta exists
if [[ ! -f "$REPO_ROOT/.template-meta.json" ]]; then
    cat > "$REPO_ROOT/.template-meta.json" << 'METAEOF'
{
  "template": {
    "name": "submodule-template",
    "version": "1.0.0"
  },
  "instance": {
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "name": "$(basename $REPO_ROOT)"
  }
}
METAEOF
    echo -e "${GREEN}✓${NC} Template metadata created"
fi

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Available commands:"
echo "  ./scripts/version.sh current   - Show version"
echo "  ./scripts/version.sh bump      - Bump version"
echo "  ./scripts/version.sh release   - Create release"
