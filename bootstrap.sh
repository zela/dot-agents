#!/bin/bash
# ~/dot-agents/bootstrap.sh

echo "Starting Agent Dotfiles Synchronization..."

# Compile the final .merged-skills directory
echo "Merging upstream and custom skills..."
mkdir -p ~/.merged-skills
# 1. Start with copying everything from the community upstream
rsync -a --exclude='.git' ~/dot-agents/upstream-skills/ ~/.merged-skills/
# 2. Overwrite with your personal custom skills 
rsync -a ~/dot-agents/custom-skills/ ~/.merged-skills/

# 1. Antigravity (Gemini) Skills 
echo "Linking Antigravity Skills..."
mkdir -p ~/.gemini/antigravity
rm -rf ~/.gemini/antigravity/skills
ln -sfn ~/.merged-skills ~/.gemini/antigravity/skills

# 2. Claude Skills
echo "Linking Claude Skills..."
mkdir -p ~/.claude
rm -rf ~/.claude/skills
ln -sfn ~/.merged-skills ~/.claude/skills

# 3. Legacy Agent Folder
echo "Linking Legacy ~/.agent skills folder..."
mkdir -p ~/.agent
rm -rf ~/.agent/skills
ln -sfn ~/.merged-skills ~/.agent/skills

# 4. Global Workflows
echo "Linking Global Workflows..."
mkdir -p ~/dot-agents/shared-workflows
mkdir -p ~/.agent
rm -rf ~/.agent/workflows
ln -sfn ~/dot-agents/shared-workflows ~/.agent/workflows

echo "✅ Agent dotfiles symlinked and merged successfully!"
echo "To sync with another machine, push this repo, pull it there, and run this script."
