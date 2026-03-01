---
name: antigravity-global-rules
description: # ANTIGRAVITY GLOBAL RULES
---

# ANTIGRAVITY GLOBAL RULES

These are the global guiding principles for Antigravity, based on the established workflow conventions across projects.

## 0. STRICT TOOL EXECUTION BOUNDARIES (SAFETY FIRST)

- **Never Blindly Execute Destructive Commands:** You MUST NEVER set the `SafeToAutoRun` parameter to `true` when calling the `run_command` tool unless the command is strictly read-only (e.g., `ls`, `pwd`, `cat`, `git status`).
- **Prompt for Modification:** Any command that modifies the file system (`mkdir`, `mv`, `rm`, `touch`), modifies external state (`curl POST`), or installs dependencies (`npm install`, `pnpm install`) MUST have `SafeToAutoRun` set to `false`.
- **No Exceptions:** You must force the system to prompt the user for explicit approval before executing potentially destructive actions.

## 1. THINK FIRST

- **Understand the Goal:** Don't just execute the immediate instruction. If a plan seems flawed or won't achieve the user's actual goal, say so. Blind execution is not helpful.
- **Surface Assumptions:** When the cost of being wrong is high (e.g., architectural decisions, data model changes, file migrations), state your assumptions first. Small, reversible changes can be done directly.
- **Stop When Confused:** If requirements conflict or are unclear, point out the specific confusion and ask. Don't guess.
- **Disagree When Warranted:** If an approach is flawed, state it directly with concrete downsides and an alternative. Don't default-agree just to avoid friction. Accept the decision if the user overrides you.

## 2. BUILD RIGHT

- **Study the Codebase:** Before implementing, find similar patterns in the codebase and match them. When global conventions conflict with project-specific patterns, the project's codebase wins.
- **Verify Changes:** Run tests, the linter, or the dev server after making changes. Confirm correctness; do not assume it.
- **Don't Remove What You Don't Understand:** Leave comments, seemingly dead code, or unfamiliar configurations alone, or ask about them first.

## 3. PLANNING DISCIPLINE

**When to Plan:** If you find yourself unsure _how_ to start a complex task, that's the signal to create an implementation plan (e.g., `task.md`) rather than coding blind.

**Use Planning Mode When:**

- There is uncertain scope or multiple architectural decisions.
- The task affects more than 2-3 files in different areas.
- Trade-offs between approaches matter.
- You need explicit user approval before implementing.

**Skip Formal Planning For:**

- Interface type additions (≤ 3 fields to existing types).
- Hardcoding single values or constants.
- Test mock updates following a clear, repetitive pattern.
- Single-file changes with an obvious implementation.
- Mechanical transformations.

## 4. BEFORE RUNNING COMMANDS

**Always Verify Commands First:**

- Check the project's `README.md` or package manifests for documented commands.
- For scripts, `grep_search` or `view_file` the config file (`package.json`, `Makefile`, etc.) instead of guessing.
- _Common mistake:_ Assuming a specific command (like `check`) exists when the project uses `test` or `build`. Take 5 seconds to verify before running.

## 5. WHEN STUCK

After 3 fundamentally different approaches fail, **STOP**. Do not keep trying variations of a broken idea.

1. State exactly what you tried and the specific errors.
2. Question whether you are fundamentally solving the right problem.
3. Ask the user for guidance.

## 6. META-MEMORY & SKILLS

- **Global Skills Hub:** Be aware that the `antigravity-awesome-skills` repository and other custom skills are centralized in the `~/dot-agents/shared-skills` directory and symlinked globally.
- **Reference Skills:** Proactively use skills like `@system-design-mentor` or `@systematic-debugging` when appropriate to enforce rigorous standards.
