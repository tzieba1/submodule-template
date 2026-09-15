# Scripts

This directory contains automation scripts for the submodule template.

## Quick Reference

| Script | Purpose | Common Usage |
|--------|---------|--------------|
| [`version.sh`](#versionsh) | Version management | `./scripts/version.sh bump patch` |
| [`template-sync.sh`](#template-syncsh) | Pull template updates | `./scripts/template-sync.sh check` |

---

## version.sh

**Purpose**: Manage semantic versions.

### Commands

```bash
# Show current version
./scripts/version.sh current

# Bump version (updates VERSION file)
./scripts/version.sh bump patch    # 1.0.0 → 1.0.1
./scripts/version.sh bump minor    # 1.0.0 → 1.1.0
./scripts/version.sh bump major    # 1.0.0 → 2.0.0

# Create a release tag
./scripts/version.sh release
```

### When to Use

| Scenario | Command |
|----------|---------|
| Bug fix | `bump patch` |
| New feature | `bump minor` |
| Breaking change | `bump major` |
| Publishing release | `release` |

### Related Docs
- [../docs/VERSIONING.md](../docs/VERSIONING.md) - Versioning strategy guide

---

## template-sync.sh

**Purpose**: Keep this instance in sync with template updates.

### Commands

```bash
# Check if updates are available
./scripts/template-sync.sh check

# Show differences from template
./scripts/template-sync.sh diff

# Apply updates (with preview)
./scripts/template-sync.sh apply --dry-run

# Apply updates for real
./scripts/template-sync.sh apply
```

### Prerequisites

The `.template-meta.json` must have a `source` field:

```json
{
  "template": {
    "source": "git@github.com:yourorg/submodule-template.git",
    ...
  }
}
```

### What Gets Synced

Scripts, hooks, and workflows are synced. Instance-specific files are never touched:
- `.template-meta.json` (instance section)
- `VERSION`
- `README.md`
- Your application code

### When to Use

- Periodically (monthly) to get improvements
- When you see template version warnings
- After the template team announces updates

---

## Adding New Scripts

When adding a new script:

1. Add the script to this directory
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add a section to this README
4. Update [../ARCHITECTURE.md](../ARCHITECTURE.md)
