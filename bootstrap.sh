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

    # Install current custom skills.
    # Clear the destination first — `cp -a src dst` nests when dst already
    # exists (dst/name/name), and `rm -f` cannot remove a dir left by a copy run.
    for name in "${CURRENT_NAMES[@]}"; do
        rm -rf "$dir/$name"
        if [ "$SYMLINK" = true ]; then
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

# 3. Custom subagents (Claude Code only — no antigravity/copilot equivalent)
#    Flat .md files. .custom-agents.prev tracks them so removals propagate.
#    ~/.claude/agents is NOT wiped by --upstream: hand-written agents there survive.
SUBAGENT_SRC=~/dot-agents/custom-agents
SUBAGENT_DEST=~/.claude/agents
SUBAGENT_MANIFEST=~/dot-agents/.custom-agents.prev

if [ -d "$SUBAGENT_SRC" ]; then
    echo "Installing custom subagents..."
    mkdir -p "$SUBAGENT_DEST"

    SUBAGENT_NAMES=()
    for file in "$SUBAGENT_SRC"/*.md; do
        [ -e "$file" ] && SUBAGENT_NAMES+=("$(basename "$file")")
    done

    # Remove previously installed subagents that no longer exist
    if [ -f "$SUBAGENT_MANIFEST" ]; then
        while IFS= read -r old_name; do
            [ -n "$old_name" ] && [ ! -e "$SUBAGENT_SRC/$old_name" ] && rm -f "$SUBAGENT_DEST/$old_name"
        done < "$SUBAGENT_MANIFEST"
    fi

    # Clear first: copying onto a symlink left by a prior --symlink run would
    # write through it into the repo source.
    for name in "${SUBAGENT_NAMES[@]}"; do
        rm -f "$SUBAGENT_DEST/$name"
        if [ "$SYMLINK" = true ]; then
            ln -sfn "$SUBAGENT_SRC/$name" "$SUBAGENT_DEST/$name"
        else
            cp -a "$SUBAGENT_SRC/$name" "$SUBAGENT_DEST/$name"
        fi
    done

    printf '%s\n' "${SUBAGENT_NAMES[@]}" > "$SUBAGENT_MANIFEST"
    echo "  ✓ $SUBAGENT_DEST (${#SUBAGENT_NAMES[@]})"
fi

# 4. Global Workflows
echo "Linking Global Workflows..."
mkdir -p ~/.agent
rm -rf ~/.agent/workflows
ln -sfn ~/dot-agents/shared-workflows ~/.agent/workflows

# 5. Global Configurations
echo "Linking Global Configurations..."

# 5.1 Gemini
mkdir -p ~/.gemini
ln -sfn ~/dot-agents/GEMINI.md ~/.gemini/GEMINI.md

# 5.2 Claude
ln -sfn ~/dot-agents/CLAUDE.md ~/.claude/CLAUDE.md

echo ""
echo "✅ Agent dotfiles synchronized!"
echo ""
echo "Usage:"
echo "  ./bootstrap.sh              # Overlay custom skills only (rsync copy)"
echo "  ./bootstrap.sh --symlink    # Overlay via symlinks (live-editable)"
echo "  ./bootstrap.sh --upstream   # Also install/update community skills"
echo "  ./bootstrap.sh --upstream --symlink  # Both"
