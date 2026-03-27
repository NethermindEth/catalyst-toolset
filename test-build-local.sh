#!/bin/bash

# Test script to build Docker images locally before pushing to CI
# Usage: ./test-build-local.sh [client|protocol|blobindexer|geth] [OPTIONS]
#
# Options:
#   --custom-script <path>     Path to custom build script
#   --custom-commands <cmds>   Inline commands to run before build
#   --custom-config <path>     Path to custom JSON config
#   --custom-patch <path>      Path to patch file

set -e

COMPONENT=${1:-client}
shift || true

# Parse optional customization arguments
CUSTOM_BUILD_ARGS=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --custom-script)
            CUSTOM_BUILD_ARGS="$CUSTOM_BUILD_ARGS --build-arg CUSTOM_SCRIPT=$(basename "$2")"
            shift 2
            ;;
        --custom-commands)
            CUSTOM_BUILD_ARGS="$CUSTOM_BUILD_ARGS --build-arg CUSTOM_COMMANDS=\"$2\""
            shift 2
            ;;
        --custom-config)
            CUSTOM_BUILD_ARGS="$CUSTOM_BUILD_ARGS --build-arg CUSTOM_CONFIG=$(basename "$2")"
            shift 2
            ;;
        --custom-patch)
            CUSTOM_BUILD_ARGS="$CUSTOM_BUILD_ARGS --build-arg CUSTOM_PATCH=$(basename "$2")"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            shift
            ;;
    esac
done

echo "🔧 Testing build for: $COMPONENT"

# Initialize submodule based on component
if [ "$COMPONENT" = "geth" ]; then
    SUBMODULE="taiko-geth"
    VERSION="taiko"
else
    SUBMODULE="taiko-mono"
    VERSION="main"
fi

echo "📦 Initializing submodule: $SUBMODULE"
git submodule update --init "$SUBMODULE"

# Checkout specific version (you can override this)
cd "$SUBMODULE"
echo "🔄 Checking out version: $VERSION"
git fetch origin "$VERSION" || git fetch origin
git checkout "$VERSION"
COMMIT_SHA=$(git rev-parse HEAD)
echo "✅ Current commit: $COMMIT_SHA"

# Return to root
cd ..

# Fix git metadata
echo "🔧 Fixing git metadata..."
if [ -f "$SUBMODULE/.git" ]; then
    cd "$SUBMODULE"
    GIT_DIR=$(cat .git | sed 's/gitdir: //')
    echo "   Git dir path from submodule: $GIT_DIR"
    
    # Remove the pointer file
    rm .git
    
    # GIT_DIR is relative path like ../.git/modules/taiko-mono
    # We need to resolve it properly
    if [ -d "$GIT_DIR" ]; then
        cp -r "$GIT_DIR" .git
        echo "   ✅ Git metadata copied from $GIT_DIR"
        
        # Fix the worktree path in the git config
        # The original config points to ../../../submodule (relative from .git/modules/)
        # We need to change it to point to the current directory
        sed -i.bak 's|worktree = .*|worktree = .|g' .git/config
        rm -f .git/config.bak
        echo "   ✅ Git config updated (worktree path fixed)"
    else
        echo "   ❌ Git directory not found at: $GIT_DIR"
        exit 1
    fi
    
    # Verify git works
    if git status > /dev/null 2>&1; then
        echo "   ✅ Git commands working"
    else
        echo "   ⚠️  Warning: Git commands may not work"
    fi
    
    cd ..
fi

# Build based on component
case "$COMPONENT" in
    client)
        echo "🐳 Building Taiko Client..."
        # shellcheck disable=SC2086
        docker build \
            --build-arg GIT_VERSION="$COMMIT_SHA" \
            $CUSTOM_BUILD_ARGS \
            -t catalyst-taiko-client:test \
            -f Dockerfile.taiko-client \
            ./taiko-mono
        ;;
    protocol)
        echo "🐳 Building Taiko Protocol..."
        # shellcheck disable=SC2086
        docker build \
            --build-arg GIT_VERSION="$COMMIT_SHA" \
            $CUSTOM_BUILD_ARGS \
            -t catalyst-taiko-protocol:test \
            -f Dockerfile.taiko-protocol \
            ./taiko-mono
        ;;
    geth)
        echo "🐳 Building Taiko Geth..."
        # shellcheck disable=SC2086
        docker build \
            --build-arg GIT_VERSION="$COMMIT_SHA" \
            --build-arg COMMIT="$COMMIT_SHA" \
            $CUSTOM_BUILD_ARGS \
            -t catalyst-taiko-geth:test \
            -f Dockerfile.taiko-geth \
            ./taiko-geth
        ;;
    blobindexer)
        echo "🐳 Building Taiko Blobindexer..."
        # shellcheck disable=SC2086
        docker build \
            --build-arg GIT_VERSION="$COMMIT_SHA" \
            $CUSTOM_BUILD_ARGS \
            -t catalyst-taiko-blobindexer:test \
            -f Dockerfile.taiko-blobindexer \
            ./taiko-mono
        ;;
    *)
        echo "❌ Unknown component: $COMPONENT"
        echo "Usage: $0 [client|protocol|blobindexer|geth] [OPTIONS]"
        exit 1
        ;;
esac

echo ""
echo "✅ Build completed successfully!"
echo "   Image: catalyst-taiko-$COMPONENT:test"
echo "   Commit: $COMMIT_SHA"

