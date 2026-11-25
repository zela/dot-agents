# Session 01 — grammar-tutor

**Goal:** Fix `grammar-tutor` so it works when it is turned on again, then move it to `passive-skills/` (D3).

**Prerequisites:** none.

## Tasks

1. Find out how Claude Code loads a hook that belongs to a skill. The skill keeps `hooks/hooks.json` in its own folder, which looks like the plugin layout (inferred, not checked). A grep of `~/.claude/settings.json` and `bootstrap.sh` for `grammar` and `evaluate.sh` found nothing (executed 2026-11-25). Ask the `claude-code-guide` agent whether a skill can declare hooks (in frontmatter or in a folder file), and how. Record the answer with its source.
2. Fix the Claude Code branch to match that answer: either the skill declares its hook in the supported form, or `SKILL.md` names the `settings.json` entry the user adds when they turn the skill on.
3. Fix `SKILL.md:12`. It names `claude-3-5-haiku-20241022`, but `hooks/evaluate.sh:9` runs `--model haiku`. Name the model once, in the script; the skill text says "Haiku".
4. Cut from `SKILL.md:12` the instruction "gently mention… in your very first sentence"; `evaluate.sh:14` already injects it (R5).
5. Replace the Antigravity branch at `SKILL.md:14` with a pointer to the workflow `grammar-hook.md`, which holds the same steps at lines 7–13 (R5). Name it by its deployed path, `~/.agent/workflows/grammar-hook.md` (`bootstrap.sh:157`); the deployed skill folder does not contain `shared-workflows/`. If task 7 moves the file, point at its new place instead.
6. Cut `SKILL.md:16` "Do not stall… do not refuse to answer" (R7).
7. Ask the user whether `shared-workflows/grammar-hook.md` also goes passive. `bootstrap.sh:157` links all of `shared-workflows/` into `~/.agent/workflows`, so the Antigravity hook stays live otherwise. Move it only on an explicit yes, to `passive-skills/grammar-hook.md`, and add it to the README passive skills section.
8. Move `custom-skills/grammar-tutor/` to `passive-skills/grammar-tutor/` (the user consented on 2026-11-25). Use `git mv`.
9. Update the living docs:
   - `README.md:120`: move the row from the custom skills table to the passive skills section (`README.md:192`).
   - `docs/user-invoked-skills.md:29`: remove the entry.

## Files to create / modify

- `custom-skills/grammar-tutor/SKILL.md` → `passive-skills/grammar-tutor/SKILL.md`: the fixes, then the move.
- `custom-skills/grammar-tutor/hooks/` → `passive-skills/grammar-tutor/hooks/`: changed only if task 2 needs it.
- `README.md`, `docs/user-invoked-skills.md`: the skill lists.
- `shared-workflows/grammar-hook.md`: only on the user's yes in task 7.

## Reuse references (read-only)

- `bootstrap.sh:70-90`: the manifest loop. A name in `.custom-skills.prev` without a `custom-skills/<name>/SKILL.md` is removed from every deployed skills directory on the next run. So the move needs no manual cleanup of `~/.claude/skills`.
- `README.md:192`: the passive skills section and its format.

## Acceptance / verification

- The overview's acceptance procedure, steps 1–3 and 5–6. Step 2 compares the old `custom-skills/` version with the new `passive-skills/` version.
- `grep -rn grammar-tutor README.md docs/user-invoked-skills.md docs/notes/skill-flow.md custom-skills` finds only these lines. Any other hit fails the check.
  - the `grammar-tutor` row in the README passive skills section, and the `grammar-hook` row if task 7 adds one;
  - `custom-skills/stop-slop/SKILL.md:3` and `custom-skills/simple-english/SKILL.md:3` (routing) and `custom-skills/simple-english/SKILL.md:294` (`<sub>` line). Session 02 owns those three.
- The task 1 answer is recorded in the session's commit message or in the skill, with its source.
- After the user runs `bootstrap.sh`, `ls ~/.claude/skills/grammar-tutor` fails. The user runs it; this check is theirs. The run rewrites the tracked `.custom-skills.prev` (`bootstrap.sh:107`); commit that change with the session or after it.

## Out of scope

- The `grammar-tutor` mentions in `stop-slop` and `simple-english` descriptions: Session 02.
- A test run of the hook. The skill is passive; testing waits until the user turns it on.

**Considered and not built:**

- Deleting the skill instead of moving it: the user wants it kept for later (D3).
