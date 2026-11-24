# Harvest claudex-loop into our skills

**Status:** changes 0–5 done (2026-11-23). The Codex smoke run passed (2026-11-23, codex-cli 0.167.0). The exit code was 0, and the event stream had no `error` or `turn.failed` event and no model name. `reply.txt` was correct and had `file:line` evidence. The run did not change the tree. Codex read `~/.codex/memories/MEMORY.md` beside the brief. Nobody ran the Claude command yet. Source evaluation: [notes/claudex-loop-eval.md](notes/claudex-loop-eval.md).

## Context

`docs/notes/claudex-loop-eval.md` proposed four changes. One constraint decides where the four plan-writing rules go: `doc-check` reviews docs and runs no code. The docs-only review in `review-staged` checks prose rules. `doc-check` checks plan facts against code. The four rules are plan facts. As a result, `doc-check` checks three of them, as statements in the doc, and runs nothing.

## Deep evaluation of the four rules

This section judges each rule on the failure that it prevents, what already covers it, and where it belongs. The general split:

- `multi-session-plan` writes the rule into the doc.
- `doc-check` checks that the doc carries it.
- The session, or `craft` for unplanned work, runs it.
- `review-staged` checks the result.

### A. Superseded

- **Failure.** A grill or a scope change edits one task. The acceptance item, another session doc, the overview or `data-model.md` still states the old behavior. The session implements one behavior and tests the other, or the reviewer judges against the stale one.
- **Coverage before.** `doc-check` § Consistency catches two passages that contradict each other. It misses a stale passage when the new behavior is only in the decisions log, because nothing on the page contradicts it. `multi-session-plan` §6 said "append to the decisions log rather than silently rewriting history". That read as permission to leave the body stale.
- **Verdict: strongest of the four.** It resolves an ambiguity in §6: the log keeps the history, and the body keeps the current truth. Write it in `multi-session-plan` §6. Check it in `doc-check`. The coordinator already runs `doc-check` after the grills, so the check catches stale grill edits. `grill-me` needs no edit.
- **Wording.** The leading word is *superseded*. The rule names the search: grep every plan doc for the terms of the old condition (names, values, status codes, thresholds), the acceptance included.

### B. Real output

- **Failure.** The acceptance passes on hand-written fixtures. The real producer emits another shape, so the tests prove the consumer only against a guess.
- **Coverage before.** Partial. `multi-session-plan` step 5 traces each data dependency end to end. The `data-model.md` template says that fixtures and real outputs both conform. Neither requires a check on real output. Our kit uses fixtures first (frontend-first build order), so the rule cannot be "no fixtures".
- **Verdict: keep, reshaped.** At least one acceptance check runs on the real output of the producer, in this session or in a named later session. A captured real output on disk counts. Real data follows `doc-check` § Secrets. Write the rule into step 5 and the session template. `doc-check` checks it as a doc fact: the item exists or names its session.

### C. Replacement

- **Failure.** A rewrite, a port, a library swap or a parser replacement passes its new tests. It still changes behavior on inputs that no test covers.
- **Coverage before.** `craft` § Right "Pin, change, prove" covers a refactor with a pinning test. It does not cover a replacement, where tests are thin, the input space is wide, and some differences are intended.
- **Verdict: keep, with one addition that the source lacks.** Most replacements change some behavior on purpose. Without a list of intended differences, the check cannot fail (`doc-check` § Can fail). So the acceptance names the inputs (real ones, per B), the comparison, and the intended differences. Any other difference is a defect.
  - `doc-check` only checks that a task that replaces code carries this item.
  - The session runs the comparison as part of its acceptance. `parallel-sessions` § Before and after describes how to get the base code without leaving the branch.
  - Unplanned replacements have no session doc. One sentence in `craft` "Pin, change, prove" covers them.

### D. Tautological tests

- **Failure.** A test copies its expected values from the output of the code (a first-run snapshot, a regenerated golden file). Or someone edits an existing assertion to match new output. Then the test enshrines the bug.
- **Coverage before.** Covered at writing time. `tdd` § Tautological says "expected values must come from an independent source of truth: a known-good literal, a worked example, the spec". The `craft` Empty-return test catches a test that passes on any return. The review-time check was missing: the `review-staged` Spec subagent asked only for missing and wrong requirements.
- **Verdict: a review rule.** A plan doc has no tests to check, so `multi-session-plan` and `doc-check` do not change. Add one ask to the Spec subagent in `review-staged`, with *tautological* as the leading word. Keep the exception from the source: a regression test for existing behavior needs no criterion. An edited existing assertion is legitimate only when the plan superseded that behavior (A).

## Changes

0. **Save this plan as `docs/claudex-loop-harvest-plan.md`.** Done.
1. **`custom-skills/third-opinion/SKILL.md`: rewrite.** Done. Codex is the default from Claude Code, and Claude from Codex. Copilot runs only on request and is unverified. The skill holds the commands, the read-only flags and the success criteria. Evidence:
   - Codex flags: checked in `codex exec --help` 0.167.0.
   - Codex feature names `apps` and `plugins`: checked in `codex features list`. The MCP list is `[]` here.
   - Claude flags: checked in `claude --help` 2.1.323. The prompt on stdin is the approach of the runner, not run here.
2. **`custom-skills/doc-check/SKILL.md`: optional cross-provider check.** Done. On request, step 2 also sends each doc through the read-only run of `third-opinion`. The agent names the call count and waits for a yes. The findings enter step 3 like the findings of the agents, marked with the provider.
3. **`doc-check`: hash record and launch gate.** Done.
   - New step 7: after the last pass, write the `shasum -a 256` of each checked doc to `<report>.sha256`. Step 4 puts the gate command in the report header.
   - New § Launch gate: before a launch, run `shasum -a 256 -c <report>.sha256`. A doc that fails changed after its check.
   - Why a hash, not the base commit: step 5 fixes land after the base, and `parallel-sessions` allows `docs/` outside git.
   - `custom-skills/parallel-sessions/coordinator.md` step 4 (Launch) runs the gate first. A sequential session has no coordinator, so the report header carries the command.
4. **The four rules.** Done.
   - `custom-skills/multi-session-plan/SKILL.md` §6 (A) and step 5 (B, C).
   - `custom-skills/multi-session-plan/assets/templates/session.md` Acceptance: a real-output bullet (B) and a replacement bullet (C).
   - `doc-check` § Checks: *Superseded* (A), *Real output* (B), *Replacement* (C). The severities follow `doc-check` § Severity, which lists a missing acceptance item under **gap**.
   - `custom-skills/craft/SKILL.md` "Pin, change, prove": one sentence for a replacement (C).
   - `custom-skills/review-staged/SKILL.md` Spec subagent: one ask for tautological tests (D).
5. **Docs.** Done. The `README.md` rows for `third-opinion` and `doc-check`, and the § Changes made list in the eval note.

## Verification

- `shasum -a 256`, then `shasum -a 256 -c`, on two scratch files with one edited between the two runs. Done: the edited file gave `FAILED` and exit 1.
- The Codex smoke run of the new `third-opinion` command, on a trivial read-only question. Done: see the Status line.
- Not run: the Claude command from a Codex host.
- Suggested, not run: `/review-staged` on the staged result, and `~/dot-agents/bootstrap.sh` to deploy. Bootstrap overwrites the installed skill copies.
