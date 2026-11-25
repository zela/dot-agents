# Session 05 — Review and ship

**Goal:** Trim the review and finish skills, restructure `ship-session`, and resolve the conflict over counts between `ship-session` and the `review-staged` prose checklist.

**Prerequisites:** none.

> **Sizing:** six skills. If it runs long, split it: 05a `ship-session`, `review-staged` and the counts conflict; 05b `review-mr`, `doc-check`, `lesson-record`, `papercuts`.

## Tasks

1. **Counts conflict.** `ship-session:68` tells the agent to update the aggregate counts the plan index tracks (test totals, page counts). `review-staged/references/prose-checklist.md:13` flags counts in living text as "Regenerable specifics". The as-built doc at `ship-session:50` is a dated snapshot, which the checklist allows. The plan index is living text. Decide with the user: either the index stops carrying aggregate counts, or the checklist names plan indexes as an exception.
2. **`ship-session` (1561 words; the cuts below come to about 550, mostly R2).**
   - `:9-15` "What this does" restates the description; "A heavy ritual is a ritual nobody invokes" is rationale. Keep one scope sentence.
   - `:19-23`: `:21` "Do not expand the job" (R1), `:20` is restated in step 1 (R5), `:23` "Do not optimize it away" (R7). All negation (R6).
   - `:31` the three-defect example is rationale. One sentence carries it (R2).
   - `:33` "do not start reviewing it yourself" repeats `:15` (R5).
   - `:37` "discover them, do not assume: check CLAUDE.md…" (R1).
   - `:41` and `:43` both define the unverifiable case; `:43` "It costs one line per group…" is rationale. Merge them (R5, R2).
   - `:54`, `:74` rationale (R2).
   - `:60` prose conventions (R1). `:66` "Never impose a vocabulary" restates "use its markers" (R5).
   - `:76`: point at `decision-record` by name.
   - `:80-84` convention checks are mostly `AGENTS.md` (R1). Keep `:85`, the pathspec commit; it is a real gotcha.
   - `:89-91` "The core, if you remember nothing else" (R2). Move its one new clause (small plans) to `:72`.
3. **`review-staged`.**
   - Description (R3): user-invoked. Cut the trigger list.
   - `:7` "Never target 'the current diff'…" repeats "Target the staged paths explicitly" (R5, R6).
   - `:35` the instruction-prose rule (117 words) applies only when the diff touches instruction prose: a `SKILL.md`, a skill's references, `AGENTS.md`, or a rule file. Move it to `references/` behind a pointer that names all four (R4).
   - `:42` "Minimal diff, no extra abstraction" (R1, R5). `:57` "Be terse throughout" (R1).
   - `:55` restates the `:53` commit gate as a negation. Keep `:53`; make `:55` positive: "Commit only on a message that asks for a commit." (R6).
4. **`review-mr`.**
   - Description (R3): user-invoked. Cut "Use when the user asks to review or re-review…".
   - `:166-193` Step 4b "MR description (on request)": a branch. Move it to a sibling file behind a pointer (R4).
   - `:9` "The user pastes the comments from this file" repeats `:160` (R5).
   - `:131` "Do not merge the spec findings… The two axes are separate on purpose…" restates "own `## Spec` heading, after the code findings" (R5, R6).
   - `:207` describes the page a second time after `REVIEW-PAGE.md:3`; `REVIEW-PAGE.md:5` repeats the host gate at `:207` (R5).
   - `:36` the verifier-bar fallback: only for a host without a `verifier` agent. Move it to a root sibling file, `VERIFIER-FALLBACK.md`, behind a pointer, matching `review-mr`'s layout (`RE-REVIEW.md`, `REVIEW-PAGE.md`) (R4). Session 04 moves the same text in `census` to `references/verifier-fallback.md`. Unsure whether Codex needs it inline; check what Codex loads.
   - `:156` "The comments and replies are outside this pass, because…": unsure whether it is a no-op. Keep unless the user decides otherwise (R7).
5. **`doc-check`.**
   - Description (R3): model-invoked. Cut "Finds stale references, acceptance checks…file lists" and "with one read-only agent per doc".
   - `:29` "A check always finds something…not a stop signal" restates the stop rule before it. Unsure: it may counter a real default (R7).
   - `:32` "For a single sequential session…" restates steps 2 and 6; likely left over from a removed branch (R5).
   - `:48` "Real output" and `:49` "Replacement" duplicate `multi-session-plan:88` and `:89`. `multi-session-plan` § 5 owns it; make `doc-check` cite it, or the reverse. Pick the side where each check bites.
6. **`lesson-record`.**
   - `:10-14` "Where this fits" (R2). Keep the routing lines that change what the agent does.
   - `:12` "From ship-session, report a check. Do not write it." duplicates `ship-session:52`. Keep one (R5).
   - `:53` repeats `:34` (R5). `:54` no-commit (R1).
7. **`papercuts`.**
   - `:16` restates the line format of `AGENTS.md` § Papercuts, with a different last field (`<text>` vs `<what you hit>. <what would have prevented it>.`). Point at `AGENTS.md` and drop the copy (R1).
   - `:60` first sentence restates "Fix only the families the user picks" (R5). `:62` repeats step 4 `invalid` (R5). `:63` no-commit (R1). `:53` "Follow the normal build flow" (R7).

## Files to create / modify

- `custom-skills/ship-session/SKILL.md`.
- `custom-skills/review-staged/SKILL.md`, `references/prose-checklist.md`, a new reference file for the instruction-prose rule.
- `custom-skills/review-mr/SKILL.md`, `REVIEW-PAGE.md`, a new sibling file for step 4b, and the new `VERIFIER-FALLBACK.md`.
- `custom-skills/doc-check/SKILL.md`, `custom-skills/lesson-record/SKILL.md`, `custom-skills/papercuts/SKILL.md`.
- `custom-skills/multi-session-plan/SKILL.md` only if task 5 moves "Real output" there; coordinate with Session 03 if it has not run.

## Reuse references (read-only)

- `AGENTS.md` § Papercuts, § Writing, § Build Right: the rules R1 cuts against.
- The other copy of the verifier fallback: `custom-skills/census/SKILL.md:66` until Session 04 runs, then `custom-skills/census/references/verifier-fallback.md`. Each skill keeps its own copy (roadmap item 3).

## Acceptance / verification

- The overview's acceptance procedure.
- Task 1 is decided and both files agree.

## Out of scope

- `doc-check/SKILL.md:57` ("join doc"): Session 03 changes that one line with the "join" term; leave it.
- Merging `review-staged` and `review-mr`: they review different targets (local staged diff vs a hosted MR) and share little wording.

**Considered and not built:**

- Moving the `ship-session` rationale to `docs/notes/`: most of it is already in `docs/notes/skill-flow.md`. Move a fact only if it lives nowhere else (R2).
