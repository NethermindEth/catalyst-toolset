#!/bin/bash

# Example Custom Build Script
# Rename this to custom-build.sh or customize-{component}.sh to activate
#
# This script demonstrates how to customize the build process.
# It receives two arguments:
#   $1 - Component name (client, geth, blobindexer, protocol)
#   $2 - Working directory

COMPONENT=$1
WORKING_DIR=$2

echo "🎨 Running custom build customizations for: $COMPONENT"
echo "Working directory: $WORKING_DIR"

cd "$WORKING_DIR" || exit 1

# Example 1: Modify version strings
# sed -i 's/version = "1.0.0"/version = "1.0.0-custom"/g' version.go

# Example 2: Add custom patches based on component
case "$COMPONENT" in
    client)
        echo "Customizing Taiko Client..."
        # Add client-specific customizations here
        # Example: sed -i 's/defaultTimeout = 30/defaultTimeout = 60/g' config.go
        ;;
    geth)
        echo "Customizing Taiko Geth..."
        # Add geth-specific customizations here
        # Example: sed -i 's/maxPeers = 50/maxPeers = 100/g' params/config.go
        ;;
    blobindexer)
        echo "Customizing Blobindexer..."
        # Add blobindexer-specific customizations here
        ;;
    protocol)
        echo "Customizing Protocol..."
        # Add protocol-specific customizations here
        ;;
    *)
        echo "Unknown component: $COMPONENT"
        ;;
esac

# Example 3: Add custom environment variables
export CUSTOM_BUILD_FLAG=true
export BUILD_TIMESTAMP=$(date +%s)

# Example 4: Modify configuration files
# if [ -f "config.yaml" ]; then
#     sed -i 's/production: false/production: true/g' config.yaml
# fi

# Example 5: Apply multiple patches
# for patch in patches/*.patch; do
#     if [ -f "$patch" ]; then
#         echo "Applying patch: $patch"
#         git apply "$patch" || patch -p1 < "$patch"
#     fi
# done

# Example 6: Download additional dependencies or files
# curl -sL https://example.com/custom-config.json -o custom-config.json

# Example 7: Run code generation or preprocessing
# if command -v go &> /dev/null; then
#     go generate ./...
# fi

echo "✅ Custom build script completed"

