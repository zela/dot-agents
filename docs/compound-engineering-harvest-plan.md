# Harvest compound-engineering into our skills

**Status:** changes 1–4 and 6–11 made in the working tree (2026-11-24), uncommitted. `bootstrap.sh` installed them before the review fixes (see As built). Change 5 waits for the first `/papercuts` run. No skill was run after its edit. Source evaluation: [notes/compound-engineering-eval.md](notes/compound-engineering-eval.md). Decisions come from the grill of 2026-11-24. The lesson store is [ADR-0001](adr/0001-lesson-store.md).

Upstream paths are relative to `skills/` in EveryInc/compound-engineering-plugin at `fcb5e3ad`. Before each edit, re-check that our target does not already state the rule. Use a grep that writes to a file, because the `rtk` rewrite returned a false empty result once in the evaluation.

## Changes

1. [x] **Lesson store** ([ADR-0001](adr/0001-lesson-store.md)).
   - New `custom-skills/lesson-record/SKILL.md`. It writes `docs/lessons/<slug>.md` with frontmatter `title`, `applies_when`, `tags`, and the body sections Problem, Symptoms, What didn't work, Solution, Why, Prevention.
   - The bar is the counterfactual test (`ce-compound/SKILL.md:33`). The form ladder is check, then standard, then lesson (`ce-compound/references/form.md:9-21`). A check is kept only after it fails on the defect's shape with each guard broken alone. "Not worth a lesson" is a valid result. Ground claims in a symbol, not a line number (`ce-compound/references/research.md:94-95`).
   - Callers: `diagnosing-bugs` Phase 5 and `ship-session` step 2.
   - Readers: `craft` (beside the ADR read), `diagnosing-bugs` (beside the ADR read), `multi-session-plan` step 1. Each reader cites a lesson path in the plan doc or the commit message when the lesson changes what it does.
2. [x] **UNRESOLVED verdict** (`ce-code-review/references/validator-batch-template.md:27-45`).
   - `custom-agents/verifier.md`: a third verdict for protected subjects (security, auth, data loss, concurrency, injection, secrets, crypto, public contract). Reject such a claim only with specific refuting evidence.
   - `review-staged` step 2 and 3, `review-mr` Step 2 and the thread check, `review-mr/RE-REVIEW.md`, `census`: one handling line each. Review findings become a note, a thread stays open, a census claim becomes a row that still needs verification.
3. [x] **`diagnosing-bugs`** (`ce-debug`).
   - Performance: a measurement names what bounds the number, or the claim is inconclusive (`ce-debug/references/investigate.md:34`).
   - Uncommitted work is a suspect. Propose the stash experiment and ask first (`investigate.md:46-54`).
   - Search past PRs and tickets before the fix (`investigate.md:66-80`).
   - Propose a cheap always-on signal when the deciding fact took a deep dig (`ce-debug/SKILL.md:64`).
4. [x] **Unrequested mechanisms** (`ce-plan/references/structure.md:150-161`, `ce-work/references/implementation-loop.md:17-22`).
   - `AGENTS.md` § Before You Add Code: rewrite the "speculative guards" sentence with the two conditions and "never narrow requested behavior".
   - `multi-session-plan` session template: a "Considered and not built" list beside Out of scope, one line each with the reason and the evidence that would change the call.
5. [ ] **`papercuts`** (`ce-retro`). Waits for the first `/papercuts` run in its own session, so that the change follows real triage. Proposed: cheapest-fix order starting with removal (`ce-retro/references/placement-and-routing.md:7-15`), declined fixes recorded (`candidates-and-proof.md:23-25`), landed fixes graded against later sessions (`placement-and-routing.md:39-41`).
6. [x] **`review-staged` step 3**.
   - Instruction prose is not code: a finding that the stated condition already decides is not a fix. Fix the condition or move the rule. Never add the case (`ce-resolve-pr-feedback/references/evaluation-rubric.md:18-25`).
   - A finding that would undo a recorded decision is reported, not fixed (`lfg/references/review-followup.md:13`).
7. [x] **`craft` § 3 Right**.
   - Break each guard alone and see a test fail (`ce-work/references/implementation-loop.md:34`).
   - No export, flag or hook that only tests use (`implementation-loop.md:38`).
   - Remove the code of approaches that did not work (`ce-work/references/shipping-workflow.md:51`).
   - For a deleted file, check string references, file-name routes and import-time registrations (`ce-code-review/references/personas/correctness-reviewer.md:15`).
   - A test proves nothing when a mock or fixture supplies the expected result, or when another guard rejects the negative case (`ce-simplify-code/references/personas/test-value-reviewer.md:5`, `testing-reviewer.md:11`).
