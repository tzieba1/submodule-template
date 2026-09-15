# Version Management Guide

This document explains how versioning works in submodule repositories.

## Quick Reference

| Command | What it does |
|---------|--------------|
| `./scripts/version.sh current` | Show current version |
| `./scripts/version.sh bump patch` | 1.0.0 → 1.0.1 |
| `./scripts/version.sh bump minor` | 1.0.0 → 1.1.0 |
| `./scripts/version.sh bump major` | 1.0.0 → 2.0.0 |
| `./scripts/version.sh release` | Create version tag |

## The VERSION File

The `VERSION` file contains your semantic version:

```
1.2.3
```

- **Major (1)**: Breaking changes
- **Minor (2)**: New features, backwards compatible
- **Patch (3)**: Bug fixes

## Release Workflow

### 1. Make Your Changes

```bash
# Work on your feature or fix
git commit -m "feat: add new endpoint"
```

### 2. Bump Version

```bash
# For a new feature
./scripts/version.sh bump minor

# For a bug fix
./scripts/version.sh bump patch

# For breaking changes
./scripts/version.sh bump major
```

### 3. Commit the Version Bump

```bash
git add VERSION
git commit -m "chore: bump version to 1.3.0"
```

### 4. Create Release Tag

```bash
./scripts/version.sh release
# Creates tag: v1.3.0
```

### 5. Push

```bash
git push origin main --tags
```

### 6. Orchestrator Updates

The orchestrator can now update to your new version:

```bash
# In orchestrator repo
git submodule update --remote services/your-submodule
./scripts/version.sh lock
git commit -m "chore: update your-submodule to v1.3.0"
```

## When to Bump What

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix | `patch` | Fix null pointer error |
| New feature | `minor` | Add new API endpoint |
| Performance improvement | `patch` | Optimize query |
| Dependency update (non-breaking) | `patch` | Update library |
| Breaking API change | `major` | Change endpoint signature |
| Breaking schema change | `major` | Alter database schema |

## Template Compatibility

The `.template-meta.json` declares compatibility with orchestrator versions:

```json
{
  "compatibility": {
    "orchestrator-template": {
      "minimum": "1.0.0",
      "maximum": "1.x.x"
    }
  }
}
```

The orchestrator can check if your version is compatible.

## Template Updates

Keep your scripts in sync with template improvements:

```bash
./scripts/template-sync.sh check   # See if updates exist
./scripts/template-sync.sh apply   # Apply updates
```

## Troubleshooting

### "Tag already exists"

You're trying to create a tag that exists:

```bash
# Check existing tags
git tag -l "v*"

# Bump version first
./scripts/version.sh bump patch
```

### Orchestrator shows old version

The orchestrator needs to update its submodule pointer:

```bash
# In orchestrator
git submodule update --remote services/your-submodule
./scripts/version.sh lock
```
