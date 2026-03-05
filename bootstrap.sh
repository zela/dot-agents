#!/bin/bash
# ~/dot-agents/bootstrap.sh
#
# Community skills are managed by `pnpm dlx skills`.
# This script overlays your personal custom skills on top,
# ensuring your overrides always win over community defaults.

AGENTS="-a claude-code -a antigravity -a github-copilot"

echo "Starting Agent Dotfiles Synchronization..."

# 1. Install/update community skills (if requested with --upstream flag)
if [ "$1" = "--upstream" ]; then
    echo "Cleaning existing skills..."
    rm -rf ~/.claude/skills ~/.gemini/antigravity/skills ~/.agents/skills
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
echo "Overlaying custom skills..."
CUSTOM_DIR=~/dot-agents/custom-skills
AGENT_DIRS=(
    ~/.claude/skills
    ~/.gemini/antigravity/skills
    ~/.agents/skills
)

for dir in "${AGENT_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        rsync -a "$CUSTOM_DIR/" "$dir/"
        echo "  ✓ $dir"
    else
        echo "  ⚠ $dir not found, skipping"
    fi
done

# 3. Global Workflows
echo "Linking Global Workflows..."
mkdir -p ~/.agent
rm -rf ~/.agent/workflows
ln -sfn ~/dot-agents/shared-workflows ~/.agent/workflows

echo ""
echo "✅ Agent dotfiles synchronized!"
echo ""
echo "Usage:"
echo "  ./bootstrap.sh              # Overlay custom skills only"
echo "  ./bootstrap.sh --upstream   # Also install/update community skills"
