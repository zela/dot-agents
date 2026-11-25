# Session 07 — Code skills

**Goal:** Trim `craft`, `diagnosing-bugs` and `prototype`, make small fixes in `diagram`, `cross-engine-check` and `resolving-merge-conflicts`, and fix the routing defects in this group.

**Prerequisites:** none. If Session 06 has run, `prototype/SKILL.md:13` already names `design-it-twice`.

## Tasks

1. **`craft`.**
   - Description (R3): model-invoked, 77 words. Cut the two parenthetical check lists; the body carries them. Keep the triggers.
   - Defect: `:8` "Domain words belong to `domain-modeling`" routes the model to a user-invoked skill it cannot start. Tell the agent to suggest the skill to the user instead, or cut the line.
   - `:47` Root cause restates `AGENTS.md` "find the cause … lowest safe shared layer" (R1). Keep its routing clause "Give a real bug to `diagnosing-bugs`"; that skill is model-invoked.
   - `:50` "It examines reuse … rarely reports them" is rationale the `simplify` description already gives (R2).
   - `:41` "Make sure that the diff passes the type checker and the linter": maybe a no-op; the list of escapes (`any`, `as`, `@ts-ignore`) is the part with value. Unsure (R7).
2. **`diagnosing-bugs`.**
   - `:20-22` "This phase is the skill… Be aggressive. Be creative. Do not give up.", `:37` "the bug is 90% fixed", `:66` "If you catch yourself… stop", and `:55` "Do not hypothesise without a loop" all say "the loop first". Keep one positive line (R5, R6, R7).
   - `:39-47` Tighten and `:61-63` Done checklist both state fast/sharp/deterministic. Let the leading word "tight" carry it (R5).
   - Branch-only reference: `:49-51` non-deterministic bugs, `:92` the stash protocol for uncommitted work, `:110` the performance branch. Move behind pointers (R4).
   - `:24-35` the 10-item loop menu: the model may know most of it. Candidate for R4, not a cut. Unsure.
   - `:84` "Do not continue until…" repeats its done line. `:106` "Never log everything and grep" (R6). `:108` "Tagged logs die." `:132` repeats `:126`. `:135` and `:138` restate `AGENTS.md` on delete and commit (R1).
   - Description (R3): "broken, throwing, failing" is one branch.
   - `:118` names `design-an-interface`. Session 06 changes that line to `design-it-twice`; leave it to that session.
3. **`prototype`.**
   - Description (R3): user-invoked, but it carries a trigger list ("Use when the user wants…"). One human line.
   - `SKILL.md:11-13` "Where this fits" (R2). Keep the line that routes to `design-it-twice` for paper designs if it changes what the agent does.
   - `LOGIC.md:7-14` and `UI.md:5-12` "When this is the right shape": `SKILL.md:15-22` picks the branch before either file is read (R5).
   - `LOGIC.md:60-67` Anti-patterns: all negation, nearly every line repeats an earlier rule. Keep `:67` at most (R5, R6).
   - `UI.md:14-30` says "prefer sub-shape A" about five times. Say it once (R5).
   - `UI.md:111` repeats `:54`; `UI.md:114` repeats rule 4; `LOGIC.md:56-58` and `UI.md:100-107` restate rule 6 (R5).
   - Defect: `UI.md:3` "then throws the rest away" contradicts rule 6, which proposes the cleanup to the user.
   - `SKILL.md:19` and `MERMAID.md:15` (in `diagram`) "Artifact tool can publish…" restate the host's tool description (R7).
4. **`diagram`.**
   - Description (R3): the parenthetical format list is body identity.
   - `MERMAID.md:3` "about 4 KB" and `:19` "pins `mermaid@12.2.0`" cache the template; the version goes stale on upgrade (R7 as environment cache).
   - `MERMAID.md:15` the Artifact sentence (see task 3).
5. **`cross-engine-check`.**
   - `:6`: two of three sentences restate the description and `AGENTS.md` § Evidence Discipline. Keep "You are measuring, not arguing." (R1, R5).
   - `:83-85` Cleanup: keep "Say where they are."; the deletion clause is R1.
   - Description (R3): "vendor prefixes" and "`-moz-`/`-webkit-` behavior" are one branch.
6. **`resolving-merge-conflicts`.**
   - Description (R3): lead with the trigger: "Resolve an in-progress git merge or rebase conflict."
   - `:11-12` restate `AGENTS.md` (find the checks, wait before commit). `:12` is the deliberate change that replaced upstream's commit step; no line in the file leads the other way now. Apply R1: keep `:12` as one positive sentence only if resolving a conflict would otherwise lead the agent to `--continue` on its own, and record the call.
7. **Attribution (R8).** `diagnosing-bugs:142`, `prototype:35` and `resolving-merge-conflicts:14` say "Vendored from". Rewrite each as "Adapted from … at v1.2.3". Change `README.md:116` and `:126` from "Vendored" to "Adapted"; `README.md:117` "~4 KB" repeats the cache that task 4 cuts, so drop it there too.

## Files to create / modify

- `custom-skills/craft/SKILL.md`.
- `custom-skills/diagnosing-bugs/SKILL.md` and new sibling files for the branch material.
- `custom-skills/prototype/SKILL.md`, `LOGIC.md`, `UI.md`.
- `custom-skills/diagram/SKILL.md`, `MERMAID.md`.
- `custom-skills/cross-engine-check/SKILL.md`, `custom-skills/resolving-merge-conflicts/SKILL.md`.
- `README.md:116-117`, `:126`: task 7.
- `docs/notes/skill-flow.md` or `docs/user-invoked-skills.md`: only for a fact R2 moves.

## Reuse references (read-only)

- `AGENTS.md` § Build Right, § Evidence Discipline: the rules R1 cuts against.
- `custom-skills/prototype/LOGIC.md`, `UI.md`: the sibling-file pattern for the branch material moved out of `diagnosing-bugs`. `diagnosing-bugs` has no prose reference file yet; `scripts/hitl-loop.template.sh` is a script, not a destination.

## Acceptance / verification

- The overview's acceptance procedure.
- `grep -rn "domain-modeling" custom-skills/craft` shows no instruction to invoke it.
- `UI.md` and rule 6 agree on who removes the prototype.

## Out of scope

- `craft` scoring scripts and thresholds.
- `domain-modeling` itself: Session 06.

**Considered and not built:**

- A shared "read the context first" preamble (CONTEXT.md, ADRs, lessons by `applies_when`) for `craft:10` and `diagnosing-bugs:10`; `multi-session-plan:44` reads only lessons: roadmap.
