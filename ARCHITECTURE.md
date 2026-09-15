# Architecture

This document explains how the submodule template works.

## Overview

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          SUBMODULE REPOSITORY                                │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│  ┌─────────────┐  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │   VERSION   │  │  .template-meta.json│  │  Your Application Code      │   │
│  │    file     │  │                     │  │                             │   │
│  │             │  │  Template version & │  │  src/, lib/, etc.           │   │
│  │ "1.2.3"     │  │  compatibility info │  │                             │   │
│  └─────────────┘  └─────────────────────┘  └─────────────────────────────┘   │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐ │
│  │                              scripts/                                   │ │
│  │  ┌──────────────────────────┐  ┌────────────────────────────────────┐   │ │
│  │  │      version.sh          │  │      template-sync.sh              │   │ │
│  │  │                          │  │                                    │   │ │
│  │  │  bump/current/release    │  │  Check and apply template updates  │   │ │
│  │  └──────────────────────────┘  └────────────────────────────────────┘   │ │
│  └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                              │
│  ┌──────────────────────────────┐  ┌───────────────────────────────────────┐ │
│  │         .githooks/           │  │        .github/workflows/             │ │
│  │                              │  │                                       │ │
│  │  pre-commit  →  Checks       │  │  ci.yml  →  Build + test              │ │
│  │  commit-msg  →  Format       │  │                                       │ │
│  │                              │  │                                       │ │
│  └──────────────────────────────┘  └───────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Component Map

| Component | Purpose | Documentation | When to Update Docs |
|-----------|---------|---------------|---------------------|
| `VERSION` | Semantic version number | [docs/VERSIONING.md](docs/VERSIONING.md) | When versioning strategy changes |
| `.template-meta.json` | Template tracking | This file | When metadata schema changes |
| `scripts/*` | Automation scripts | [scripts/README.md](scripts/README.md) | When adding/modifying scripts |
| `.githooks/*` | Git hooks | [.githooks/README.md](.githooks/README.md) | When changing hook behavior |
| `.github/workflows/*` | CI/CD pipelines | [.github/workflows/README.md](.github/workflows/README.md) | When changing CI behavior |

## Relationship to Orchestrator

```
orchestrator-template
        │
        │ manages
        ▼
┌─────────────────────────────────┐
│  orchestrator instance          │
│  (my-orchestrator)              │
│                                 │
│  ├── services/                  │
│  │   ├── backend/  ◄────────────┼──── This is a submodule instance
│  │   └── frontend/ ◄────────────┼──── This is a submodule instance
│  └── .submodule-versions.lock   │
└─────────────────────────────────┘
        │
        │ points to
        ▼
submodule-template (this)
        │
        │ creates instances
        ▼
my-backend, my-frontend, ...
```

## Key Concepts

### Template Compatibility

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

This allows orchestrators to verify they're using compatible submodules.

### Version File

The `VERSION` file is the single source of truth for this repo's version:

```
1.2.3
```

Orchestrators read this to display submodule versions and track updates.

### Template Sync

When the submodule-template is updated, instances can sync:

```bash
./scripts/template-sync.sh check   # See if updates available
./scripts/template-sync.sh apply   # Apply updates
```

## Data Flow

### Version Release

```
Developer runs: ./scripts/version.sh bump patch

VERSION file         Git
    │                 │
    ▼                 │
1.0.0 → 1.0.1        │
    │                 │
    └─────────────────┤
                      │
              Developer commits
                      │
                      ▼
              ./scripts/version.sh release
                      │
                      ▼
               Git tag: v1.0.1
                      │
                      ▼
               git push --tags
                      │
                      ▼
              Orchestrator can now update
              to this version
```

## Design Principles

1. **Minimal footprint**: Only version management and hooks, not application logic
2. **Orchestrator-compatible**: Works seamlessly as a submodule
3. **Self-versioned**: VERSION file is the source of truth
4. **Evolvable**: template-sync.sh enables updates without breaking
