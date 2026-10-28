# Evaluating ub-mode and its quality-gate tools

[unclebob/ub-mode](https://github.com/unclebob/ub-mode) is one `SKILL.md` of about 140 lines: terse engineering rules in three parts (First Make it Work, Then Make it Right, Practice), loosely based on poteto's `poteto-mode`. Three of its rules call deterministic tools from the same author: [crapper](https://github.com/unclebob/crapper) (CRAP score per function), [dryer](https://github.com/unclebob/dryer) (structural duplication), and [mutator](https://github.com/unclebob/mutator) (mutation testing). A fourth repo, [uml-viewer](https://github.com/unclebob/uml-viewer), renders their snapshots and is out of scope here.

Evaluated on 2026-10-28 from shallow clones: ub-mode `57a8bdd` (2026-10-25), crapper `6fd92c4` (2026-10-21), dryer `66ff6d2` (2026-10-03), mutator 2026-10-21.

## What was checked

- Executed: read `SKILL.md` and all four READMEs. Read the tool source on the paths that install, delete, or write into the target tree, and on the coverage and changed-file paths (`crapper/src/crapper/runners.py`, `cli.py`, `coverage.py`, `discover.py`; `dryer/src/dryer/cli.py`, `scan.py`, `report.py`; `mutator/src/mutator/engine.py`, `workers.py`, `bugs/`).
- Executed: GitHub API metadata and open issues. ub-mode: created 2026-10-25, 4 commits, about 2,150 stars, 3 open issues, no license file. The user decided to treat it as MIT. crapper has 9 commits, dryer 5, mutator 11. All three tools are `0.1.0`, 0BSD, created 2026-09-30, with 6 to 11 open issues each.
- Executed: this workstation has `node`, `pnpm`, and `uv`, and no `cargo`, `go`, `mvn`, or `clj`. The user's projects are mostly TypeScript with Astro or React, tested with Vitest.
- Executed: graded each ub-mode principle against the text of `AGENTS.md`, `tdd`, `domain-modeling`, and every custom skill, by grep and by reading the matching lines.
- Executed: `craft/scripts/check-changed.sh` against stub `crapper` and `dryer` binaries in a scratch repository. File selection, `--since`, the coverage command, the no-provider branch, the stale-report warning, the duplicate filter, and the missing-tool exit all behaved as written.
- Not executed: crapper, dryer, and mutator themselves. Claude Code's auto-mode classifier blocked running the cloned code. Every tool-behaviour claim below that is not a README quote is read from source. The trial in "Not done yet" confirms or refutes it.

## Verdict: rewrite the skill as `craft`, use crapper and dryer through a wrapper, defer mutator

## The skill

A first draft of this note said about three quarters of ub-mode was already in the kit. That was wrong. It counted `census` audit items as build guidance, but `census` finds problems in standing code and never steers the code being written. Graded against the text:

- Covered at build time:
  - TDD, and Test Behavior, Not Implementation: `tdd`, which is stronger on both.
  - Fix Root Causes: `AGENTS.md` and `diagnosing-bugs`.
  - Sequence Work into Verifiable Units: `tdd` vertical slices and `multi-session-plan`.
  - Outcome-Oriented Execution: `AGENTS.md` Think First, `/goal`, and expand–contract.
- Partial:
  - Laziness Protocol: "smallest edit" is in `AGENTS.md`; "one decision lives in one place" is not.
  - Subtract Before You Add: our ladder says do not add; it never says simplify first, then add.
  - Attack the Premise: "When Work Fails" counts repeats of one approach, not fixes that share an assumption.
  - Build the Lever: only `run-state`, for homogeneous runs.
  - Model the Domain: the glossary is `domain-modeling`; illegal states appear only as a `census` audit item.
  - Boundary Discipline: `AGENTS.md` only says do not remove validation at trust boundaries.
- Absent at build time:
  - Foundational Thinking (data shape before logic).
  - Redesign From First Principles.
  - Type System Discipline, including "do not silence the compiler" (a `census` audit item only).
  - Make Operations Idempotent.
  - Separate Before Serializing Shared State (`census` audits races only).

The design-time half is the real gap: the kit is strong on process and almost silent on design while code is written. That is worth a skill. ub-mode as written is not, for these reasons:

- It is a list of principles. The model already knows each one, so a list barely changes behaviour. A check tied to a moment does.
- Its Practice section conflicts with `AGENTS.md`: "push to the main line at the end", "reclaim the disk", and the Mutator rule "delete dead code". The first two are filed upstream as "Two rules let the agent act on its own: push to main and reclaim disk". Keep a Log contradicts "be as short as completeness permits".
- It calls the tools with no install step or command.
- It states "ship the smallest edit" and "do not bolt a new requirement onto the old design" side by side, with no rule for when each wins.

`custom-skills/craft` is the rewrite. It is model-invoked, because the agent has to reach it without being asked. It has three steps, and each ends on a completion criterion:

- Shape, before the first edit: data shape and illegal states, parse at the boundary, one decision in one place, make the change easy first, edit or redesign, idempotency, single writer. Its output is a short Shape note.
- Work: `tdd` slices, plus two moves for when stuck (name the premise, build the lever).
- Right, before done: fix the type rather than the checker, the empty-return test, pin before a refactor, root cause, and the scores on the changed files. Its output is a short Right note.

The edit-or-redesign rule resolves the tension: make the smallest edit, unless the requirement becomes a special case in a shape that did not expect it (a new flag, the same new branch in several places, a parameter that only one caller passes). Then reshape and deliver it with expand–contract.

## crapper: no fork, a wrapper

Read from source: `--coverage-command` returns before every per-language runner (`runners.py`, `run_coverage`). The installs live only on the default path:

- `npm install @vitest/coverage-v8` when the provider is missing.
- `npx vitest` when there is no local binary, and `npx --yes c8` for other test scripts.
- `pip install coverage` or `pytest`, and `cargo install cargo-llvm-cov`.

So `craft/scripts/check-changed.sh` passes its own command: the local `node_modules/.bin/vitest run --changed`, LCOV into `coverage/craft/`, `--coverage.include` per changed file, and `--passWithNoTests`. It runs only when a local Vitest and a coverage provider exist. Otherwise it scores complexity only. It installs nothing, and upstream fixes still arrive with each pinned upgrade.

Limits the wrapper cannot remove:

- crapper merges every `lcov.info` under `coverage/` and `target/coverage/` (`coverage.py`, `_lcov_paths`). A stale project report can skew scores. The wrapper warns and names the files; it does not delete them.
- `.astro` is not in crapper's extension map (`discover.py`). Astro frontmatter is not scored.
- The table covers every function in a changed file, not only the changed functions.
- It writes `.metrics/crap.edn` at the project root.

## dryer: a wrapper too

dryer is static: no test runs, no installs, one output file (`.metrics/dry.edn`). Read from source, `--changed` passes only the changed files to `find_duplicates`, so it compares them with each other and misses the main case, new code that repeats existing code. The wrapper passes every tracked and untracked source file instead, and keeps only the pairs with a changed side. Open issues say Python `is`, `in`, `@`, and `//` drop out of the normalised tree; that does not affect TypeScript.

## mutator: defer

Mutation testing is the strongest check that tests test behaviour. This tool is not ready to be trusted for it:

- Open issues report silent wrong answers. Go: every site is reported uncovered and the run exits 0. Rust: parallel workers report survivors as KILLED. Python: mutants in an uncovered `elif` are run and reported as SURVIVED.
- It is heavy by design: one full test run per mutant, after a baseline run.
- It needs a crapper checkout at `../crapper`, found through a `sys.path` insert (`crapper_link.py`).
- Read from `engine.py:317`, not observed: at the end of a file it writes the start-of-run bytes back if the file changed. An edit to that file during the run, by the user or a parallel agent, is reverted without warning.

Revisit when the silent-wrong-answer issues are closed. For TypeScript, StrykerJS is the established mutation tester (assumed from general knowledge, not checked in this session). The empty-return test in `craft` is the cheap manual stand-in.

## Outcome (2026-10-28)

- Added `custom-skills/craft/`: `SKILL.md`, `references/scores.md`, and `scripts/check-changed.sh`.
- Added `craft` to the Build phase of [skill-flow.md](skill-flow.md) and to the custom-skill table in `README.md`. The HTML renders of the flow were not regenerated.

## Eval, iteration 1 (2026-10-28)

Executed with `skill-creator`. There were four TypeScript fixtures and one run per configuration, on Opus, with the same global `AGENTS.md` in both configurations. Each fixture uses `node --test`, so every run had a real test loop with no installs. The cases were a wholesale tier, theme settings from dirty `localStorage`, duplicate webhooks with refunds, and a refactor guarded by weak tests. There were 26 assertions: 17 hidden behaviour tests run against each final tree, 2 scripted checks, and 7 judgement assertions. Graders saw the two runs labelled A and B, without knowing which used the skill.

- Pass rate: 25/26 with `craft`, 21/26 without. The per-eval mean is 95% against 79%.
- Cost: +56 s (+68%) and +11k tokens (+21%) per run on average. Replies were about twice as long, because each carries a Shape note and a Right note.
- Where the skill made the difference:
  - Eval 1: a `tier` union and one rule table, against a second `isWholesale` boolean with checks in three places.
  - Eval 2: type guards with no casts, against `as` casts.
  - Eval 3: a real discriminated union for the events.
- Where it made no difference: all 17 hidden behaviour tests passed in both configurations, including concurrent duplicate webhooks and behaviour equivalence after the refactor. The baseline already gets observable behaviour right.
- Both configurations failed one check: neither tested shipping just below the 500 threshold.
- The score hides one trade-off. In eval 3 the with-skill run chose a version compare-and-set that changes the contract of `putOrder` and needs a row migration. The baseline added a purely additive transactional method. Only the with-skill run rejects over-refunds.
- Scope drift: two with-skill runs reached outside the project. One ran a `tsc` found in another app's folder. The other wrote mutants to a separate scratch folder.
- The sample is small, with one run per cell. Treat the delta as directional, not as significant.

## Eval, iteration 2 (2026-10-28)

Iteration 1 had two flaws. Its prompts gave the traps away, so the hidden tests could not discriminate. And its fixtures used `node --test`, so crapper and dryer never ran. Iteration 2 fixes both. Each prompt is a plain feature request, and the trap sits only in the hidden tests: a rerun after a crash, junk URL values, a push that arrives during an API call, the `KW1`/`KW15` prefix, exactly 30 kg. The fixtures use Vitest 5 with v8 coverage, and crapper and dryer are installed. There were six evals, two runs per cell, and 46 assertions per configuration-run. The skill changes from iteration 1 were already applied: the note cap, the boundary check, and type-checking with the project's own tools only. The eval set is in [craft-evals/iteration-2/](craft-evals/iteration-2/).

- Executed: with `craft`, 92/92 assertions passed. Without it, 80/92. Each cell scored the same in both of its runs.
- Executed: all 34 hidden behaviour tests passed in both configurations. With `AGENTS.md`, the Opus baseline already gets behaviour right even when the trap is unstated. `craft` changes structure, not correctness.
- Where `craft` made the difference:
  - Wholesale: a tier union and one rule table, against a second boolean with checks in three places. Only the with-skill runs also tested just below 500.
  - Inbox: a derived `unreadCount` getter, against a field that methods assign by hand.
  - URL filters: parsing with no casts, against `as Sort` / `as Category`.
  - Shipping: the function split into `baseRate`, at a CRAP score of 8 and 100% coverage. The baseline kept one function at CC 15, with a CRAP score of 15.3. Both with-skill runs read crapper's first score and then split the function. This is the tool loop working as designed.
- Executed: dryer flagged nothing. All four email runs reused `cartSummary` without being told to, so that case did not discriminate.
- Executed: two baseline replies told the user that `tsc` passed. TypeScript is not installed, and the RTK hook rewrites `npx tsc` to print "TypeScript: No errors found". No with-skill reply made that claim. The papercut is logged.
- Cost: +79 s per run (139 s against 60 s) and +13.7k tokens (+27%). The median reply is 539 words, against 301. The note cap brought the longest reply down from 1032 to 637 words.
- The sample is still small: two runs per cell, on one model.

## Not done yet

1. A run on one of the user's real projects. The eval fixtures confirmed the tool loop: Vitest `--changed`, LCOV, crapper, and dryer all ran. A real repo can still differ: a workspace config, a custom `reportsDirectory`, `.astro` files.
2. The user chose to keep the reply length as it is.

## Shipped (2026-10-28)

- The description names the change kinds where the eval showed gains: a domain variant, a data write, outside input, shared state, an already complex function, a refactor, and branch scoring.
- Trigger test, executed: recall 12/12 and 0/8 false triggers, over 10 cases × 2 runs on Opus. Each run used a real fixture project with `craft` as a project skill and read-only tools. A run counted as triggered when `craft` was invoked before the first Edit or Write. In 3 of the 12 positive runs, the agent ran `Bash` first and then invoked the skill. The near-misses were a text change, a rename, tests only, and a question. They went straight to an edit or to an answer. The harness and the results are in [craft-evals/trigger/](craft-evals/trigger/).
- skill-creator's own trigger loop was stopped after about 120 calls, because its measurements were invalid. Parallel workers each wrote a duplicate of the skill, and each worker counted only its own copy: the explicit `craft:` query scored 0/3 in parallel and 2/2 serially. The loop also stops at the first tool call that is not a skill, which counts an agent that explores first as a miss. Its proposed descriptions ("Invoke it FIRST… Do not skip it") were fitted to that artefact and were not applied. Its queries are in [craft-evals/trigger/skill-creator-queries.json](craft-evals/trigger/skill-creator-queries.json).
- `upstream-tools.txt` pins crapper and dryer to a commit. `scripts/agent-tools.sh install | check | update` installs the pins, compares them with upstream HEAD, and moves them forward. `bootstrap.sh` step 7 runs `install` and adds `.metrics/` and `coverage/craft/` to the global gitignore.
