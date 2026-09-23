# dot-agents

Personal AI agent configuration — skills, workflows, and rules — synchronized across workstations.

## Architecture

```
dot-agents/
├── AGENTS.md                # Canonical host-neutral working policy
├── CLAUDE.md                # Claude Code imports and additions
├── bootstrap.sh             # Install skills and link global configuration
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
├── hooks/                   # Claude Code hooks, wired from ~/.claude/settings.json
│   └── block-dangerous-git.sh
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
5. The bootstrap script links the Claude Code, Codex, and Gemini instruction files to their global locations.

### Supported agents

| Agent                | Global skills path              |
| -------------------- | ------------------------------- |
| Claude Code          | `~/.claude/skills/`             |
| Codex                | `~/.agents/skills/`             |
| Antigravity (Gemini) | `~/.gemini/antigravity/skills/` |
| GitHub Copilot       | `~/.agents/skills/`             |

### Global instructions

| Agent       | Installed path          | Repository source |
| ----------- | ----------------------- | ----------------- |
| Claude Code | `~/.claude/CLAUDE.md`  | `CLAUDE.md`       |
| Codex       | `~/.codex/AGENTS.md`    | `AGENTS.md`       |
| Gemini      | `~/.gemini/GEMINI.md`   | `GEMINI.md`       |

`AGENTS.md` is the canonical host-neutral policy. `CLAUDE.md` imports it and adds Claude Code instructions. Put portable changes in `AGENTS.md`.

Comment density defaults to human-team standards. A project opts into denser context comments by putting the line `Agent-maintained codebase.` in its own instruction file. The rule is in the Comments section of `AGENTS.md`.

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
| `census`                | Survey a whole codebase and maintain findings as a persistent, reconciled ledger under `docs/census/`. Host-agnostic; complements `code-review`. |
| `complexity-optimizer`  | Find algorithmic complexity hotspots — nested loops, N+1 queries, avoidable O(n²) — and report or fix. |
| `cross-engine-check`    | Observe a CSS/layout claim in Firefox, WebKit and Chromium instead of inferring it from spec knowledge. |
| `decision-record`       | Capture a design/architecture decision as a terse ADR under `docs/adr/` — options, trade-off, what breaks if wrong. Closes the Design-phase gap; `census` reads it as by-design. |
| `design-a-feature`      | Generate radically different UI/UX designs for one feature by varying the interaction pattern.      |
| `design-an-interface`   | Generate radically different interface designs for one module ("design it twice"). Carries the deep-module vocabulary, the dependency categories, and subagent-per-variant. |
| `diagnosing-bugs`       | Disciplined loop for hard bugs: a red feedback loop first, minimise, 3–5 falsifiable hypotheses, tagged instrumentation, regression test at a correct seam. Vendored from mattpocock/skills. |
| `domain-modeling`       | Build the project's glossary in `CONTEXT.md`: challenge fuzzy terms, stress-test with scenarios, record the canonical word. Decisions go to `decision-record`. Vendored from mattpocock/skills. |
| `grammar-tutor`         | Gentle English grammar and style tutor.                                                            |
| `grill-me`              | Interview the user relentlessly about a plan: a design tree worked in rounds, facts fetched by the agent, decisions left to the user, done when the frontier is empty. |
| `multi-session-plan`    | Break a large build into a sequenced roadmap of linked docs under `docs/`. Expand–contract for wide refactors; the roadmap holds the fog. |
| `prototype`             | Throwaway code that answers one design question: N structurally different UI variants on one route, or a single-file HTML state-machine demo. Vendored from mattpocock/skills. |
| `resolving-merge-conflicts` | Resolve an in-progress merge or rebase hunk by hunk, by intent traced to each side's primary source. Never `--abort`; waits for a yes before the final commit. |
| `review-mr`             | Review the current GitLab MR branch and save findings as ready-to-paste MR comments. Adds a Spec axis against the MR description and an MR-description template on request. |
| `review-staged`         | Review the staged diff, stress-test findings, fix survivors, commit granularly.                    |
| `run-state`             | Execute a long-horizon many-step run (bulk migration, backlog, long refactor) via an external state file, so context stays bounded and the session can be `/clear`'d and resumed. |
| `ship-session`          | Close out a build session: verify acceptance, convert the plan to as-built, commit. No code review. |
| `simple-english`        | Rewrite technical docs/runbooks/SKILL.md with ASD-STE100 (Simplified Technical English) discipline. Vendored (MIT); scoped to technical writing so it doesn't collide with `stop-slop`. |
| `system-design-mentor`  | Staff-level engineering mentor for Frontend and Backend system design.                             |
| `third-opinion`         | Consult an alternative AI model via CLI (Copilot or Claude Code).                                  |

Skills only ever typed by hand (`census`, `review-mr`, `review-staged`, `run-state`, `ship-session`) carry `disable-model-invocation: true` and an `agents/openai.yaml` policy, so their descriptions cost no context on any host.

## Adopted community skills

Installed unchanged from [mattpocock/skills](https://github.com/mattpocock/skills) through `upstream-sources.txt`; see [the evaluation](docs/notes/mattpocock-skills-eval.md) for what was taken, harvested, and skipped.

| Skill                | Description                                                                                       |
| -------------------- | ------------------------------------------------------------------------------------------------- |
| `tdd`                | Red-green loop at pre-agreed seams; three test anti-patterns; mock only at system boundaries.     |
| `research`           | Background agent, primary sources only, cited markdown saved in the repo.                         |
| `to-questionnaire`   | Turn a decision someone else holds the facts for into a questionnaire; grills the send, not the subject. |
| `handoff`            | Compact the conversation into a portable file for another harness, directory, or colleague.      |
| `writing-for-agents` | How to write skills and steering files: context pointers, the two loads, leading words, no-ops. |
| `teach`              | Multi-session learning workspace: mission, HTML lessons, reference sheets, learning records.     |

## Hooks

`hooks/block-dangerous-git.sh` is a Claude Code `PreToolUse` hook on `Bash`. It blocks force pushes, `reset --hard`, `clean -f`, `branch -D`, `checkout .`, `restore .`, and `stash drop|clear` before they run, so the git rules in `AGENTS.md` are binding rather than advisory. Plain `git push` stays allowed, because `AGENTS.md` permits a push the user asked for. It is wired from `~/.claude/settings.json` (not tracked here) as the first hook under the `Bash` matcher:

```json
{ "type": "command", "command": "\"$HOME\"/dot-agents/hooks/block-dangerous-git.sh" }
```

## Passive skills

Present in the repo but **not** installed by `bootstrap.sh` (which only overlays `custom-skills/`). Move one into `custom-skills/` to activate it.

| Skill               | Description                                                             |
| ------------------- | ------------------------------------------------------------------------- |
| `beautiful-mermaid` | Create, style, and render beautiful Mermaid diagrams.                   |
| `markdown-new`      | Convert public web pages into clean Markdown via markdown.new.          |
| `caveman`           | Ultra-compressed caveman-speak reply mode (`CAVEMAN-SKILL.md`, no dir). |

## Custom agents

The bootstrap script deploys these subagent definitions to `~/.claude/agents/` for Claude Code. Codex supports subagents, but Claude Code agent files need adaptation. Put portable behavior in a skill. The `--upstream` option keeps hand-written agents in `~/.claude/agents/`.

| Agent      | Description                                                                                        |
| ---------- | ---------------------------------------------------------------------------------------------------- |
| `verifier` | Re-checks a single claim against the source with no prior context. Reports REPRODUCES / DOES-NOT-REPRODUCE with `file:line` evidence. |

Add one by dropping a `.md` file with `name` / `description` frontmatter into `custom-agents/`, then running `~/dot-agents/bootstrap.sh`.

## Workflows

| Workflow                   | Description                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------ |
| `antigravity-global-rules` | Global operating principles: safety boundaries, planning discipline, and coding standards. |
| `model_evaluation`         | Framework to evaluate and compare new or existing models for codebase tasks.               |
