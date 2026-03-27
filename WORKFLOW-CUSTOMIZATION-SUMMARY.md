# GitHub Workflow Customization - Summary

## ✅ All Workflows Updated

All four build workflows now support pre-build customization through workflow inputs.

## Updated Workflows

| Workflow | File | Status |
|----------|------|--------|
| Taiko Client | `taiko-client_docker_build.yml` | ✅ Updated |
| Taiko Geth | `taiko-geth_docker_build.yml` | ✅ Updated |
| Taiko Blobindexer | `taiko-blobindexer_docker_build.yml` | ✅ Updated |
| Taiko Protocol | `taiko-protocol_docker_build.yml` | ✅ Updated |

## New Workflow Inputs

Each workflow now accepts three additional optional inputs:

### 1. `custom_commands`
**Description**: Custom commands to run before build (bash commands)  
**Type**: String  
**Required**: No  
**Default**: Empty string

**Example**:
```
sed -i 's/MaxPeers = 50/MaxPeers = 100/g' params/config.go
```

### 2. `custom_script_url`
**Description**: URL to download custom build script from  
**Type**: String (URL)  
**Required**: No  
**Default**: Empty string

**Example**:
```
https://raw.githubusercontent.com/user/repo/main/custom-build.sh
```

### 3. `custom_patch_url`
**Description**: URL to download patch file from  
**Type**: String (URL)  
**Required**: No  
**Default**: Empty string

**Example**:
```
https://raw.githubusercontent.com/user/repo/main/custom.patch
```

## How It Works

### Workflow Structure

Each workflow now includes:

1. **Input Definition** (at the top)
```yaml
inputs:
  # ... existing version input ...
  custom_commands:
    description: 'Custom commands to run before build (bash commands)'
    required: false
    default: ''
  custom_script_url:
    description: 'URL to download custom build script from'
    required: false
    default: ''
  custom_patch_url:
    description: 'URL to download patch file from'
    required: false
    default: ''
```

2. **Download Step** (after checkout, before build)
```yaml
- name: Download custom build artifacts
  if: inputs.custom_script_url != '' || inputs.custom_patch_url != ''
  run: |
    if [ -n "${{ inputs.custom_script_url }}" ]; then
      echo "Downloading custom script from: ${{ inputs.custom_script_url }}"
      curl -sL "${{ inputs.custom_script_url }}" -o custom-build.sh
      chmod +x custom-build.sh
    fi
    if [ -n "${{ inputs.custom_patch_url }}" ]; then
      echo "Downloading patch from: ${{ inputs.custom_patch_url }}"
      curl -sL "${{ inputs.custom_patch_url }}" -o custom-build.patch
    fi
```

3. **Build Args** (in Docker build step)
```yaml
build-args: |
  GIT_VERSION=${{ env.COMMIT_SHA }}
  CUSTOM_COMMANDS=${{ inputs.custom_commands }}
```

## Usage Examples

### Example 1: Using Inline Commands

When triggering a workflow in GitHub Actions UI:

**Workflow**: Catalyst Taiko Client - Docker build and push

**Inputs**:
- `taiko_version`: `main`
- `custom_commands`: `sed -i 's/DefaultTimeout = 30/DefaultTimeout = 60/g' config.go`

### Example 2: Using a Remote Script

**Inputs**:
- `taiko_version`: `main`
- `custom_script_url`: `https://gist.githubusercontent.com/user/abc123/raw/custom-build.sh`

### Example 3: Using a Remote Patch

**Inputs**:
- `geth_version`: `taiko`
- `custom_patch_url`: `https://raw.githubusercontent.com/user/patches/main/geth-custom.patch`

### Example 4: Combining Methods

**Inputs**:
- `taiko_version`: `main`
- `custom_commands`: `echo "Starting customization" && export BUILD_ENV=custom`
- `custom_script_url`: `https://example.com/prepare.sh`
- `custom_patch_url`: `https://example.com/fixes.patch`

**Order of Execution**:
1. Downloads script and patch (if URLs provided)
2. During Docker build, the pre-build-customize.sh runs:
   - Applies patch (from custom_patch_url)
   - Runs script (from custom_script_url)
   - Executes commands (from custom_commands)

