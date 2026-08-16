# dot-agents

Personal AI agent configuration — skills, workflows, and rules — synchronized across workstations.

## Architecture

```
dot-agents/
├── bootstrap.sh             # Install upstream + overlay custom skills + link workflows
├── upstream-sources.txt     # Git-tracked list of community skill repos
├── custom-skills/           # Personal skills (deployed; always override community)
│   ├── complexity-optimizer/
│   ├── review-staged/
│   ├── system-design-mentor/
│   └── ...                  # see "Custom skills" below
├── passive-skills/          # Kept in repo, NOT deployed by bootstrap.sh
│   ├── beautiful-mermaid/
│   └── markdown-new/
├── custom-agents/           # Subagent definitions → ~/.claude/agents/ (Claude Code only)
│   └── verifier.md
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

| Skill                   | Description                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------------------- |
| `complexity-optimizer`  | Find algorithmic complexity hotspots — nested loops, N+1 queries, avoidable O(n²) — and report or fix. |
| `cross-engine-check`    | Observe a CSS/layout claim in Firefox, WebKit and Chromium instead of inferring it from spec knowledge. |
| `design-a-feature`      | Generate radically different UI/UX designs for one feature by varying the interaction pattern.      |
| `design-an-interface`   | Generate radically different interface designs for one module ("design it twice").                 |
| `grammar-tutor`         | Gentle English grammar and style tutor.                                                            |
| `grill-me`              | Interview the user relentlessly about a plan until shared understanding is reached.                |
| `multi-session-plan`    | Break a large build into a sequenced roadmap of linked docs under `docs/`.                         |
| `review-mr`             | Review the current GitLab MR branch and save findings as ready-to-paste MR comments.               |
| `review-staged`         | Review the staged diff, stress-test findings, fix survivors, commit granularly.                    |
| `ship-session`          | Close out a build session: verify acceptance, convert the plan to as-built, commit. No code review. |
| `system-design-mentor`  | Staff-level engineering mentor for Frontend and Backend system design.                             |
| `third-opinion`         | Consult an alternative AI model via CLI (Copilot or Claude Code).                                  |

## Passive skills

Present in the repo but **not** installed by `bootstrap.sh` (which only overlays `custom-skills/`). Move one into `custom-skills/` to activate it.

| Skill               | Description                                                             |
| ------------------- | ------------------------------------------------------------------------- |
| `beautiful-mermaid` | Create, style, and render beautiful Mermaid diagrams.                   |
| `markdown-new`      | Convert public web pages into clean Markdown via markdown.new.          |
| `caveman`           | Ultra-compressed caveman-speak reply mode (`CAVEMAN-SKILL.md`, no dir). |

## Custom agents

Subagent definitions, deployed to `~/.claude/agents/`. **Claude Code only** — antigravity and copilot have no equivalent, so anything that must work everywhere belongs in a skill instead. Hand-written agents already in `~/.claude/agents/` are left alone; `--upstream` does not wipe that directory.

| Agent      | Description                                                                                        |
| ---------- | ---------------------------------------------------------------------------------------------------- |
| `verifier` | Re-checks a single claim against the source with no prior context. Reports REPRODUCES / DOES-NOT-REPRODUCE with `file:line` evidence. |

Add one by dropping a `.md` file with `name` / `description` frontmatter into `custom-agents/`, then running `~/dot-agents/bootstrap.sh`.

## Workflows

| Workflow                   | Description                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------ |
| `antigravity-global-rules` | Global operating principles: safety boundaries, planning discipline, and coding standards. |
| `model_evaluation`         | Framework to evaluate and compare new or existing models for codebase tasks.               |
