# Documentation Index

This directory contains documentation for the submodule template.

## Quick Navigation

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [VERSIONING.md](VERSIONING.md) | How versioning works | Managing releases |

## Documentation Map

```
Repository Root
├── README.md                    # Entry point, quick start
├── ARCHITECTURE.md              # System design
│
├── docs/                        # Detailed guides
│   ├── README.md                # This file
│   └── VERSIONING.md            # Version management
│
├── scripts/
│   └── README.md                # Scripts reference
│
├── .githooks/
│   └── README.md                # Hooks reference
│
└── .github/workflows/
    └── README.md                # CI/CD reference
```

## Finding What You Need

| I want to... | Read |
|--------------|------|
| Understand the system | [../ARCHITECTURE.md](../ARCHITECTURE.md) |
| Bump a version | [VERSIONING.md](VERSIONING.md) |
| Use a script | [../scripts/README.md](../scripts/README.md) |
| Understand a hook | [../.githooks/README.md](../.githooks/README.md) |

## Keeping Docs Updated

When modifying the system, update:
1. The component's own README
2. ARCHITECTURE.md if interactions change
3. This index if adding new docs
