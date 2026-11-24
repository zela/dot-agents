# Evaluating chaseai-yt/claudex-loop

[chaseai-yt/claudex-loop](https://github.com/chaseai-yt/claudex-loop) at `53cddc4` (2026-10-14), MIT. It has four skills (`claudex-loop`, `claudex-route`, `codex-review`, `codex-build`), a Python runner, a fake-CLI test suite, and a `legacy/` copy of the mattpocock grill skills. We evaluated it on 2026-11-23 against the [skill flow](skill-flow.md).

## Verdict: skip the workflow, harvest the runner's boundaries and four rules

The core idea of the repo is cross-provider review. The host plans, and the other provider (Codex from Claude Code, Claude from Codex) reviews the plan in rounds. Then a fresh session of the other provider inspects the built code. That idea fills a real gap here. Every reviewer in our kit (`doc-check`, `review-staged`, `verifier`, `/code-review`) runs on the same model that wrote the work. The only cross-provider skill, `third-opinion`, defaulted to the Copilot CLI, which is not installed on this machine (`which copilot` found nothing). `codex` 0.167.0 is installed.

The workflow duplicates our own flow, with a weaker structure:

- One `PLAN.md` and one `PLAN-REVIEW-LOG.md` at the repo root, against our linked session docs under `docs/`.
- Phase 0–1 (recon, decision map, interview) is `grill-me` plus `domain-modeling`. Its `CONTEXT-FORMAT.md` and `ADR-FORMAT.md` are the same mattpocock files that we vendored or replaced with `decision-record`.
- Phase 2 (plan review) is `doc-check` with a different reviewer.
- Phase 3 (build and inspect) is a session plus `review-staged`.

The value is in the runner and in a few rules that the skills state well. We took those into existing skills.

## Per-part verdicts

- **`claudex-loop` (full workflow).** Skip.
  - Overlap: `grill-me`, `multi-session-plan`, `doc-check`, `review-staged`, `ship-session`.
  - Cost: up to 5 plan-review rounds plus 2 inspections, each a frontier-model run. Under our heavy-operation rule, each run needs a yes, so a model-invoked loop does not fit.
- **`claudex-route` (model routing).** Skip.
  - It hard-codes a model shortlist dated October 2026, which goes stale on the next release.
  - Our `AGENTS.md` subagent and "When Work Fails" rules cover most of its role table. One row is worth a line in `third-opinion`: after a repeated failure, give another provider the failed approaches.
- **`codex-review`, `codex-build`.** Skip. They are compatibility aliases for the loop.
- **`legacy/`.** Skip. Older copies of skills that we already have.
- **`scripts/runner.py` (review and inspect modes).** Harvest the invocation boundaries into `third-opinion`. If we later want structured multi-round review, vendor the file.
  - Claude reviewer: `--safe-mode`, an empty `--strict-mcp-config`, `--tools Read,Glob,Grep`, `--permission-mode dontAsk`. These flags exist in our Claude Code 2.1.323 (checked with `claude --help`).
  - Codex reviewer: `exec -s read-only`, plus `--disable apps --disable plugins`, plus each MCP server from `codex mcp list --json` turned off. Reason: the shell sandbox does not govern MCP side effects. `--sandbox` and `--disable` exist in our Codex 0.167.0 (checked with `codex exec --help`). The repo claims that the MCP gap is real. We did not reproduce it.
  - The prompt goes through a file or stdin, never into a shell string. The old `third-opinion` built `copilot -p "<summary>"` and `claude -p "<summary>"` inline.
  - Exit 0 means that the turn completed, and says nothing about the verdict. An empty output, a timeout, or a permission failure is a failure. The runner does not retry or switch model.
  - The runner reports the requested model and the observed model apart. The CLI default does not prove which model ran.
  - Each run keeps its artifacts (prompt, command, stdout, stderr, result) in a unique directory outside the checkout.
  - Inspection starts a fresh session. Plan review resumes one session across rounds, so the reviewer does not reopen resolved points.
- **Plan-hash binding.** Harvest into `doc-check`. The runner binds an approval to the path and the SHA-256 of the plan, and a changed plan invalidates it. `doc-check` step 7 and § Launch gate do the same for each cleared session doc.
- **Plan-writing rules.** Four rules. The full reasoning is in [the harvest plan](../claudex-loop-harvest-plan.md).
  - **Superseded** (change every passage that still states a replaced behavior). The strongest of the four. `doc-check` § Consistency misses a stale passage when the new behavior is only in the decisions log. Also, `multi-session-plan` §6 ("append to the decisions log") read as permission to leave the body stale. The rule is in §6 and in `doc-check`.
  - **Real output** (prove on the real output of the producer, not only on hand-written fixtures). Reshaped: our kit uses fixtures first, so the rule asks for one check on real output, in this session or in a named later one. The rule is in `multi-session-plan` step 5, the session template and `doc-check`.
  - **Replacement** (run the old and the new code on the same inputs). Extended: the acceptance also lists the intended differences, because without them the check cannot fail. The rule is in `multi-session-plan`, the session template, `doc-check` (presence only) and `craft` "Pin, change, prove" for unplanned work.
  - **Tautological tests.** The `tdd` tautological anti-pattern already covers this rule at writing time. We added only a review-time ask to the `review-staged` Spec subagent.
- **Permission advice.** Note only. Do not allowlist a script with a prefix rule such as `Bash(python …/runner.py*)`, because a prefix rule also approves anything chained after it.

## Changes made (2026-11-23)

1. We rewrote `third-opinion`. It picks the other provider by host (Codex from Claude Code, Claude from Codex) and uses the read-only flags of the runner. It sends the prompt through stdin from a file outside the repo. It has strict success criteria and reports the requested and the observed model apart. Copilot stays an explicit option.
2. `doc-check` has an optional cross-provider check through `third-opinion`. It runs on request, after a yes for the call count.
3. `doc-check` step 7 records a SHA-256 for each cleared doc, and § Launch gate checks it before launch. `parallel-sessions/coordinator.md` runs the gate at wave launch. A scratch-file test showed that `shasum -c` gives `FAILED` and exit 1 for a doc edited after its check.
4. The four rules, placed as above.
5. Open: a cross-provider inspection step in `review-staged` or in the `parallel-sessions` review session, as a fresh Codex session over `<base>...HEAD`. Decide after `third-opinion` shows how useful Codex findings are in practice.

## Evidence

- Executed: we cloned the repo. We read all four `SKILL.md` files, both references, `VALIDATION.md`, and the command construction of the runner. We checked the reviewer flags against the help of the installed `claude` and `codex`.
- Not executed: the runner, its tests, any live cross-provider review. The live validation of the repo was a seeded-defect fixture, not a quality comparison (its `VALIDATION.md` says so).
