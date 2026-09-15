# Submodule Template

A template for repositories designed to be used as git submodules within an orchestrator.

## Quick Start

```bash
# Create repo from this template on GitHub, then:
git clone git@github.com:YOUR_ORG/your-service.git
cd your-service

# Setup hooks
./.githooks/setup.sh

# Start developing!
```

## Common Commands

```bash
# Versioning
./scripts/version.sh current          # Show current version
./scripts/version.sh bump minor       # Bump version (patch/minor/major)
./scripts/version.sh release          # Create release tag

# Maintenance
./scripts/template-sync.sh check      # Check for template updates
./scripts/template-sync.sh apply      # Apply template updates
```

## Structure

```
your-service/
├── README.md                    # You are here
├── ARCHITECTURE.md              # System design
├── VERSION                      # Semantic version (e.g., 1.2.3)
├── .template-meta.json          # Template version tracking
│
├── scripts/                     # Automation scripts
│   └── README.md                # Script reference
├── .githooks/                   # Git hooks
│   └── README.md                # Hook reference
├── .github/workflows/           # CI/CD pipelines
│   └── README.md                # Workflow reference
├── docs/                        # Detailed guides
│   └── README.md                # Documentation index
│
└── src/                         # Your application code
```

## Workflow: Making a Release

```bash
# 1. Make your changes
git add .
git commit -m "feat: add new feature"

# 2. Bump version
./scripts/version.sh bump minor

# 3. Commit and tag
git add VERSION
git commit -m "chore: bump version to 1.2.0"
./scripts/version.sh release

# 4. Push
git push origin main --tags
```

## Documentation

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design, how it fits with orchestrator |
| [docs/VERSIONING.md](docs/VERSIONING.md) | Version management guide |
| [scripts/README.md](scripts/README.md) | Scripts reference |
| [.githooks/README.md](.githooks/README.md) | Git hooks reference |
| [.github/workflows/README.md](.github/workflows/README.md) | CI/CD reference |

## Commit Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore, ci, perf, build
```

Examples:
```bash
git commit -m "feat: add user authentication"
git commit -m "fix: handle null input"
git commit -m "docs: update API documentation"
```

## Template Compatibility

This template works with `orchestrator-template`. The `.template-meta.json` declares compatibility:

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

## Adding to Orchestrator

In the orchestrator repository:

```bash
git submodule add git@github.com:YOUR_ORG/your-service.git services/your-service
git submodule update --init
./scripts/version.sh lock
git commit -m "chore: add your-service submodule"
```

## Getting Help

- Check [docs/README.md](docs/README.md) for documentation index
- See [ARCHITECTURE.md](ARCHITECTURE.md) for system understanding
- Run `./scripts/version.sh --help` for command help
