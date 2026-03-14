# dot-agents

Personal AI agent configuration — skills, workflows, and rules — synchronized across workstations.

## Architecture

```
dot-agents/
├── bootstrap.sh             # Install upstream + overlay custom skills + link workflows
├── upstream-sources.txt     # Git-tracked list of community skill repos
├── custom-skills/           # Personal skills (always override community)
│   ├── beautiful-mermaid/
│   ├── markdown-new/
│   ├── system-design-mentor/
│   └── third-opinion/
└── shared-workflows/        # Global rules and workflow definitions
    ├── antigravity-global-rules.md
    └── model_evaluation.md
```

Community skills are managed by the [`skills` CLI](https://www.npmjs.com/package/skills). This repo only tracks **your own** custom skills, workflows, and the list of upstream sources.

### How it works

1. `upstream-sources.txt` lists community skill repositories (one per line).
2. `bootstrap.sh --upstream` iterates over that list and installs each via `pnpm dlx skills add`.
3. Custom skills from `custom-skills/` are `rsync`'d on top, so your overrides always win.
4. Workflows in `shared-workflows/` are symlinked to `~/.agent/workflows/`.

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

# 2. Install everything
~/dot-agents/bootstrap.sh --upstream
```

## Daily usage

| Task                          | Command                                |
| ----------------------------- | -------------------------------------- |
| Apply custom skill changes    | `~/dot-agents/bootstrap.sh`            |
| Full sync (upstream + custom) | `~/dot-agents/bootstrap.sh --upstream` |
| Quick-update community skills | `pnpm dlx skills update`               |

## Adding a community skill source

Add a line to `upstream-sources.txt` and run `~/dot-agents/bootstrap.sh --upstream`.

```
# Format: <source> [skill1 skill2 ...]
# Use * or omit skills to install all from that source.

sickn33/antigravity-awesome-skills *
vercel-labs/skills find-skills
some-org/repo skill-a skill-b
```

On the other machine: `git pull && ~/dot-agents/bootstrap.sh --upstream`

## Adding a custom skill

1. Create the skill:
   ```bash
   mkdir -p ~/dot-agents/custom-skills/my-new-skill
   ```
2. Write `SKILL.md` with YAML frontmatter (`name`, `description`) and markdown instructions.
3. Deploy: `~/dot-agents/bootstrap.sh`
4. Commit & push.

## Custom skills

| Skill                  | Description                                                            |
| ---------------------- | ---------------------------------------------------------------------- |
| `system-design-mentor` | Staff-level engineering mentor for Frontend and Backend system design. |
| `markdown-new`         | Convert public web pages into clean Markdown via markdown.new.         |
| `beautiful-mermaid`    | Create, style, and render beautiful Mermaid diagrams.                  |
| `third-opinion`        | Consult an alternative AI model via CLI (Copilot or Claude Code).      |

## Workflows

| Workflow                   | Description                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------ |
| `antigravity-global-rules` | Global operating principles: safety boundaries, planning discipline, and coding standards. |
| `model_evaluation`         | Framework to evaluate and compare new or existing models for codebase tasks.               |