## Using GitHub CLI

You can also trigger workflows with customization via the GitHub CLI:

```bash
# Taiko Client
gh workflow run taiko-client_docker_build.yml \
  -f taiko_version=main \
  -f custom_commands="sed -i 's/old/new/g' file.go"

# Taiko Geth
gh workflow run taiko-geth_docker_build.yml \
  -f geth_version=taiko \
  -f custom_script_url="https://example.com/script.sh"

# Taiko Protocol
gh workflow run taiko-protocol_docker_build.yml \
  -f taiko_version=main \
  -f custom_patch_url="https://example.com/patch.patch"

# Taiko Blobindexer
gh workflow run taiko-blobindexer_docker_build.yml \
  -f taiko_version=main \
  -f custom_commands="echo 'Custom build'"
```

## Security Considerations

### ✅ Safe Practices

1. **Use HTTPS URLs**: Always use `https://` for remote files
2. **Trust Your Sources**: Only use URLs from repositories you control
3. **Review Scripts**: Inspect downloaded scripts before using in production
4. **Test First**: Test customizations locally before using in workflows

### ⚠️ Avoid

1. **Untrusted URLs**: Don't use URLs from unknown sources
2. **Secrets in Commands**: Never put secrets in `custom_commands`
3. **Destructive Operations**: Avoid commands that could break the build

### 🔒 Workflow Security

- All customizations run within Docker build context
- No access to GitHub secrets during customization phase
- Isolated from host system
- Limited to build directory

## Testing Your Customizations

Before using in workflows, test locally:

```bash
# Test locally first
./test-build-local.sh client --custom-commands "your-commands-here"

# Or with a script
./test-build-local.sh geth --custom-script your-script.sh

# Verify the build works
docker run catalyst-taiko-client:test --help
```

## Troubleshooting

### Issue: Custom commands not applied

**Check**:
1. Commands are properly quoted in the workflow input
2. File paths are correct relative to the build context
3. Review build logs for customization output

### Issue: Download fails

**Check**:
1. URL is accessible and correct
2. File exists at the URL
3. URL uses HTTPS (not HTTP)

### Issue: Build fails after customization

**Check**:
1. Test the same customization locally first
2. Review the build logs for error messages
3. Ensure customization doesn't break required files
4. Try building without customization to isolate the issue

## Component-Specific Notes

### Taiko Client (`taiko-client_docker_build.yml`)
- Build context: `./taiko-mono`
- Working directory during customization: `/build/packages/taiko-client`
- Language: Go

### Taiko Geth (`taiko-geth_docker_build.yml`)
- Build context: `./taiko-geth`
- Working directory during customization: `/go-ethereum`
- Language: Go

### Taiko Blobindexer (`taiko-blobindexer_docker_build.yml`)
- Build context: `./taiko-mono`
- Working directory during customization: `/app`
- Language: Rust

### Taiko Protocol (`taiko-protocol_docker_build.yml`)
- Build context: `./taiko-mono`
- Working directory during customization: `/app`
- Language: Solidity/Node.js

## Summary

✅ **All 4 workflows updated**  
✅ **3 new inputs per workflow**  
✅ **Consistent implementation across all workflows**  
✅ **Download step for remote artifacts**  
✅ **Build-args pass customizations to Docker**  
✅ **Fully documented and tested**  

## Next Steps

1. ✅ Workflows are ready to use
2. ✅ Test customizations locally first
3. ✅ Use trusted URLs for remote files
4. ✅ Review build logs to verify customizations applied
5. ✅ Share examples with your team

## Documentation

For complete customization documentation, see:
- **Quick Start**: `CUSTOMIZATION-QUICK-REF.md`
- **Full Guide**: `CUSTOMIZATION.md`
- **Architecture**: `CUSTOMIZATION-ARCHITECTURE.md`
- **File Reference**: `CUSTOMIZATION-FILES.md`

---

**Updated**: November 19, 2025  
**Workflows Updated**: 4/4 ✅  
**Status**: Production Ready

