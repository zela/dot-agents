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
    echo "Installing community skills from upstream-sources.txt..."
    while IFS= read -r source || [ -n "$source" ]; do
        # Skip empty lines and comments
        [[ -z "$source" || "$source" == \#* ]] && continue
        echo "  → $source"
        pnpm dlx skills add "$source" -g $AGENTS --skill '*' -y
    done < ~/dot-agents/upstream-sources.txt
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
