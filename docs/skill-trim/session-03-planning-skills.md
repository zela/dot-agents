# Session 03 — Planning skills

**Goal:** Trim `multi-session-plan`, `parallel-sessions` and `run-state`, and give "join" one meaning across the planning skills.

**Prerequisites:** none.

## Tasks

1. **Settle "join" with the user.** In `multi-session-plan:66` it is the session where two tracks merge. In `parallel-sessions` it is the merge of a wave of sessions into `main`. Propose one name for each meaning, ask the user, and record the settled term in `CONTEXT.md` in its format.
2. **`multi-session-plan`.**
   - `:27-32` "Why this shape works" (R2). `:29` repeats `:10` and `:93`; `:31` repeats `:66` and the overview template `:39`; `:32` repeats the template's decisions log.
   - `:70` wide refactors / expand–contract (R4): only plans with a wide refactor need it. Move it to a reference file behind a pointer.
   - Data-model optionality is said at `:16`, `:23`, `:59` "(if any)", `:103` and the data-model template `:5`. Keep `:16` and `:103` (R5).
   - `:97-99` status legend repeats the overview template `:27` and `:93` (R5).
   - `:25` "Read them… do not reinvent the structure" vs `:74` "Use the templates" (R5, R6).
   - `:36` "Do not jump straight to writing docs…" (R6, R7: the step order enforces it). `:95` "The plan is a living document…" (R7).
   - `:74` "an empty 'Out-of-scope' is a smell" repeats the session template `:35`. Keep the template copy (R5).
   - `:42` "You want the conclusions, not the file dumps": maybe a no-op given `AGENTS.md` § Subagent Delegation. Unsure (R7).
   - `:55` names `AskUserQuestion`, a Claude-only tool, in a skill that several hosts load. Name the action ("ask the user"), not the tool.
   - Description (R3): "an overview, one doc per session, and a deferred-work roadmap" is body identity.
   - Tables in the templates: `AGENTS.md` § Writing asks for nested lists in Markdown docs. Convert the templates, so the next plan does not need D4 of this plan.
   - Add a pointer to `parallel-sessions` for running sessions at once; today only `parallel-sessions` (`adopt.md:5`) points the other way.
3. **`parallel-sessions`.**
   - `:29-39` "The project doc" caches the field list of `assets/project-doc.md`; `:31` repeats `:10`. Point at the template (R5).
   - `:19-27` Usage holds prompts the human types. The setup script prints them (`adopt.md:14` points here). Move them to `adopt.md` or the project-doc template (R4).
   - `:61` "(inferred from the configs, not tested)", `:62` the Claude Code `baseRef` detail (`adopt.md:24` covers it), and `:67` "It refused 73 actions in one wave (2026-10-28)" are evidence; move it to a note under `docs/notes/` (R2). `coordinator.md:9` "Six branches… four merge conflicts" stays; it drives the "keep it small" rule.
   - The rule-8 staging bullet at `:52` is repeated at `coordinator.md:22`. Make the coordinator cite rule 8 (R5).
   - "Removing them is the user's call" at `:73`, `coordinator.md:37` and `:46` (R1).
   - `:14` repeats `project-doc.md:7` and `:63`/`:65` on primary-only state (R5).
   - Description (R3): "Covers the rules for a worktree session, its setup and its review." is body identity.
4. **`run-state`.**
   - Description (R3): user-invoked, 77 words with rationale, triggers and exclusions. One line.
   - `:9-11` "quadratic growth" and "payoff" rationale. The source is in the `<sub>` line and `docs/notes/skill-state-and-the-ledger-pattern.md` (R2).
   - `:13-23` "Where this fits" (R2). Keep the `:21` archetype if it changes behaviour.
   - `:37`, `:38`, `:40` repeat the rules at `:45`/`:46`: cold-resume test, one unit, discard reasoning (R5).
   - `:49` no-commit rule, and the template `:11` copy (R1).
   - `:50` "Match the codebase" (R1). Keep the gates clause.
   - `:54` and `:56-58` summarize the loop twice (R2, R5).
   - Defect: the template `:18` has a "→ in progress" status that the loop at `:39` never sets. Either the loop sets it or the template drops it.
5. **Cross-skill.** `multi-session-plan:67` ("one session that creates" each shared artifact) overlaps `parallel-sessions` rule 6. Keep the rule in `multi-session-plan` (planning time) and make rule 6 cite it.

## Files to create / modify

- `CONTEXT.md`: the "join" terms.
- `custom-skills/multi-session-plan/SKILL.md`, its `assets/templates/*`, and a new reference file for wide refactors.
- `custom-skills/parallel-sessions/SKILL.md`, `references/coordinator.md`, `references/adopt.md`, `assets/project-doc.md`.
- `custom-skills/run-state/SKILL.md`, its template.
- A note under `docs/notes/` for the `parallel-sessions` evidence, or an existing note that fits.

## Reuse references (read-only)

- `CONTEXT.md`: the entry format (`**Term**:`, definition, `_Avoid_:`).
- `docs/notes/skill-state-and-the-ledger-pattern.md`: where `run-state` rationale already lives.

## Acceptance / verification

- The overview's acceptance procedure.
- `grep -rn "\bjoin" custom-skills/multi-session-plan custom-skills/parallel-sessions` shows each use matching one of the two settled terms.
- `grep -rn AskUserQuestion custom-skills` returns nothing outside Claude-only skills.

## Out of scope

- `doc-check`, which overlaps `multi-session-plan:88` on real output: Session 05.
- A shared "read the context" preamble in `AGENTS.md`: roadmap.

**Considered and not built:**

- Merging `run-state` into `multi-session-plan`: they serve different shapes of work (a long procedure vs a sequenced build).
