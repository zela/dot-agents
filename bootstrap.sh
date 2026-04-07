#!/bin/bash
# ~/dot-agents/bootstrap.sh
#
# Community skills are managed by `pnpm dlx skills`.
# This script overlays your personal custom skills on top,
# ensuring your overrides always win over community defaults.

AGENTS="-a claude-code -a antigravity -a github-copilot"
AGENT_DIRS=(
    ~/.claude/skills
    ~/.gemini/antigravity/skills
    ~/.agents/skills
)
CUSTOM_DIR=~/dot-agents/custom-skills

UPSTREAM=false
SYMLINK=false
for arg in "$@"; do
    case "$arg" in
        --upstream) UPSTREAM=true ;;
        --symlink)  SYMLINK=true ;;
    esac
done

echo "Starting Agent Dotfiles Synchronization..."

# 1. Install/update community skills (if requested with --upstream flag)
if [ "$UPSTREAM" = true ]; then
    echo "Cleaning existing skills..."
    rm -rf "${AGENT_DIRS[@]}"
    echo "Installing community skills from upstream-sources.txt..."
    FAILED=0
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        # Parse: first word = source, remaining words = skill names
        read -r source skills <<< "$line"

        if [ -z "$skills" ] || [ "$skills" = "*" ]; then
            # Install all skills from this source
            echo "  → $source (all skills)"
            if ! pnpm dlx skills add "$source" -g $AGENTS --skill '*' -y < /dev/null; then
                echo "  ✗ FAILED: $source"
                FAILED=$((FAILED + 1))
            fi
        else
            # Cherry-pick specific skills
            SKILL_FLAGS=""
            for skill in $skills; do
                SKILL_FLAGS="$SKILL_FLAGS --skill $skill"
            done
            echo "  → $source ($skills)"
            if ! pnpm dlx skills add "$source" -g $AGENTS $SKILL_FLAGS -y < /dev/null; then
                echo "  ✗ FAILED: $source ($skills)"
                FAILED=$((FAILED + 1))
            fi
        fi

        # Brief pause between sources to avoid pnpm dlx cache collisions
        sleep 2
    done < ~/dot-agents/upstream-sources.txt

    if [ $FAILED -gt 0 ]; then
        echo "  ⚠ $FAILED source(s) failed. Re-run or install manually."
    fi
fi

# 2. Overlay custom skills on top of all agent skill directories
#    .custom-skills.prev tracks previously installed names so removals propagate.
MANIFEST=~/dot-agents/.custom-skills.prev

# Build current custom skill name list
CURRENT_NAMES=()
for file in "$CUSTOM_DIR"/*; do
    [ -e "$file" ] && CURRENT_NAMES+=("$(basename "$file")")
done

for dir in "${AGENT_DIRS[@]}"; do
    [ -d "$dir" ] || { echo "  ⚠ $dir not found, skipping"; continue; }

    # Remove previously installed custom skills that no longer exist
    if [ -f "$MANIFEST" ]; then
        while IFS= read -r old_name; do
            [ -e "$CUSTOM_DIR/$old_name" ] || rm -rf "$dir/$old_name"
        done < "$MANIFEST"
    fi

    # Install current custom skills
    for name in "${CURRENT_NAMES[@]}"; do
        if [ "$SYMLINK" = true ]; then
            rm -f "$dir/$name"
            ln -sfn "$CUSTOM_DIR/$name" "$dir/$name"
        else
            cp -a "$CUSTOM_DIR/$name" "$dir/$name"
        fi
    done
    echo "  ✓ $dir"
done

# Update manifest
printf '%s\n' "${CURRENT_NAMES[@]}" > "$MANIFEST"

if [ "$SYMLINK" = true ]; then
    echo "Custom skills symlinked."
else
    echo "Custom skills copied."
fi

# 3. Global Workflows
echo "Linking Global Workflows..."
mkdir -p ~/.agent
rm -rf ~/.agent/workflows
ln -sfn ~/dot-agents/shared-workflows ~/.agent/workflows

# 4. Global Configurations
echo "Linking Global Configurations..."
mkdir -p ~/.gemini
ln -sfn ~/dot-agents/GEMINI.md ~/.gemini/GEMINI.md

echo ""
echo "✅ Agent dotfiles synchronized!"
echo ""
echo "Usage:"
echo "  ./bootstrap.sh              # Overlay custom skills only (rsync copy)"
echo "  ./bootstrap.sh --symlink    # Overlay via symlinks (live-editable)"
echo "  ./bootstrap.sh --upstream   # Also install/update community skills"
echo "  ./bootstrap.sh --upstream --symlink  # Both"