8. [x] **`ship-session` § 5**: stage named paths and commit with a pathspec (`ce-commit/SKILL.md:46-58`).
9. [x] **Single lines**.
   - `grill-me`: settled decisions are not asked again, and a bare directive gets one challenge (`ce-brainstorm/references/settled-decisions.md:9-15`). Before exit, combine answers with your own defaults and ask about effects nobody asked about (`ce-brainstorm/references/dialogue.md:87`).
   - `multi-session-plan`: safe after every merge, one creator per shared artifact (`ce-plan/references/structure.md:72-73`). One owner per rule; cite, do not restate (`ce-plan/references/plan-sections.md:355-368`).
   - `doc-check`: an "already shipped" check (`ce-work/references/implementation-loop.md:7`).
   - `third-opinion` step 5: agreement is not proof (`ce-pov/references/cross-model-panel.md:472-476`).
   - `decision-record`: "keep the incumbent" and "do nothing" are real options (`ce-pov/references/method.md:14`).
   - `design-an-interface` synthesis: a concrete counterexample against each required guarantee (`ce-bakeoff/references/verification.md:5-9`).
   - `prototype/UI.md`: look at each variant's render before handover (`ce-prototype/references/preview.md:89`).
10. [x] **Prose skills**.
    - `custom-skills/stop-slop/`: for text that people read. Base: `ce-noslop/SKILL.md` and `references/patterns.md`, with the `ce-promote` and `ce-explain` references removed. Add stop-slop's general false agency, narrator-from-a-distance and lazy extremes as rules 45 and up. Exempt counts that a calling skill's format requires (rule 41). Model-invocable, with a narrow description. Credit both sources.
    - Remove `hardikpandya/stop-slop` from `upstream-sources.txt`. Replacing the installed `~/.claude/skills/stop-slop` link needs the user's yes.
    - `review-staged` step 1: drop the em-dash override. `review-mr` Step 3b: the Editor pass loads `stop-slop`. MR descriptions stay on `simple-english`.
    - `custom-skills/wtf/`: vendored from `wtf/SKILL.md`, with the description pointing at `simple-english` and `stop-slop`.
11. [x] **Docs**: README rows for `lesson-record`, `stop-slop`, `wtf`. [skill-flow.md](notes/skill-flow.md) places `lesson-record` in Build and Ship with `docs/lessons/` in the document backbone. The evaluation note gets an Outcome section.

## Dropped in the grill

- `multi-session-plan` stable IDs: the `NNa/NNb` split covers it.
- `parallel-sessions` base-SHA check: not reproduced here, and our worktrees have an explicit base.
- `AGENTS.md` "no plan IDs in comments": no observed cost, and the file is always loaded.
- `third-opinion` depth by consequence: the current trigger is enough.

## As built

Where the edits differ from the list above, or add to it:

- `ship-session` step 2 runs `lesson-record`, but a check that it proposes is reported, not written. `ship-session` changes only docs.
- `lesson-record` proves a check in a copy of the working tree in a temporary directory outside the repo, because a `git worktree` would miss the uncommitted fix. A repo without a coding-standards doc does not get one.
- "Considered and not built" is a bold label inside the template's `## Out of scope`, so the template keeps its seven headings. `multi-session-plan` § 5 cites `AGENTS.md` § Before You Add Code instead of restating the test.
- UNRESOLVED handling:
  - `review-mr` lists it under `## Held back` with `Unresolved` in the grade slot. The line format stays, so `RE-REVIEW.md` re-checks it next round. `review-page.html` now says "Below the post bar (…), or Unresolved."
  - `review-staged` step 6 gained a Notes list. Before this change, the "Unsure" items that step 3 sends to "the report" had no list there.
  - `census` records it as a `?` row with the missing evidence as its Resolves-with check. The ledger legend has the `?` marker.
- `doc-check` classes a shipped but unmarked task as **wrong**.
- `design-an-interface` checks the combined design against the responsibilities and constraints of its step 1, because the skill has no "guarantee" term.
- `stop-slop` rules 45–47: false agency outside code, narrator from a distance, lazy extremes. Each rule narrows or names an actor only from what the source states. Not imported: the absolute bans on adverbs, passive voice, em-dashes, Wh- openers and three-item lists, and the 1–10 score.
- `wtf` has a `LICENSE` and an `agents/openai.yaml` policy (implicit invocation off), like the other hand-typed skills.
- Installed on 2026-11-24, before the review fixes, as copies in `~/.claude/skills` and `~/.agents/skills`, with `verifier.md` in `~/.claude/agents`. `~/.claude/skills/stop-slop` is now a copy, not the upstream symlink. `~/.gemini/antigravity/skills` does not exist, so bootstrap skipped it. Run `./bootstrap.sh` again to install the review fixes.
- `diagnosing-bugs` runs `lesson-record` as a Phase 6 item after the cleanup, not in Phase 5, so that it runs with or without a seam and the debug instrumentation is gone first.
- The protected-subject list adds memory safety.
- A host without the `verifier` agent gets the verifier's bar inline: `review-staged` step 2, `review-mr` Step 2 and `census` step 3.
