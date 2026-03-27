# Pre-Build Customization System - Architecture

## System Overview

The pre-build customization system allows users to modify the binary codebase before compilation through multiple input methods, without needing to fork the repository.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Input Layer                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Local Files  │  │   CLI Args   │  │ Workflow     │          │
│  │              │  │              │  │ Inputs       │          │
│  │ • Scripts    │  │ --script     │  │              │          │
│  │ • JSON       │  │ --commands   │  │ • commands   │          │
│  │ • Patches    │  │ --config     │  │ • script_url │          │
│  │ • .env       │  │ --patch      │  │ • patch_url  │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                 │                  │                   │
│         └─────────────────┴──────────────────┘                   │
│                           │                                      │
└───────────────────────────┼──────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                 Pre-Build Customization Script                   │
│                   (pre-build-customize.sh)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  1. Parse Input Arguments                                        │
│     └─► Detect component type (client/geth/blobindexer/protocol)│
│                                                                   │
│  2. Auto-Detect Customization Files                              │
│     ├─► custom-build.sh        (generic)                         │
│     └─► customize-{component}.*  (specific)                      │
│                                                                   │
│  3. Execute Customizations in Order:                             │
│     ┌──────────────────────────────────────────┐                │
│     │ a) Load environment variables (.env)     │                │
│     │ b) Apply patch files (.patch)            │                │
│     │ c) Run custom scripts (.sh)              │                │
│     │ d) Execute inline commands               │                │
│     │ e) Apply JSON configuration (.json)      │                │
│     └──────────────────────────────────────────┘                │
│                                                                   │
│  4. Report Results                                               │
│     └─► Success/failure with colored output                      │
│                                                                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Modified Codebase                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  • Configuration values changed                                  │
│  • Source code patched                                           │
│  • Environment variables set                                     │
│  • Additional files added                                        │
│                                                                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Build Process                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Docker Build (Dockerfile.taiko-*)                               │
│  ├─► Install dependencies                                        │
│  ├─► Copy source code                                            │
│  ├─► Run pre-build-customize.sh ◄── Integration Point            │
│  ├─► Compile binary                                              │
│  └─► Create final image                                          │
│                                                                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Customized Binary                             │
│                   (Docker Image)                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Component Flow

### 1. Local Build Flow

```
User
 │
 ├─► Creates: custom-build.sh / customize-{component}.sh
 │
 ├─► Runs: ./test-build-local.sh client [--options]
 │     │
 │     ├─► Checks out submodule
 │     │
 │     ├─► Fixes git metadata
 │     │
 │     └─► Builds Docker image
 │           │
 │           └─► Docker RUN: pre-build-customize.sh
 │                 │
 │                 ├─► Detects customization files
 │                 ├─► Applies customizations
 │                 └─► Continues with build
 │
 └─► Result: catalyst-taiko-{component}:test
```

### 2. GitHub Workflow Flow

```
User (GitHub UI)
 │
 ├─► Triggers workflow with inputs:
 │     • taiko_version: main
 │     • custom_commands: "sed -i 's/old/new/g' file.go"
 │     • custom_script_url: https://example.com/script.sh
 │     • custom_patch_url: https://example.com/patch.patch
 │
 ├─► GitHub Actions
 │     │
 │     ├─► Checkout code
 │     │
 │     ├─► Download custom artifacts (if URLs provided)
 │     │
 │     └─► Docker build with build-args
 │           │
 │           └─► Docker RUN: pre-build-customize.sh
 │                 │
 │                 ├─► Uses CUSTOM_COMMANDS build-arg
 │                 ├─► Loads downloaded files
 │                 └─► Applies customizations
 │
 └─► Result: Pushed to Docker Hub
```

## File Priority System

When multiple customization sources exist, they are applied in this order:

```
1. Environment Files (.env)           [First - sets environment]
   └─► Loads environment variables

2. Patch Files (.patch)               [Second - modifies files]
   └─► Applies Git patches

3. Custom Scripts (.sh)               [Third - runs custom logic]
   └─► Executes bash scripts

4. Inline Commands                    [Fourth - CLI/workflow commands]
   └─► Executes provided commands

5. JSON Configuration (.json)         [Last - structured changes]
   └─► Applies replacements and commands
```

**Component-Specific Override:**

```
Generic Files          Component-Specific Files
────────────          ────────────────────────
custom-build.sh       ───► customize-client.sh      (Higher priority)
custom-build.json     ───► customize-client.json    (Higher priority)
custom-build.patch    ───► customize-client.patch   (Higher priority)

Component-specific files override generic ones when both exist.
```

## Integration Points

### Dockerfile Integration

Each Dockerfile includes the customization system:

