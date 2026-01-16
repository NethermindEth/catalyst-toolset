# Catalyst Toolset

A collection of tools and Docker images for running Taiko network components and related infrastructure, maintained by Nethermind.

## 📦 Components

This repository includes the following components:

### Submodules
- **[taiko-mono](https://github.com/taikoxyz/taiko-mono)** - Taiko monorepo containing:
  - `packages/protocol` - Taiko protocol smart contracts
  - `packages/taiko-client` - Taiko client implementation
- **[taiko-geth](https://github.com/taikoxyz/taiko-geth)** - Taiko's fork of Go Ethereum
- **[web3signer](https://github.com/Consensys/web3signer)** - Ethereum signing service

### Native Components
- **p2p-bootnode** - Rust-based P2P bootnode for network discovery

## 🚀 Quick Start

### Clone the Repository

```bash
# Fast clone (recommended) - shallow submodules
git clone --recurse-submodules --shallow-submodules --depth 1 https://github.com/NethermindEth/catalyst-toolset.git

# Or standard clone with full history
git clone --recurse-submodules https://github.com/NethermindEth/catalyst-toolset.git

# If you already cloned without submodules
git submodule update --init --recursive
```

### Clone Only What You Need

```bash
# Clone the repo without submodules
git clone https://github.com/NethermindEth/catalyst-toolset.git
cd catalyst-toolset

# Initialize only specific submodules
git submodule update --init taiko-geth
git submodule update --init taiko-mono
```

## 🐳 Docker Images

The following Docker images are automatically built and published to Docker Hub:

| Component | Image | Latest Tag |
|-----------|-------|------------|
| Taiko Client | `nethermind/catalyst-taiko-client` | `latest` |
| Taiko Protocol | `nethermind/catalyst-taiko-protocol` | `latest` |
| Taiko Geth | `nethermind/catalyst-taiko-geth` | `latest` |
| P2P Bootnode | `nethermind/catalyst-p2p-bootnode` | `latest` |

## 🔧 GitHub Actions Workflows

All components can be built using GitHub Actions workflows with flexible version control.

### Available Workflows

#### 1. Taiko Client Build
**File:** `.github/workflows/taiko-client_docker_build.yml`

Build the Taiko client from any version of the taiko-mono repository.

**Manual Trigger:**
1. Go to **Actions** → **Catalyst Taiko Client - Docker build and push**
2. Click **Run workflow**
3. Enter `taiko_version`:
   - Branch name (e.g., `main`)
   - Tag (e.g., `v1.2.3`)
   - Commit hash (e.g., `c459c0d`)
4. Click **Run workflow**

**Example versions:**
```
main           # Latest main branch
v1.0.0         # Specific release tag
c459c0d        # Specific commit
```

#### 2. Taiko Protocol Build
**File:** `.github/workflows/taiko-protocol_docker_build.yml`

Build the Taiko protocol smart contracts from any version of the taiko-mono repository.

**Manual Trigger:**
1. Go to **Actions** → **Catalyst Taiko Protocol - Docker build and push**
2. Click **Run workflow**
3. Enter `taiko_version` (same options as Client)
4. Click **Run workflow**

#### 3. Taiko Geth Build
**File:** `.github/workflows/taiko-geth_docker_build.yml`

Build Taiko Geth from any version of the taiko-geth repository.

**Manual Trigger:**
1. Go to **Actions** → **Catalyst Taiko Geth - Docker build and push**
2. Click **Run workflow**
3. Enter `geth_version`:
   - Branch name (e.g., `taiko`)
   - Tag (e.g., `v1.0.0`)
   - Commit hash
4. Click **Run workflow**

**Default version:** `taiko` (default branch)

#### 4. P2P Bootnode Build
**File:** `.github/workflows/p2p-bootnode_docker_build.yml`

Build the P2P bootnode from the native code in this repository.

**Triggers:**
- Push to `master` branch
- Tag matching `catalyst-p2p-bootnode-v*`
- Manual trigger via Actions

#### 5. Submodule Auto-Update
**File:** `.github/workflows/update-submodules.yml`

Automatically checks for updates to submodules and creates pull requests.

**Schedule:** Runs daily at 2 AM UTC

**Manual Trigger:**
1. Go to **Actions** → **Update Submodules**
2. Click **Run workflow**

This workflow will create a PR if any submodules have updates available.

### Building Multiple Version Combinations

You can build different versions of each component independently:

**Example Scenario:**
```bash
# Build Protocol from v1.2.0
Workflow: Taiko Protocol
Input: taiko_version = v1.2.0

# Build Client from latest main
Workflow: Taiko Client
Input: taiko_version = main

# Build Geth from specific commit
Workflow: Taiko Geth
Input: geth_version = abc123def
```

This allows testing of different component version combinations without modifying the repository.

## 🛠️ Local Development

### Building Docker Images Locally

#### Taiko Client
```bash
cd taiko-mono/packages/taiko-client
docker build -t catalyst-taiko-client .
```

#### Taiko Protocol
```bash
cd taiko-mono/packages/protocol
docker build -t catalyst-taiko-protocol .
```

#### Taiko Geth
```bash
cd taiko-geth
docker build -t catalyst-taiko-geth .
```

#### P2P Bootnode
```bash
cd p2p-bootnode
docker build -t catalyst-p2p-bootnode .
```

### Updating Submodules

```bash
# Update all submodules to latest from tracked branches
git submodule update --remote --recursive

# Update specific submodule
git submodule update --remote taiko-mono

# Checkout specific version in submodule
cd taiko-mono
git fetch origin
git checkout v1.2.3
cd ..
git add taiko-mono
git commit -m "Update taiko-mono to v1.2.3"
```

## 📋 Architecture

```
catalyst-toolset/
├── .github/workflows/          # CI/CD workflows
│   ├── taiko-client_docker_build.yml
│   ├── taiko-protocol_docker_build.yml
│   ├── taiko-geth_docker_build.yml
│   ├── p2p-bootnode_docker_build.yml
│   └── update-submodules.yml
├── p2p-bootnode/               # Native Rust bootnode
├── taiko-mono/                 # Submodule: Taiko monorepo
│   └── packages/
│       ├── protocol/           # Smart contracts
│       └── taiko-client/       # Client implementation
├── taiko-geth/                 # Submodule: Taiko Geth
└── web3signer/                 # Submodule: Web3Signer
```

## 🔄 Workflow Features

### Multi-Architecture Support
All Docker builds support both architectures:
- `linux/amd64`
- `linux/arm64`

### Automatic Tagging
Images are automatically tagged with:
- `latest` - Most recent build
- `<branch-name>` - Branch-specific builds
- `<tag-name>` - Release tags
- `sha-<commit>` - Git commit SHA

### Version Flexibility
- **Default behavior:** Builds use the pinned submodule commits
- **Manual builds:** Override with any branch, tag, or commit
- **CI builds:** Can test any version combination without code changes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

Each component maintains its own license. See the respective submodule directories for details.

## 🔗 Links

- [Taiko Official Documentation](https://docs.taiko.xyz/)
- [Nethermind](https://nethermind.io/)
- [Docker Hub - Nethermind](https://hub.docker.com/u/nethermind)

## ⚡ Performance Tips

### Fast Clone
```bash
# Minimal clone for CI/development
git clone --depth 1 --recurse-submodules --shallow-submodules \
  https://github.com/NethermindEth/catalyst-toolset.git
```

### Parallel Submodule Updates
```bash
git submodule update --init --recursive --jobs 4
```

### Selective Component Builds
Only initialize the submodules you need to reduce clone time and disk usage.


---

**Maintained by:** [Nethermind](https://nethermind.io/)
