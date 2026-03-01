#!/bin/bash
# ~/dot-agents/bootstrap.sh

echo "Starting Agent Dotfiles Synchronization..."

# 1. Antigravity (Gemini) Skills 
echo "Linking Antigravity Skills..."
mkdir -p ~/.gemini/antigravity
# Remove existing dir/symlink to prevent nesting issues
rm -rf ~/.gemini/antigravity/skills
ln -sfn ~/dot-agents/shared-skills ~/.gemini/antigravity/skills

# 2. Claude Skills
echo "Linking Claude Skills..."
mkdir -p ~/.claude
# Claude typically looks for global custom tools or context depending on the setup. 
# We'll link to a specific skills folder so Claude can index them.
rm -rf ~/.claude/skills
ln -sfn ~/dot-agents/shared-skills ~/.claude/skills

# 3. Legacy Agent Folder (just to keep paths we previously used from breaking)
echo "Linking Legacy ~/.agent folder..."
mkdir -p ~/.agent
rm -rf ~/.agent/skills
ln -sfn ~/dot-agents/shared-skills ~/.agent/skills

# 4. Global Workflows
echo "Linking Global Workflows..."
mkdir -p ~/dot-agents/shared-workflows
mkdir -p ~/.agent
rm -rf ~/.agent/workflows
ln -sfn ~/dot-agents/shared-workflows ~/.agent/workflows

echo "✅ Agent dotfiles symlinked successfully!"
echo "To sync with another machine, push this repo, pull it there, and run this script."