```dockerfile
# Install required tools
RUN apk add --no-cache bash jq patch

# Copy customization script and files
COPY --chmod=755 pre-build-customize.sh /tmp/
COPY custom*.sh custom*.json custom*.patch /tmp/ || true

# Run customization
RUN if [ -f /tmp/pre-build-customize.sh ]; then \
        WORKING_DIR=/build /tmp/pre-build-customize.sh <component> \
            ${CUSTOM_SCRIPT:+--script /tmp/$CUSTOM_SCRIPT} \
            ${CUSTOM_COMMANDS:+--commands "$CUSTOM_COMMANDS"} \
            ${CUSTOM_CONFIG:+--config /tmp/$CUSTOM_CONFIG} \
            ${CUSTOM_PATCH:+--patch /tmp/$CUSTOM_PATCH}; \
    fi

# Continue with build...
```

### Local Test Script Integration

```bash
# test-build-local.sh

# Parse customization options
--custom-script <file>
--custom-commands <commands>
--custom-config <file>
--custom-patch <file>

# Pass to Docker as build-args
docker build \
  --build-arg CUSTOM_SCRIPT=<filename> \
  --build-arg CUSTOM_COMMANDS="<commands>" \
  ...
```

### GitHub Workflow Integration

```yaml
# .github/workflows/*.yml

inputs:
  custom_commands:
    description: 'Custom commands to run before build'
  custom_script_url:
    description: 'URL to download custom script'
  custom_patch_url:
    description: 'URL to download patch file'

steps:
  - name: Download custom build artifacts
    run: |
      curl -sL "${{ inputs.custom_script_url }}" -o custom-build.sh
      curl -sL "${{ inputs.custom_patch_url }}" -o custom-build.patch

  - name: Build and push
    uses: docker/build-push-action@v5
    with:
      build-args: |
        CUSTOM_COMMANDS=${{ inputs.custom_commands }}
```

## Security Considerations

### Sandboxing

```
Docker Build Environment
├─► Runs in isolated container
├─► Limited to build context
└─► No access to host system
```

### Input Validation

```
┌─────────────────────┐
│  User Input         │
└──────┬──────────────┘
       │
       ├─► Script exists?
       ├─► File readable?
       ├─► Commands safe?
       └─► URLs trusted?
              │
              ▼
       ┌─────────────┐
       │  Validation │
       └──────┬──────┘
              │
              ▼
       Execute if valid
```

### Best Practices

1. **Local Testing First**: Always test customizations locally
2. **Trusted Sources Only**: Only use URLs from trusted sources
3. **No Secrets**: Never hardcode secrets in customization files
4. **Minimal Changes**: Keep customizations focused and minimal
5. **Version Control**: Track customization files separately

## Error Handling

```
Error Detection
     │
     ├─► File not found
     │     └─► Skip silently or warn
     │
     ├─► Script fails
     │     └─► Stop build (set -e)
     │
     ├─► Patch fails
     │     └─► Try alternative method
     │
     └─► Command fails
           └─► Exit with error code
```

## Extension Points

### Adding New Customization Methods

To add a new customization method:

1. Add parsing logic in `pre-build-customize.sh`
2. Add execution logic in `run_customization()` function
3. Update documentation
4. Add test case to `test-customization.sh`

### Supporting New Components

To support a new component:

1. Create `Dockerfile.taiko-<component>`
2. Add customization integration (copy pre-build-customize.sh)
3. Add to `test-build-local.sh` case statement
4. Create example `customize-<component>.sh`

## Performance Considerations

### Build Cache

```
Docker Layer Caching
├─► Dependencies (cached)
├─► Source code (cached)
├─► Customization script (may invalidate cache)
└─► Build (rebuilt after customization)
```

### Optimization Tips

1. Place customization early in Dockerfile
2. Use `.dockerignore` for unnecessary files
3. Keep customization scripts fast
4. Use multi-stage builds effectively

## Monitoring and Debugging

### Debug Mode

Enable debug output:

```bash
# In custom script
set -x  # Print commands
set -v  # Print input lines

# Check what was executed
docker history <image> | grep customize
```

### Logs

```
Build Logs
├─► Pre-build customization output
├─► File operations
├─► Command execution
└─► Success/failure status
```

## Future Enhancements

Potential improvements:

1. **Validation Framework**: Pre-validate customization scripts
2. **Template System**: Reusable customization templates
3. **Rollback Mechanism**: Undo customizations if build fails
4. **Dry-Run Mode**: Preview customizations without applying
5. **Configuration Schema**: JSON schema validation for configs
6. **Plugin System**: Extensible customization plugins

## Summary

The pre-build customization system provides:

✅ **Flexibility**: Multiple input methods (scripts, commands, patches, JSON)
✅ **Simplicity**: Auto-detection and sensible defaults
✅ **Safety**: Isolated execution in Docker containers
✅ **Integration**: Works with local builds and CI/CD
✅ **Extensibility**: Easy to add new customization methods

This architecture enables users to customize builds without forking the repository, while maintaining security and reproducibility.

