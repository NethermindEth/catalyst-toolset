# Pre-Build Customization System - File Reference

This document provides a complete reference of all files in the pre-build customization system.

## Core System Files

### `pre-build-customize.sh`
**Purpose**: Main customization script that orchestrates all customization activities

**Location**: Repository root

**Key Features**:
- Parses command-line arguments
- Auto-detects customization files
- Executes customizations in defined order
- Supports multiple input methods (scripts, commands, JSON, patches)
- Provides colored output for better visibility

**Usage**:
```bash
./pre-build-customize.sh <component> [OPTIONS]
```

**Options**:
- `--script <path>` - Run a custom script
- `--commands <commands>` - Execute inline bash commands
- `--config <json>` - Apply JSON configuration
- `--patch <path>` - Apply patch file
- `--env <file>` - Load environment variables

---

### `test-build-local.sh` (Modified)
**Purpose**: Enhanced local build script with customization support

**Location**: Repository root

**What Changed**:
- Added customization argument parsing
- Passes customization options to Docker build as build-args
- Supports all customization methods

**Usage**:
```bash
./test-build-local.sh <component> [CUSTOMIZATION_OPTIONS]
```

**Examples**:
```bash
./test-build-local.sh client
./test-build-local.sh geth --custom-script my-script.sh
./test-build-local.sh client --custom-commands "sed -i 's/old/new/g' file.go"
```

---

### `test-customization.sh`
**Purpose**: Automated test suite for the customization system

**Location**: Repository root

**What It Tests**:
1. Custom script execution
2. Inline commands
3. JSON configuration
4. Patch file application
5. Component-specific script detection

**Usage**:
```bash
./test-customization.sh
```

**Exit Codes**:
- `0` - All tests passed
- `1` - One or more tests failed

---

## Example Files

### `custom-build.example.sh`
**Purpose**: Example customization script showing common patterns

**Location**: Repository root

**What It Shows**:
- Script structure and argument handling
- Component-specific customizations
- Configuration file modifications
- Patch application
- Environment variable setup
- Multi-component logic

**To Use**:
```bash
cp custom-build.example.sh custom-build.sh
# Edit custom-build.sh with your customizations
```

---

### `custom-build.example.json`
**Purpose**: Example JSON configuration for structured customizations

**Location**: Repository root

**Schema**:
```json
{
  "replacements": [
    {
      "file": "path/to/file",
      "search": "pattern",
      "replace": "replacement"
    }
  ],
  "commands": [
    "command1",
    "command2"
  ]
}
```

**To Use**:
```bash
cp custom-build.example.json custom-build.json
# Edit with your customizations
```

---

### `custom-build.example.patch`
**Purpose**: Example Git-style patch file

**Location**: Repository root

**Format**: Standard unified diff format

**To Use**:
```bash
# Create your own patch
git diff > custom-build.patch

# Or copy example
cp custom-build.example.patch custom-build.patch
```

---

## Documentation Files

### `CUSTOMIZATION.md`
**Purpose**: Comprehensive customization guide

**Location**: Repository root

**Contents**:
- Detailed usage instructions
- All customization methods explained
- Local and CI/CD integration
- Multiple examples and use cases
- Best practices
- Troubleshooting guide
- Security considerations

**Audience**: Users who need detailed information

---

### `CUSTOMIZATION-QUICK-REF.md`
**Purpose**: Quick reference guide for common tasks

**Location**: Repository root

**Contents**:
- 30-second quick start
- Command reference table
- Common customization patterns
- File format examples
- Quick troubleshooting
- Testing checklist

**Audience**: Users who need quick answers

---

### `CUSTOMIZATION-ARCHITECTURE.md`
**Purpose**: System architecture and design documentation

**Location**: Repository root

**Contents**:
- System overview with diagrams
- Component flow diagrams
- File priority system
- Integration points
- Security considerations
- Extension points
- Performance tips

**Audience**: Developers and maintainers

---

### `CUSTOMIZATION-FILES.md` (This File)
**Purpose**: Complete file reference

**Location**: Repository root

**Contents**: Description of all system files

---

## Configuration Files

### `.gitignore`
**Purpose**: Prevent committing user customization files

**Location**: Repository root

**What It Ignores**:
- `custom-build.sh`
- `custom-build.json`
- `custom-build.patch`
- `custom-build.env`
- `customize-*.sh`
- `customize-*.json`
- `customize-*.patch`

**What It Preserves**:
- `custom-build.example.*` (example files)
- `pre-build-customize.sh` (core script)

---

### `.gitignore.customization`
**Purpose**: Standalone gitignore rules for customization files

**Location**: Repository root

**Usage**: Copy these rules to your `.gitignore` if using a fork

---

## Modified Dockerfiles

All Dockerfiles have been updated to integrate the customization system:

### `Dockerfile.taiko-client`
**Changes**:
- Added bash, jq, patch to dependencies
- Added COPY commands for customization files
- Added RUN command to execute customizations
- Supports CUSTOM_* build-args

### `Dockerfile.taiko-geth`
**Changes**: Same as taiko-client

### `Dockerfile.taiko-blobindexer`
**Changes**: Same as taiko-client (Rust-based)

### `Dockerfile.taiko-protocol`
**Changes**: Same as taiko-client (Node-based)

---

## User Customization Files

These files are created by users and are ignored by Git:

### `custom-build.sh`
**Purpose**: Generic customization script (all components)

**Created By**: User (copy from example)

**Auto-Detected**: Yes

