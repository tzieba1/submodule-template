# Git Hooks

This directory contains git hooks for the submodule template.

## Overview

| Hook | Trigger | Purpose |
|------|---------|---------|
| [`pre-commit`](#pre-commit) | Before commit | Run checks |
| [`commit-msg`](#commit-msg) | After message written | Validate format |
| [`setup.sh`](#setupsh) | Manual | Install hooks |

## Installation

```bash
./.githooks/setup.sh
```

This configures git to use `.githooks/` as the hooks directory.

## pre-commit

Runs before each commit. Add your checks here:
- Linting
- Tests
- Format validation

## commit-msg

Validates commit messages follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

### Valid Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting |
| `refactor` | Restructuring |
| `test` | Tests |
| `chore` | Maintenance |

### Examples

```bash
# Good
git commit -m "feat: add user login"
git commit -m "fix: handle null input"

# Bad (rejected)
git commit -m "updated code"
```

## setup.sh

Configures git to use these hooks:

```bash
git config core.hooksPath .githooks
```

## Bypassing Hooks

For emergencies:

```bash
git commit --no-verify -m "emergency fix"
```

## Related Docs

- [../ARCHITECTURE.md](../ARCHITECTURE.md) - System overview
