# Pre-Build Customization - Quick Reference

## 🚀 Quick Start (30 seconds)

```bash
# 1. Copy example script
cp custom-build.example.sh custom-build.sh

# 2. Edit your customizations
nano custom-build.sh

# 3. Build locally
./test-build-local.sh client
```

## 📋 Customization File Names

| Purpose | Filename | Priority |
|---------|----------|----------|
| All components | `custom-build.sh` | Low |
| Taiko Client only | `customize-client.sh` | High |
| Taiko Geth only | `customize-geth.sh` | High |
| Blobindexer only | `customize-blobindexer.sh` | High |
| Taiko Protocol only | `customize-protocol.sh` | High |

Component-specific files override generic files.

## 🛠️ Command Line Usage

### Local Builds

```bash
# Auto-detect customization files
./test-build-local.sh <component>

# Explicit customization script
./test-build-local.sh <component> --custom-script my-script.sh

# Inline commands
./test-build-local.sh <component> --custom-commands "sed -i 's/old/new/g' file.go"

# JSON configuration
./test-build-local.sh <component> --custom-config config.json

# Patch file
./test-build-local.sh <component> --custom-patch changes.patch
```

**Components:** `client`, `geth`, `blobindexer`, `protocol`

### GitHub Workflows

In the workflow dispatch form, provide:

- **custom_commands**: Bash commands to run
- **custom_script_url**: URL to download script from
- **custom_patch_url**: URL to download patch from

## 📝 Common Customizations

### Change Configuration Value

```bash
sed -i 's/MaxPeers = 50/MaxPeers = 100/g' params/config.go
```

### Apply Patch

```bash
git apply my-changes.patch
# or
patch -p1 < my-changes.patch
```

### Set Environment Variable

```bash
export CUSTOM_FLAG=true
export BUILD_OPTS="-O3"
```

### Modify Multiple Files

```bash
find . -name "*.go" -type f -exec sed -i 's/old/new/g' {} \;
```

### Download Additional Files

```bash
curl -sL https://example.com/config.yaml -o config.yaml
```

## 📦 File Format Examples

### Script Format (`.sh`)

```bash
#!/bin/bash
COMPONENT=$1
WORKING_DIR=$2

cd "$WORKING_DIR" || exit 1

# Your customizations here
sed -i 's/old/new/g' file.go
```

### JSON Format (`.json`)

```json
{
  "replacements": [
    {
      "file": "path/to/file.go",
      "search": "old_value",
      "replace": "new_value"
    }
  ],
  "commands": [
    "echo 'Running custom command'",
    "go mod download"
  ]
}
```

### Patch Format (`.patch`)

```diff
diff --git a/file.go b/file.go
index abc123..def456 100644
--- a/file.go
+++ b/file.go
@@ -10,7 +10,7 @@
-	OldValue = 30
+	NewValue = 60
```

## ✅ Testing Checklist

- [ ] Customization file has correct name
- [ ] Script has execute permissions (`chmod +x`)
- [ ] Tested locally with `./test-build-local.sh`
- [ ] Build completes successfully
- [ ] Binary runs correctly (`docker run ... --help`)
- [ ] Changes are applied as expected

## 🔍 Debugging

```bash
# Add debug output to your script
set -x  # Print commands
set -e  # Exit on error

# Check if files exist
ls -la custom*.sh customize-*.sh

# Verify file permissions
ls -l custom-build.sh

# Test script manually
./custom-build.sh client /path/to/working/dir
```

## 📚 Full Documentation

For detailed information, see [CUSTOMIZATION.md](./CUSTOMIZATION.md)

## 🎯 Examples by Use Case

### Increase Timeout Values

```bash
sed -i 's/timeout.*=.*30/timeout = 60/g' config.go
```

### Add Custom Build Tags

```bash
export GOFLAGS='-tags=custom,debug'
```

### Modify Version String

```bash
sed -i "s/version = \"\"/version = \"custom-$(date +%Y%m%d)\"/g" version.go
```

### Download Custom Genesis

```bash
curl -sL https://example.com/genesis.json -o custom-genesis.json
```

### Enable Debug Features

```bash
sed -i 's/DEBUG = false/DEBUG = true/g' constants.go
```

## 🚨 Important Notes

- **Always test locally first** before using in CI
- **Keep customizations minimal** for easier maintenance
- **Document your changes** for team members
- **Never commit sensitive data** in customization files
- **Add customization files to `.gitignore`**

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Script not running | Check filename and permissions |
| Changes not applied | Verify file paths and syntax |
| Build fails | Test without customizations first |
| Docker errors | Check COPY commands in Dockerfile |

## 🔗 Resources

- [Full Customization Guide](./CUSTOMIZATION.md)
- [Example Script](./custom-build.example.sh)
- [Example JSON Config](./custom-build.example.json)
- [Example Patch](./custom-build.example.patch)

---

**Need help?** Check the logs, review examples, or open an issue!