**Priority**: Low (overridden by component-specific)

---

### `customize-<component>.sh`
**Purpose**: Component-specific customization script

**Examples**:
- `customize-client.sh`
- `customize-geth.sh`
- `customize-blobindexer.sh`
- `customize-protocol.sh`

**Created By**: User

**Auto-Detected**: Yes

**Priority**: High (overrides generic)

---

### `custom-build.json`
**Purpose**: Generic JSON configuration

**Created By**: User (copy from example)

**Auto-Detected**: Yes

---

### `customize-<component>.json`
**Purpose**: Component-specific JSON configuration

**Created By**: User

**Auto-Detected**: Yes

---

### `custom-build.patch`
**Purpose**: Generic patch file

**Created By**: User (git diff output)

**Auto-Detected**: Yes

---

### `customize-<component>.patch`
**Purpose**: Component-specific patch file

**Created By**: User

**Auto-Detected**: Yes

---

### `custom-build.env`
**Purpose**: Environment variables file

**Created By**: User

**Auto-Detected**: Yes (if --env specified)

**Format**:
```bash
export VAR_NAME=value
export ANOTHER_VAR=value
```

---

## Modified GitHub Workflows

### `.github/workflows/taiko-blobindexer_docker_build.yml`
**Changes Added**:

**New Inputs**:
- `custom_commands` - Inline commands to execute
- `custom_script_url` - URL to download script from
- `custom_patch_url` - URL to download patch from

**New Steps**:
- Download custom build artifacts (if URLs provided)
- Pass CUSTOM_COMMANDS as build-arg

**Note**: Similar changes should be applied to other workflow files:
- `taiko-client_docker_build.yml`
- `taiko-geth_docker_build.yml`
- `taiko-protocol_docker_build.yml`

---

## File Relationships

```
Core System
├── pre-build-customize.sh (main script)
├── test-build-local.sh (local build integration)
└── test-customization.sh (test suite)

Examples (Committed)
├── custom-build.example.sh
├── custom-build.example.json
└── custom-build.example.patch

Documentation (Committed)
├── CUSTOMIZATION.md (full guide)
├── CUSTOMIZATION-QUICK-REF.md (quick reference)
├── CUSTOMIZATION-ARCHITECTURE.md (architecture)
└── CUSTOMIZATION-FILES.md (this file)

Configuration (Committed)
├── .gitignore (updated)
└── .gitignore.customization (reference)

Dockerfiles (Modified)
├── Dockerfile.taiko-client
├── Dockerfile.taiko-geth
├── Dockerfile.taiko-blobindexer
└── Dockerfile.taiko-protocol

User Files (Ignored by Git)
├── custom-build.sh
├── custom-build.json
├── custom-build.patch
├── custom-build.env
├── customize-client.*
├── customize-geth.*
├── customize-blobindexer.*
└── customize-protocol.*
```

---

## Quick File Checklist

When setting up customizations, verify these files:

### Required (In Repository)
- [x] `pre-build-customize.sh` - Executable
- [x] `test-build-local.sh` - Executable
- [x] `CUSTOMIZATION.md` - Documentation
- [x] `CUSTOMIZATION-QUICK-REF.md` - Quick reference
- [x] `.gitignore` - Updated

### Optional (User Created)
- [ ] `custom-build.sh` - Your customizations
- [ ] `customize-*.sh` - Component-specific customizations
- [ ] `custom-build.json` - JSON configuration
- [ ] `custom-build.patch` - Patch file

### Testing
- [ ] Run `./test-customization.sh` to verify system works
- [ ] Run `./test-build-local.sh <component>` to test build

---

## File Sizes (Approximate)

| File | Size | Type |
|------|------|------|
| `pre-build-customize.sh` | ~6 KB | Script |
| `test-customization.sh` | ~5 KB | Script |
| `test-build-local.sh` | ~4 KB | Script |
| `custom-build.example.sh` | ~2 KB | Example |
| `custom-build.example.json` | ~0.5 KB | Example |
| `custom-build.example.patch` | ~0.3 KB | Example |
| `CUSTOMIZATION.md` | ~25 KB | Docs |
| `CUSTOMIZATION-QUICK-REF.md` | ~8 KB | Docs |
| `CUSTOMIZATION-ARCHITECTURE.md` | ~12 KB | Docs |
| `CUSTOMIZATION-FILES.md` | ~8 KB | Docs |
| `.gitignore` | ~0.5 KB | Config |

**Total System Size**: ~70 KB

---

## Maintenance

### Adding New Files

If you add new customization capabilities:

1. Update `pre-build-customize.sh` with new logic
2. Add example to `custom-build.example.sh`
3. Document in `CUSTOMIZATION.md`
4. Add to quick reference in `CUSTOMIZATION-QUICK-REF.md`
5. Update this file reference
6. Add test case to `test-customization.sh`

### Version Control

Only commit:
- Core system files
- Example files
- Documentation files
- Configuration files

Never commit:
- User customization files (`custom-build.*`, `customize-*.*`)
- Build artifacts
- Test output

---

## Getting Help

If you have questions about any file:

1. Check the quick reference: `CUSTOMIZATION-QUICK-REF.md`
2. Read the full guide: `CUSTOMIZATION.md`
3. View examples: `custom-build.example.*`
4. Run tests: `./test-customization.sh`
5. Check architecture: `CUSTOMIZATION-ARCHITECTURE.md`

---

**Last Updated**: November 19, 2025
**System Version**: 1.0.0

