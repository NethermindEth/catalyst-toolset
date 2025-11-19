# Pre-Build Customization Guide

This guide explains how to customize the binary builds before compilation. The customization system allows you to make simple modifications to the codebase without forking the entire repository.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Customization Methods](#customization-methods)
- [Local Builds](#local-builds)
- [GitHub Workflow Integration](#github-workflow-integration)
- [Examples](#examples)
- [Best Practices](#best-practices)

## Overview

The pre-build customization system supports multiple methods:

1. **Custom Scripts** - Run bash scripts before the build
2. **Inline Commands** - Execute bash commands directly
3. **JSON Configuration** - Apply structured customizations
4. **Patch Files** - Apply Git-style patch files
5. **Environment Files** - Load custom environment variables

## Quick Start

### Method 1: Using Custom Scripts (Recommended)

1. Create a custom script (rename the example):

```bash
cp custom-build.example.sh custom-build.sh
# Edit custom-build.sh with your customizations
```

2. Build locally:

```bash
./test-build-local.sh client
```

The build system will automatically detect and run your `custom-build.sh` file.

### Method 2: Component-Specific Customization

Create component-specific files for targeted customizations:

```bash
# For Taiko Client only
customize-client.sh

# For Taiko Geth only
customize-geth.sh

# For Blobindexer only
customize-blobindexer.sh

# For Protocol only
customize-protocol.sh
```

## Customization Methods

### 1. Custom Scripts

Create a bash script that will be executed before the build.

**Generic script (applies to all components):**
```bash
custom-build.sh
```

**Component-specific scripts:**
```bash
customize-client.sh     # Only for taiko-client
customize-geth.sh       # Only for taiko-geth
customize-blobindexer.sh # Only for blobindexer
customize-protocol.sh   # Only for taiko-protocol
```

**Script Template:**
```bash
#!/bin/bash
COMPONENT=$1
WORKING_DIR=$2

cd "$WORKING_DIR" || exit 1

case "$COMPONENT" in
    client)
        echo "Customizing Taiko Client..."
        # Your client-specific customizations
        ;;
    geth)
        echo "Customizing Taiko Geth..."
        # Your geth-specific customizations
        ;;
    # ... other components
esac
```

### 2. Inline Commands

Execute bash commands directly without creating a file:

```bash
./test-build-local.sh client --custom-commands "sed -i 's/old/new/g' file.go"
```

### 3. JSON Configuration

Create a structured configuration file for complex customizations:

**File: `custom-build.json` or `customize-{component}.json`**

```json
{
  "replacements": [
    {
      "file": "params/config.go",
      "search": "MaxPeers:.*50",
      "replace": "MaxPeers: 100"
    }
  ],
  "commands": [
    "echo 'Running custom configuration'",
    "go mod download"
  ]
}
```

### 4. Patch Files

Apply Git-style patches:

**File: `custom-build.patch` or `customize-{component}.patch`**

```diff
diff --git a/params/config.go b/params/config.go
index 1234567..abcdefg 100644
--- a/params/config.go
+++ b/params/config.go
@@ -10,7 +10,7 @@ var (
-	DefaultTimeout  = 30
+	DefaultTimeout  = 60
 )
```

Apply it:
```bash
./test-build-local.sh client --custom-patch custom-build.patch
```

### 5. Environment Files

Load custom environment variables:

**File: `custom-build.env`**

```bash
export CUSTOM_FLAG=true
export BUILD_OPTIMIZATION="-O3"
export FEATURE_FLAGS="feature1,feature2"
```

## Local Builds

### Basic Usage

```bash
# Build with auto-detected customization files
./test-build-local.sh client

# Build specific components
./test-build-local.sh geth
./test-build-local.sh blobindexer
./test-build-local.sh protocol
```

### With Custom Options

```bash
# Using a custom script
./test-build-local.sh client --custom-script my-custom.sh

# Using inline commands
./test-build-local.sh geth --custom-commands "sed -i 's/MaxPeers = 50/MaxPeers = 100/g' params/config.go"

# Using JSON config
./test-build-local.sh client --custom-config my-config.json

# Using a patch file
./test-build-local.sh geth --custom-patch my-fixes.patch

# Combine multiple options
./test-build-local.sh client \
  --custom-script prepare.sh \
  --custom-patch fixes.patch
```

## GitHub Workflow Integration

### Using Workflow Inputs

When triggering the GitHub Actions workflow, you can provide customization options:

#### 1. Inline Commands

In the workflow dispatch form:

- **custom_commands**: `sed -i 's/old/new/g' config.go && echo "Modified"`

#### 2. Remote Scripts/Patches

Host your customization files and provide URLs:

- **custom_script_url**: `https://example.com/my-custom-build.sh`
- **custom_patch_url**: `https://example.com/my-changes.patch`

### Example Workflow Trigger

```yaml
# In GitHub Actions UI, provide:
taiko_version: main
custom_commands: |
  sed -i 's/DefaultTimeout = 30/DefaultTimeout = 60/g' params/config.go
  echo "Custom timeout configured"
```

Or via GitHub CLI:

```bash
gh workflow run taiko-blobindexer_docker_build.yml \
  -f taiko_version=main \
  -f custom_commands="sed -i 's/old/new/g' file.go"
```

## Examples

### Example 1: Change Configuration Values

**File: `customize-geth.sh`**

```bash
#!/bin/bash
COMPONENT=$1
WORKING_DIR=$2

cd "$WORKING_DIR" || exit 1

echo "Modifying Geth configuration..."

# Increase max peers
sed -i 's/MaxPeers:.*50/MaxPeers: 100/g' params/config.go

# Adjust timeout
sed -i 's/DefaultTimeout.*=.*30/DefaultTimeout = 60/g' params/config.go

echo "Configuration modified successfully"
```

### Example 2: Apply Multiple Patches

**File: `custom-build.sh`**

```bash
#!/bin/bash
COMPONENT=$1
WORKING_DIR=$2

cd "$WORKING_DIR" || exit 1

# Apply all patches from a patches directory
for patch in /patches/*.patch; do
    if [ -f "$patch" ]; then
        echo "Applying patch: $patch"
        git apply "$patch" || patch -p1 < "$patch"
    fi
done
```

### Example 3: Add Custom Build Flags

**File: `customize-client.json`**

```json
{
  "replacements": [
    {
      "file": "Makefile",
      "search": "LDFLAGS =",
      "replace": "LDFLAGS = -X main.customFlag=true"
    }
  ],
  "commands": [
    "export CGO_ENABLED=1",
    "export GOFLAGS='-tags=custom'",
    "go mod download"
  ]
}
```

### Example 4: Version String Customization

**File: `custom-build.sh`**

```bash
#!/bin/bash
COMPONENT=$1
WORKING_DIR=$2

cd "$WORKING_DIR" || exit 1

BUILD_DATE=$(date +%Y-%m-%d)
CUSTOM_VERSION="custom-${BUILD_DATE}"

# Modify version strings
find . -name "version.go" -type f -exec sed -i \
  "s/gitCommit = \"\"/gitCommit = \"${CUSTOM_VERSION}\"/g" {} \;

echo "Version customized to: $CUSTOM_VERSION"
```

### Example 5: Download Additional Dependencies

**File: `custom-build.sh`**

```bash
#!/bin/bash
COMPONENT=$1
WORKING_DIR=$2

cd "$WORKING_DIR" || exit 1

# Download custom configuration
curl -sL https://example.com/custom-config.yaml -o config.yaml

# Download additional dependencies
if [ "$COMPONENT" = "geth" ]; then
    curl -sL https://example.com/custom-genesis.json -o genesis.json
fi
```

## Best Practices

### 1. Version Control

- Keep your customization files in a separate Git repository
- Document what each customization does
- Use semantic versioning for your customization scripts

### 2. Safety

- Always test customizations locally before using in CI
- Make backups of files before modifying them
- Use `git apply` with patches when possible (better error handling)
- Add error checking in your scripts:

```bash
set -e  # Exit on error
set -u  # Exit on undefined variable
```

### 3. Maintainability

- Keep customizations minimal and focused
- Comment your scripts thoroughly
- Use component-specific scripts when possible
- Prefer patches over sed commands for complex changes

### 4. Testing

```bash
# Test locally first
./test-build-local.sh client --custom-script test-custom.sh

# Verify the binary works
docker run catalyst-taiko-client:test --help

# Check version strings
docker run catalyst-taiko-client:test version
```

### 5. Organization

Recommended directory structure for customizations:

```
my-customizations/
├── README.md
├── scripts/
│   ├── customize-client.sh
│   ├── customize-geth.sh
│   └── common-utils.sh
├── patches/
│   ├── client-timeout.patch
│   └── geth-peers.patch
├── configs/
│   ├── client-config.json
│   └── geth-config.json
└── tests/
    └── test-customizations.sh
```

## Security Considerations

1. **Remote URLs**: Only use trusted sources for `custom_script_url` and `custom_patch_url`
2. **Inline Commands**: Be cautious with user-provided commands in workflows
3. **Secrets**: Never hardcode secrets in customization scripts
4. **Validation**: Validate inputs before applying customizations

## Troubleshooting

### Customization Not Applied

Check that:
- File names are correct (`custom-build.sh` or `customize-{component}.sh`)
- Scripts have execute permissions (`chmod +x custom-build.sh`)
- Scripts are in the repository root directory

### Build Failures After Customization

1. Test the build without customizations first
2. Add debug output to your script:
   ```bash
   set -x  # Print commands as they execute
   ```
3. Check that file paths are correct
4. Verify syntax of sed/awk commands

### Docker Build Issues

- Ensure required tools (bash, jq, patch) are available
- Check COPY commands match your file structure
- Verify build-args are passed correctly

## Support

For issues or questions:
1. Check the example files in the repository
2. Review the build logs for error messages
3. Test locally with the `test-build-local.sh` script
4. Open an issue in the repository

## License

This customization system is part of the Catalyst Toolset and follows the same license.

