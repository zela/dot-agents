# Session 01 — grammar-tutor

**Goal:** Fix `grammar-tutor` so it works when it is turned on again, then move it to `passive-skills/` (D3).

**Status:** done on 2026-11-25, in commits `48bf995` and `9e9d41d`. The word counts are in the overview's session index.

**Prerequisites:** none.

## Tasks

1. **How a skill loads a hook.** Before the change, a grep of `~/.claude/settings.json` and `bootstrap.sh` for `grammar` and `evaluate.sh` found nothing (executed 2026-11-25). The `claude-code-guide` agent answered on 2026-11-25:
   - A skill declares hooks in its `SKILL.md` frontmatter under `hooks:`, in the settings format.
   - The hooks register when the user or the model invokes the skill. They stay registered until `/clear`, `/resume` or exit.
   - `hooks/hooks.json` loads only from a plugin root, so the old hook never registered.
   - Sources: https://code.claude.com/docs/en/skills.md (frontmatter table, `hooks` row) and https://code.claude.com/docs/en/hooks.md ("Hooks in skills and agents").
   - The docs show no `UserPromptSubmit` example for a skill hook. This case is untested.
2. **Claude Code branch.** The `UserPromptSubmit` hook is in the `SKILL.md` frontmatter and runs `evaluate.sh` from the deployed skill folder. `hooks/hooks.json` is removed, with the user's OK. The hook fires only after the user invokes the skill, so the prompt that invokes it is not evaluated. `evaluate.sh` also skips prompts that start with `/`.
   - Not chosen: a `settings.json` entry. That hook can also fire inside the `claude --print` call that `evaluate.sh` makes, and then the hook recurses. The child session does not register a skill-scoped hook. Both points are inferred, not tested.
3. **Model name.** `SKILL.md` says "Haiku". The model is named once, as `--model haiku` in `hooks/evaluate.sh:9`. The old `SKILL.md` named `claude-3-5-haiku-20241022`, which the script never used.
4. **First-sentence instruction.** Cut from `SKILL.md`, because `evaluate.sh:14` injects it (R5). The example lead-in "By the way, a more natural way…" went with it.
5. **Antigravity branch.** `SKILL.md` points at the workflow by its deployed path, `~/.agent/workflows/grammar-hook.md` (`bootstrap.sh:157`), which holds the same steps (R5). The deployed skill folder does not contain `shared-workflows/`.
   - Deviation: the plan said to point at the workflow's new place if task 7 moved it. The pointer keeps the deployed path. An agent reads the skill only when the skill is active, and at that time the workflow is back in `shared-workflows/`.
6. **"Do not stall… do not refuse to answer"** is cut (R7). `evaluate.sh:14` and the workflow already tell the agent to go on with the request.
7. **Workflow.** The user said yes. `grammar-hook.md` moved to `passive-skills/grammar-hook.md`, and the README passive skills section has a `grammar-hook` row. Without the move, the Antigravity hook stays live, because `bootstrap.sh:157` links all of `shared-workflows/` into `~/.agent/workflows`.
8. **Move.** `custom-skills/grammar-tutor/` moved to `passive-skills/grammar-tutor/` with `git mv` (the user consented on 2026-11-25). `evaluate.sh` is unchanged.
9. **Living docs.** The README row moved from the custom skills table to the passive skills section. The entry in `docs/user-invoked-skills.md` is removed.

## Deviations and gotchas

- The user approved one cut that the plan did not name: the old line "Whenever the user sends a message, you must secretly evaluate…". In Claude Code the hook is the only evaluator. In Antigravity the workflow evaluates.
- To turn the skill on again, move both files back: `passive-skills/grammar-tutor/` to `custom-skills/`, and `passive-skills/grammar-hook.md` to `shared-workflows/`. If only the skill moves, the Antigravity pointer names a file that does not exist. The README passive skills rows say this.
- `review-staged` found 15 writing-rule breaks in this session's edits. They were fixed before the commit.

## Files changed

- `custom-skills/grammar-tutor/SKILL.md` → `passive-skills/grammar-tutor/SKILL.md`: the fixes, then the move.
- `custom-skills/grammar-tutor/hooks/evaluate.sh` → `passive-skills/grammar-tutor/hooks/evaluate.sh`: moved, unchanged. `hooks/hooks.json` is removed.
- `shared-workflows/grammar-hook.md` → `passive-skills/grammar-hook.md`: moved, unchanged.
- `README.md`, `docs/user-invoked-skills.md`: the skill lists.

## Reuse references (read-only)

- `bootstrap.sh:70-90`: the manifest loop. A name in `.custom-skills.prev` without a `custom-skills/<name>/SKILL.md` is removed from every deployed skills directory on the next run. So the move needs no manual cleanup of `~/.claude/skills`.
- `README.md:192`: the passive skills section and its format.

## Acceptance / verification

Run on 2026-11-25.

- The overview's acceptance procedure, steps 1–3 and 5–6:
  1. Word counts: `wc -w` before (`48bf995^`) and after, executed again when the session shipped. They are in the session index.
  2. Replacement check: at ship time, an independent subagent compared `48bf995^` with `HEAD`, the old `custom-skills/` version with the new `passive-skills/` version. Each change it found is named in the tasks above.
  3. `review-staged` ran on the staged session diff before commit `48bf995`, in the session that built it. Its fixes went into that commit.
  5. `passive-skills/grammar-tutor/SKILL.md` has `name: grammar-tutor` and a `description`.
  6. The user asked for the commits.
- `grep -rn grammar-tutor README.md docs/user-invoked-skills.md docs/notes/skill-flow.md custom-skills` finds only the `grammar-tutor` and `grammar-hook` rows in the README passive skills section. Session 02 removed the routing lines that this check allowed.
- The task 1 answer is in the body of commit `48bf995`, with its sources.
- After the user ran `bootstrap.sh` on 2026-11-25, `ls ~/.claude/skills/grammar-tutor` and `ls ~/.agents/skills/grammar-tutor` fail. The run removed `grammar-tutor` from the tracked `.custom-skills.prev` (`bootstrap.sh:107`), and that change was committed with the ship commit.

## Out of scope

- The `grammar-tutor` mentions in the `stop-slop` and `simple-english` descriptions: Session 02 removed them.
- A test run of the hook. The skill is passive; testing waits until the user turns it on.

**Considered and not built:**

- Deleting the skill instead of moving it: the user wants it kept for later (D3).
