#!/bin/bash

# Pre-build Customization Script
# This script runs before building binaries and allows users to make customizations
# to the codebase before compilation.
#
# Usage:
#   ./pre-build-customize.sh [COMPONENT] [OPTIONS]
#
# Options:
#   --script <path>         Run a custom script file
#   --commands <commands>   Execute inline bash commands
#   --config <json>         Apply customizations from JSON config
#   --patch <path>          Apply a patch file
#   --env <file>            Source environment variables from file
#
# Examples:
#   ./pre-build-customize.sh client --script custom.sh
#   ./pre-build-customize.sh geth --commands "sed -i 's/old/new/g' file.go"
#   ./pre-build-customize.sh blobindexer --patch fixes.patch

set -e

COMPONENT=${1:-}
WORKING_DIR=${WORKING_DIR:-$(pwd)}

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Pre-Build Customization for: ${COMPONENT}${NC}"
echo "Working directory: $WORKING_DIR"

shift || true  # Remove component from args

# Parse arguments
CUSTOM_SCRIPT=""
INLINE_COMMANDS=""
CONFIG_FILE=""
PATCH_FILE=""
ENV_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --script)
            CUSTOM_SCRIPT="$2"
            shift 2
            ;;
        --commands)
            INLINE_COMMANDS="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --patch)
            PATCH_FILE="$2"
            shift 2
            ;;
        --env)
            ENV_FILE="$2"
            shift 2
            ;;
        *)
            echo -e "${YELLOW}⚠️  Unknown option: $1${NC}"
            shift
            ;;
    esac
done

# Function to run customization
run_customization() {
    echo -e "${GREEN}✅ Starting customization process...${NC}"
    
    # Load environment variables if provided
    if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
        echo -e "${BLUE}📝 Loading environment from: $ENV_FILE${NC}"
        # shellcheck disable=SC1090
        source "$ENV_FILE"
    fi
    
    # Apply patch file if provided
    if [ -n "$PATCH_FILE" ] && [ -f "$PATCH_FILE" ]; then
        echo -e "${BLUE}🔧 Applying patch file: $PATCH_FILE${NC}"
        if command -v git &> /dev/null; then
            git apply "$PATCH_FILE" || patch -p1 < "$PATCH_FILE"
        else
            patch -p1 < "$PATCH_FILE"
        fi
    fi
    
    # Run custom script if provided
    if [ -n "$CUSTOM_SCRIPT" ] && [ -f "$CUSTOM_SCRIPT" ]; then
        echo -e "${BLUE}🚀 Running custom script: $CUSTOM_SCRIPT${NC}"
        chmod +x "$CUSTOM_SCRIPT"
        "$CUSTOM_SCRIPT" "$COMPONENT" "$WORKING_DIR"
    fi
    
    # Execute inline commands if provided
    if [ -n "$INLINE_COMMANDS" ]; then
        echo -e "${BLUE}⚡ Executing inline commands...${NC}"
        eval "$INLINE_COMMANDS"
    fi
    
    # Apply JSON configuration if provided
    if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
        echo -e "${BLUE}📋 Applying configuration from: $CONFIG_FILE${NC}"
        apply_json_config "$CONFIG_FILE"
    fi
}

# Function to apply JSON configuration
apply_json_config() {
    local config_file=$1
    
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  Warning: jq not found. Skipping JSON config.${NC}"
        return
    fi
    
    # Read and apply replacements from JSON
    # Expected format:
    # {
    #   "replacements": [
    #     {"file": "path/to/file", "search": "old", "replace": "new"},
    #     ...
    #   ],
    #   "commands": [
    #     "command1",
    #     "command2"
    #   ]
    # }
    
    # Apply file replacements
    local replacements
    replacements=$(jq -r '.replacements[]? | "\(.file)|\(.search)|\(.replace)"' "$config_file")
    while IFS='|' read -r file search replace; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            echo -e "  ${GREEN}→${NC} Replacing in $file"
            sed -i.bak "s|$search|$replace|g" "$file"
            rm -f "${file}.bak"
        fi
    done <<< "$replacements"
    
    # Execute commands from JSON
    local commands
    commands=$(jq -r '.commands[]?' "$config_file")
    while IFS= read -r cmd; do
        if [ -n "$cmd" ]; then
            echo -e "  ${GREEN}→${NC} Running: $cmd"
            eval "$cmd"
        fi
    done <<< "$commands"
}

# Check for component-specific customization files
COMPONENT_CUSTOM_SCRIPT="${WORKING_DIR}/customize-${COMPONENT}.sh"
COMPONENT_PATCH="${WORKING_DIR}/customize-${COMPONENT}.patch"
COMPONENT_CONFIG="${WORKING_DIR}/customize-${COMPONENT}.json"

if [ -f "$COMPONENT_CUSTOM_SCRIPT" ] && [ -z "$CUSTOM_SCRIPT" ]; then
    echo -e "${BLUE}📦 Found component-specific customization script${NC}"
    CUSTOM_SCRIPT="$COMPONENT_CUSTOM_SCRIPT"
fi

if [ -f "$COMPONENT_PATCH" ] && [ -z "$PATCH_FILE" ]; then
    echo -e "${BLUE}📦 Found component-specific patch file${NC}"
    PATCH_FILE="$COMPONENT_PATCH"
fi

if [ -f "$COMPONENT_CONFIG" ] && [ -z "$CONFIG_FILE" ]; then
    echo -e "${BLUE}📦 Found component-specific config file${NC}"
    CONFIG_FILE="$COMPONENT_CONFIG"
fi

# Look for generic customization files if no specific ones found
if [ -z "$CUSTOM_SCRIPT" ] && [ -z "$INLINE_COMMANDS" ] && [ -z "$CONFIG_FILE" ] && [ -z "$PATCH_FILE" ]; then
    if [ -f "${WORKING_DIR}/custom-build.sh" ]; then
        echo -e "${BLUE}📦 Found generic custom-build.sh${NC}"
        CUSTOM_SCRIPT="${WORKING_DIR}/custom-build.sh"
    elif [ -f "${WORKING_DIR}/custom-build.patch" ]; then
        echo -e "${BLUE}📦 Found generic patch file${NC}"
        PATCH_FILE="${WORKING_DIR}/custom-build.patch"
    elif [ -f "${WORKING_DIR}/custom-build.json" ]; then
        echo -e "${BLUE}📦 Found generic config file${NC}"
        CONFIG_FILE="${WORKING_DIR}/custom-build.json"
    else
        echo -e "${YELLOW}ℹ️  No customization files found. Skipping customization.${NC}"
        exit 0
    fi
fi

# Run the customization
cd "$WORKING_DIR"
run_customization

echo -e "${GREEN}✅ Customization completed successfully!${NC}"

