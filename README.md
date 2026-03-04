# dot-agents

Personal AI agent configuration — skills, workflows, and rules — synchronized across workstations.

## Architecture

```
dot-agents/
├── bootstrap.sh           # Overlay custom skills & link workflows
├── custom-skills/          # Personal skills (always override community)
│   ├── system-design-mentor/
│   └── markdown-new/
└── shared-workflows/       # Global rules and workflow definitions
    └── antigravity-global-rules.md
```

Community skills (from [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills)) are managed externally by the [`skills` CLI](https://www.npmjs.com/package/skills). This repo only tracks **your own** custom skills and workflows.

### How it works

1. **Community skills** are installed globally via `pnpm dlx skills` into each agent's native directory (`~/.claude/skills`, `~/.gemini/antigravity/skills`, `~/.agents/skills`).
2. **Custom skills** from `custom-skills/` are `rsync`'d on top, so your overrides always win if there's a name collision.
3. **Workflows** in `shared-workflows/` are symlinked to `~/.agent/workflows` for global access.

### Supported agents

| Agent                | Global skills path              |
| -------------------- | ------------------------------- |
| Claude Code          | `~/.claude/skills/`             |
| Antigravity (Gemini) | `~/.gemini/antigravity/skills/` |
| GitHub Copilot       | `~/.agents/skills/`             |

## Setup on a new machine

```bash
# 1. Clone this repo
git clone <your-remote> ~/dot-agents

# 2. Install community skills + overlay custom ones
~/dot-agents/bootstrap.sh --upstream
```

## Daily usage

```bash
# Update community skills to latest
pnpm dlx skills update

# Apply custom skill overrides after editing
~/dot-agents/bootstrap.sh

# Do both at once (update upstream + overlay custom)
~/dot-agents/bootstrap.sh --upstream
```

## Adding a custom skill

```bash
# Create the skill directory
mkdir -p ~/dot-agents/custom-skills/my-new-skill

# Write the SKILL.md (name + description in YAML frontmatter, instructions in markdown)
cat > ~/dot-agents/custom-skills/my-new-skill/SKILL.md << 'EOF'
---
name: my-new-skill
description: What this skill does and when to use it.
---

# My New Skill

Instructions for the agent...
EOF

# Deploy it
~/dot-agents/bootstrap.sh

# Commit
cd ~/dot-agents && git add -A && git commit -m "Add my-new-skill"
```

## Custom skills

| Skill                  | Description                                                                                                              |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `system-design-mentor` | Staff-level engineering mentor for Frontend and Backend system design using Socratic questioning and trade-off analysis. |
| `markdown-new`         | Convert public web pages into clean Markdown via markdown.new for AI workflows.                                          |

## Workflows

| Workflow                   | Description                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------ |
| `antigravity-global-rules` | Global operating principles: safety boundaries, planning discipline, and coding standards. |
