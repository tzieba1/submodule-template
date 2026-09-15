#!/usr/bin/env bash
#
# version.sh - Semantic versioning management for submodule repos
#
# Usage:
#   ./scripts/version.sh current          # Show current version
#   ./scripts/version.sh bump patch       # 1.0.0 → 1.0.1
#   ./scripts/version.sh bump minor       # 1.0.0 → 1.1.0
#   ./scripts/version.sh bump major       # 1.0.0 → 2.0.0
#   ./scripts/version.sh tag              # Create git tag for current version
#   ./scripts/version.sh release          # Bump, tag, and push
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$REPO_ROOT/VERSION"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

get_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE" | tr -d '[:space:]'
    else
        echo "0.0.0"
    fi
}

set_version() {
    echo "$1" > "$VERSION_FILE"
    echo -e "${GREEN}Version set to $1${NC}"
}

parse_version() {
    local version="$1"
    echo "$version" | sed 's/^v//' | tr '.' ' '
}

bump_version() {
    local current=$(get_version)
    local part="$1"
    
    read major minor patch <<< $(parse_version "$current")
    
    case "$part" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}Invalid part: $part (use major, minor, or patch)${NC}"
            exit 1
            ;;
    esac
    
    local new_version="${major}.${minor}.${patch}"
    set_version "$new_version"
    echo "$new_version"
}

create_tag() {
    local version=$(get_version)
    local tag="v${version}"
    
    if git rev-parse "$tag" >/dev/null 2>&1; then
        echo -e "${YELLOW}Tag $tag already exists${NC}"
        return 1
    fi
    
    git add VERSION
    git commit -m "chore: release v${version}" --allow-empty
    git tag -a "$tag" -m "Release ${version}"
    
    echo -e "${GREEN}Created tag: $tag${NC}"
}

release() {
    local part="${1:-patch}"
    
    echo -e "${BLUE}Creating release...${NC}"
    
    # Ensure clean working directory
    if ! git diff --quiet; then
        echo -e "${RED}Working directory not clean. Commit or stash changes first.${NC}"
        exit 1
    fi
    
    # Bump version
    local new_version=$(bump_version "$part")
    
    # Create tag
    create_tag
    
    # Push
    echo -e "${BLUE}Pushing to origin...${NC}"
    git push origin main --tags
    
    echo -e "${GREEN}Released v${new_version}${NC}"
}

# Main
case "${1:-current}" in
    current)
        echo "v$(get_version)"
        ;;
    bump)
        bump_version "${2:-patch}"
        ;;
    tag)
        create_tag
        ;;
    release)
        release "${2:-patch}"
        ;;
    *)
        echo "Usage: $0 {current|bump|tag|release} [major|minor|patch]"
        exit 1
        ;;
esac
