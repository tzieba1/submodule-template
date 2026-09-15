#!/usr/bin/env bash
#
# template-sync.sh - Check for and apply template updates
#
# This script compares the current instance against its source template
# and helps apply updates while preserving local customizations.
#
# Usage:
#   ./scripts/template-sync.sh check              # Check for updates
#   ./scripts/template-sync.sh diff               # Show differences
#   ./scripts/template-sync.sh apply [--dry-run]  # Apply updates
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
META_FILE="$REPO_ROOT/.template-meta.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Files that should sync from template (scripts, hooks, workflows)
SYNC_PATHS=(
    "scripts/version.sh"
    "scripts/template-sync.sh"
    ".githooks/pre-commit"
    ".githooks/commit-msg"
    ".githooks/setup.sh"
    ".github/workflows/ci.yml"
)

# Files that should NEVER sync (instance-specific)
NEVER_SYNC=(
    ".template-meta.json"
    "VERSION"
    "README.md"
)

get_template_info() {
    if [[ ! -f "$META_FILE" ]]; then
        echo -e "${RED}Error:${NC} No .template-meta.json found"
        exit 1
    fi

    TEMPLATE_NAME=$(jq -r '.template.name' "$META_FILE")
    TEMPLATE_VERSION=$(jq -r '.template.version' "$META_FILE")
    INSTANCE_NAME=$(jq -r '.instance.name // "unknown"' "$META_FILE")
}

check_for_updates() {
    get_template_info

    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Template Sync Check                    ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Instance:     ${GREEN}$INSTANCE_NAME${NC}"
    echo -e "Template:     ${GREEN}$TEMPLATE_NAME${NC} v$TEMPLATE_VERSION"
    echo ""

    local template_source=$(jq -r '.template.source // empty' "$META_FILE")

    if [[ -z "$template_source" ]]; then
        echo -e "${YELLOW}Note:${NC} No template source configured in .template-meta.json"
        echo ""
        echo "To enable automatic sync, add to .template-meta.json:"
        echo '  "template": {'
        echo '    "source": "git@github.com:yourorg/submodule-template.git",'
        echo '    ...'
        echo '  }'
        return 0
    fi

    echo -e "Source:       ${GREEN}$template_source${NC}"
    echo ""

    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    echo -e "${BLUE}Fetching latest template...${NC}"
    if ! git clone --quiet --depth 1 "$template_source" "$temp_dir" 2>/dev/null; then
        echo -e "${RED}Error:${NC} Could not fetch template from $template_source"
        return 1
    fi

    local template_version=$(cat "$temp_dir/VERSION" 2>/dev/null || echo "unknown")
    echo -e "Latest:       ${GREEN}v$template_version${NC}"
    echo ""

    if [[ "$template_version" == "$TEMPLATE_VERSION" ]]; then
        echo -e "${GREEN}✓ Instance is up to date with template${NC}"
    else
        echo -e "${YELLOW}⚠ Template has been updated${NC}"
        echo -e "  Current: v$TEMPLATE_VERSION → Available: v$template_version"
        echo ""
        echo "Run './scripts/template-sync.sh diff' to see changes"
        echo "Run './scripts/template-sync.sh apply' to update"
    fi
}

show_diff() {
    get_template_info

    local template_source=$(jq -r '.template.source // empty' "$META_FILE")

    if [[ -z "$template_source" ]]; then
        echo -e "${RED}Error:${NC} No template source configured"
        return 1
    fi

    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    git clone --quiet --depth 1 "$template_source" "$temp_dir" 2>/dev/null

    echo -e "${BLUE}Differences from template:${NC}"
    echo ""

    local has_diff=false
    for path in "${SYNC_PATHS[@]}"; do
        if [[ -f "$temp_dir/$path" ]]; then
            if [[ -f "$REPO_ROOT/$path" ]]; then
                if ! diff -q "$REPO_ROOT/$path" "$temp_dir/$path" >/dev/null 2>&1; then
                    echo -e "${YELLOW}Modified:${NC} $path"
                    diff --color=auto -u "$REPO_ROOT/$path" "$temp_dir/$path" 2>/dev/null | head -20 || true
                    echo ""
                    has_diff=true
                fi
            else
                echo -e "${GREEN}New in template:${NC} $path"
                has_diff=true
            fi
        fi
    done

    if [[ "$has_diff" == "false" ]]; then
        echo -e "${GREEN}No differences in tracked files${NC}"
    fi
}

apply_updates() {
    local dry_run=false
    [[ "${1:-}" == "--dry-run" ]] && dry_run=true

    get_template_info

    local template_source=$(jq -r '.template.source // empty' "$META_FILE")

    if [[ -z "$template_source" ]]; then
        echo -e "${RED}Error:${NC} No template source configured"
        return 1
    fi

    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    git clone --quiet --depth 1 "$template_source" "$temp_dir" 2>/dev/null

    echo -e "${BLUE}Applying template updates${NC}"
    [[ "$dry_run" == "true" ]] && echo -e "${YELLOW}(dry-run mode)${NC}"
    echo ""

    local updated=0
    for path in "${SYNC_PATHS[@]}"; do
        if [[ -f "$temp_dir/$path" ]]; then
            local needs_update=false

            if [[ ! -f "$REPO_ROOT/$path" ]]; then
                needs_update=true
                echo -e "${GREEN}Adding:${NC} $path"
            elif ! diff -q "$REPO_ROOT/$path" "$temp_dir/$path" >/dev/null 2>&1; then
                needs_update=true
                echo -e "${YELLOW}Updating:${NC} $path"
            fi

            if [[ "$needs_update" == "true" ]]; then
                if [[ "$dry_run" == "false" ]]; then
                    mkdir -p "$(dirname "$REPO_ROOT/$path")"
                    cp "$temp_dir/$path" "$REPO_ROOT/$path"
                fi
                ((updated++))
            fi
        fi
    done

    echo ""
    if [[ $updated -eq 0 ]]; then
        echo -e "${GREEN}No updates needed${NC}"
    else
        echo -e "${GREEN}Updated $updated file(s)${NC}"

        if [[ "$dry_run" == "false" ]]; then
            local new_version=$(cat "$temp_dir/VERSION" 2>/dev/null || echo "$TEMPLATE_VERSION")
            local tmp=$(mktemp)
            jq --arg v "$new_version" '.template.version = $v' "$META_FILE" > "$tmp"
            mv "$tmp" "$META_FILE"

            echo ""
            echo -e "${BLUE}Next steps:${NC}"
            echo "  1. Review changes: git diff"
            echo "  2. Test your code still works"
            echo "  3. Commit: git add -A && git commit -m 'chore: sync with template v$new_version'"
        fi
    fi
}

usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  check              Check if template updates are available"
    echo "  diff               Show differences between instance and template"
    echo "  apply [--dry-run]  Apply template updates to this instance"
    echo ""
}

case "${1:-check}" in
    check)
        check_for_updates
        ;;
    diff)
        show_diff
        ;;
    apply)
        apply_updates "${2:-}"
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
