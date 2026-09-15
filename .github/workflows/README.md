# CI/CD Workflows

This directory contains GitHub Actions workflows for the submodule.

## Overview

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| [`ci.yml`](#ciyml) | Push, PR | Build and test |

## Design Philosophy

**Logic in scripts, not YAML.**

This means:
- Test locally: `./scripts/version.sh current`
- Easy platform migration
- No vendor lock-in

## ci.yml

**Triggers**: Push to main/develop, Pull requests to main

### What It Does

1. Checks out code
2. Runs your build/test commands
3. Validates version file exists

### Customizing

Add your build and test steps:

```yaml
- name: Install dependencies
  run: npm install  # or pip install, cargo build, etc.

- name: Run tests
  run: npm test     # or pytest, cargo test, etc.
```

## Local Testing

```bash
# Most CI checks can run locally
./scripts/version.sh current
npm test  # or your test command
```

## Migrating to Other Platforms

### GitLab CI

```yaml
# .gitlab-ci.yml
test:
  script:
    - npm install
    - npm test
```

### Bitbucket Pipelines

```yaml
# bitbucket-pipelines.yml
pipelines:
  default:
    - step:
        script:
          - npm install
          - npm test
```

## Related Docs

- [../../ARCHITECTURE.md](../../ARCHITECTURE.md) - System overview
- [../../scripts/README.md](../../scripts/README.md) - Scripts reference
