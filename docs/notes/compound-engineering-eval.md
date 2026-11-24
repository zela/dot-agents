# Evaluating EveryInc/compound-engineering-plugin

[EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) at v3.38.3 (`fcb5e3ad`, 2026-11-23), MIT. The README counts 38 skills. The `skills/` directory holds 46, including deprecation shims (`ce-compound-refresh`) and hidden utilities (`wtf`, `ce-retune`). The skills total about 920k words of `SKILL.md`, references and scripts. We evaluated it on 2026-11-24 against the [skill flow](skill-flow.md).

## Verdict: install nothing, build one missing piece, harvest about twenty rules

The plugin is a loop: `ce-brainstorm` → `ce-plan` → `ce-work` → `ce-compound`, with `lfg` to run the whole loop hands-off. The first three steps duplicate our spine (`grill-me`, `multi-session-plan`, `craft`/`tdd`, `review-staged`, `ship-session`). The fourth step is the idea of the plugin, and our kit does not have it.

- **The gap.** A solved problem's lesson has no place where a later plan reads it. `ship-session` writes gotchas into that plan's own session doc. `revise-claude-md` writes to `CLAUDE.md`, which every session pays for. `craft` and `diagnosing-bugs` read `CONTEXT.md` and `docs/adr/`, and `multi-session-plan` reads nothing from past work. `ce-compound` writes one lesson per file to `docs/solutions/`, and `ce-plan` greps its frontmatter before it plans.
- **Why not install.** Almost every skill conflicts with `AGENTS.md`:
  - It commits, pushes, opens PRs, posts to GitHub or Slack, or resolves threads without asking. `ce-babysit-pr/SKILL.md:29`: "Babysitting authorizes these mutations … never ask."
  - It deletes files without consent (`ce-compound` refresh, scratch cleanup in `ce-pov`, `ce-bakeoff`, `ce-ideate`).
  - It sends repository content to another provider without a yes for each run (`ce-code-review` focused depth, `ce-doc-review` cross-model pass, `ce-pov` oracle).
  - It depends on `.compound-engineering/config.yaml`, on bundled Python and shell scripts (about 10k lines behind the `ce-work` cross-model author alone), and on other `ce-*` skills.
- **Why harvest.** The prose is long, but it is precise and evidence-driven. Many rules are sharper versions of rules that we state loosely, and each one fits in one or two lines of an existing skill.
- **Size as a warning.** `ce-code-review` is 87k words, and `ce-plan` and `ce-work` are near 70k each. Every skill restates host mechanics (scratch directories, the blocking-question tool, `docs_root` checks). That is the tax of supporting 14 hosts. Do not copy that style.

## Per-part verdicts

Verdict words follow [the mattpocock eval](mattpocock-skills-eval.md): **Adopt** (install unchanged), **Vendor** (copy and edit), **Harvest** (one idea into one existing skill), **Skip**. All line numbers are upstream unless the path is ours.

### The core loop

- **`ce-brainstorm`.** Harvest. `grill-me` plus `design-a-*` plus `decision-record` already cover the interview, the approaches and the decisions.
  - Settlement test, into `grill-me` (`references/settled-decisions.md:9-15`). The user is never asked again about a decision they made after they saw the trade-off. A bare directive gets exactly one challenge. The agent never marks its own proposal as settled.
  - Integration check before exit, into the done condition of `grill-me` (`references/dialogue.md:87`). Combine the user's answers with your own defaults, and ask about effects that nobody asked about.
  - Lower priority. After two "you decide" answers on substance, offer a map of open decisions with defaults, and record each default as an assumption (`references/blindspot-pass.md:12-14`). Product lenses for product-shaped plans: evidence, a named beneficiary, today's workaround, the smallest version (`references/product-pressure-test.md:15-21`).
- **`ce-plan`.** Harvest.
  - **Judge each concern** (`references/structure.md:150-161`, the strongest planning rule). Build an unrequested guard, retry or mode only when leaving it out causes harm that nobody would catch in time, or when adding it later is expensive (stored data, a shared interface, money, security). A safeguard never narrows requested behavior. A concern that fails the test goes into the non-goals with the reason and the evidence that would change the call. `ce-work/references/implementation-loop.md:17-22` states the same rule for build time. Target: `AGENTS.md` § Before You Add Code gives the test a definition of "demonstrated need". The `multi-session-plan` session template gets a "Considered and not built" list next to Out of scope.
  - Safe after every merge, into `multi-session-plan` sequencing (`structure.md:72-73`). A capability is never reachable on main before the guard that limits it. Each shared artifact has one creator.
  - One owner per rule, into `multi-session-plan` § 5 (`references/plan-sections.md:355-368`). State a gate or a threshold in full once, and cite it everywhere else. This rule prevents the drift that our superseded-passage rule finds after the fact.
  - Stable IDs, into `multi-session-plan` § 6 (`structure.md:106`). Never renumber. A new item takes the next free number.
- **`ce-work`.** Skip. It commits each unit, pushes through `ce-commit-push-pr`, and its cross-model author runs the worker "with every permission request approved" (`references/cross-model-execution.md:85`). Harvest:
  - Into `craft` § 3 Right (`references/implementation-loop.md:34,38`; `references/shipping-workflow.md:51`). When behavior rests on more than one guard, remove each guard alone and see a test fail. Add no export, flag or hook that only tests use. Remove the code of approaches that did not work.
  - Into `doc-check` (`implementation-loop.md:7`). An "already shipped" check: if the code already does the work of a task, verify the code and mark the task done. Do not rebuild it.
  - Into `AGENTS.md` § Comments (`implementation-loop.md:106`). Plan IDs such as `(R7)` stay out of code and comments.
  - Into `parallel-sessions` § Start the session (`references/execution-strategy.md:29`). Before you edit, check that `HEAD` equals the intended base SHA. Upstream says that the harness has cut worktrees from the wrong base. We did not reproduce this.
  - Note only (`references/worker-model.md:7-10`). Never use a model below mid-tier for a worker, because cheaper models take more turns. Escalate once on a reasoning failure, never on an environment block.
- **`lfg`.** Skip. It pushes "without stopping" (`SKILL.md:3`). Harvest into `review-staged` step 3 (`references/review-followup.md:13`): a finding that would undo a recorded decision is reported, not fixed.
- **`ce-doc-review`.** Skip. `doc-check` covers it, and the cross-model pass defaults to `auto` (`references/cross-model-review.md:47`). Harvest into `third-opinion` § When to use (`references/depth.md:3,21`): the depth of the check follows the cost of a wrong plan (money moved, access granted, sensitive data exposed, a public contract), not the length of the plan.
- **`ce-worktree`.** Skip. It contradicts two `parallel-sessions` decisions: it prefers the native worktree tool, and it puts worktrees inside the repo and edits `.gitignore`.

### The knowledge store

- **`ce-compound`.** Vendor the capture core as a new skill. Skip refresh, packs, transcript mining and config. This is the one piece worth building. See [The lesson store](#the-lesson-store) below for the proposed shape.
  - Counterfactual bar (`SKILL.md:33`): "without a record of this lesson, would a future engineer working from the current tree still be likely to repeat the mistake or redo substantial investigation?"
  - Form ladder (`references/form.md:9-21`). Prefer a check (a test or a lint rule) to a standard, and a standard to a learning doc. Keep a check only after it fails on the defect's shape in a throwaway copy of the tree, with each guard broken alone.
  - Grounding (`references/research.md:94-95`). Cite the symbol, not the line number. Cite the PR, not the SHA. Mark an unmerged fix as pending.
  - Conflicts: refresh deletes without confirmation (`references/refresh/classify.md:32-34`). Non-interactive refresh commits and opens a PR. Setup offers a "run automatically" directive.
- **`ce-compound-refresh`.** Skip. It is a shim. If our store grows, take one rule: a claim is recoverable elsewhere only if you can quote the artifact that states it (`ce-compound/references/refresh/worth-audit.md:11,15`).
- **`ce-retro`.** Harvest into `papercuts`. It is the mature form of the mattpocock `retro` stub that our earlier eval flagged.
  - Cheapest-fix order (`references/placement-and-routing.md:7-15`): remove something, then a check, then a pointer, then a standard, then a new instruction. "Removal is a fix, not a side effect." Today `papercuts` lists fix kinds with no order.
  - Record declined fixes (`references/candidates-and-proof.md:23-25`). Do not propose them again without new evidence of their cost.
  - Grade each landed fix against later sessions (`placement-and-routing.md:39-41`).
  - Do not restore text that a commit removed on purpose, unless it has a recurring cost (`candidates-and-proof.md:27`).
  - Conflicts: it commits each approved edit, and it reads other projects' transcripts.
- **`ce-retune`.** Skip. Note one rule for our own skill evals (`SKILL.md:38`): measure the noise floor on two identical copies, and register the bar before you see results. The 96% against 71% result in [the papercuts eval](papercuts-eval.md) had no floor.
- **`ce-setup`, Compound Packs.** Skip. Take the `applies_when` phrasing (a situation, not a topic) for the lesson-store frontmatter (`docs/guides/packs.md:99-118`). Take the standards bar for later (`ce-compound/references/form.md`, `ce-standards-bar` block): a rule enters a standards file only from a fixed review finding, a fix commit, a cleanup or a lesson, and only when no check covers it.
- **`ce-strategy`, `ce-help`.** Skip. Product strategy is out of scope, and `skill-flow.md` is our map.

### Review and quality

- **`ce-code-review`.** Skip. It is coupled to the plugin, it forbids blocking questions (`SKILL.md:38`), and it treats the invocation as permission to send code to another provider (`SKILL.md:31`). Our Spec axis, the `review-mr` thread check and `verifier` cover its plan check, its previous-comments reviewer and its validator. Its "review receipt" is the gate that `ce-work` needs before it ships; `ship-session` step 1 already asks whether a review happened. Harvest:
  - **UNRESOLVED for protected subjects** (`references/validator-batch-template.md:27-45`, the strongest review rule). For security, auth, data loss, concurrency, injection, secrets, crypto or a public contract, a verifier rejects a finding only with specific refuting evidence. Otherwise the status is "unresolved". Ours says the opposite: `custom-agents/verifier.md:26` "Ambiguous evidence is DOES-NOT-REPRODUCE", and `review-staged` step 2 discards it. The security protection of step 3 comes after that discard, so an uncertain security claim disappears without a trace today. Target: a third verdict in `verifier.md`, reported as a note by `review-staged` and `review-mr`.
  - Into `craft` § 3 Right (`references/personas/correctness-reviewer.md:15`). For a deleted file, look for string references (asset paths, config keys, plugin names), routes built from file names, and import-time registrations, not only imports.
- **`ce-simplify-code`.** Skip. Native `/simplify` and `census` cover it. Its comment reviewer deletes "by default, and doubt does not save one", which conflicts with `AGENTS.md`. Harvest into the `craft` empty-return bullet (`references/personas/test-value-reviewer.md:5`, `testing-reviewer.md:11`). A test proves nothing when a mock or fixture supplies the result that the code should produce, or when a guard other than the named one rejects the negative case. Lower priority: a check that stands in for production (a CI gate, a harness, a mock) must run the same command, directory and environment, or it can pass while production fails (`adversarial-reviewer.md:15,67`).
- **`ce-noslop`.** Vendor, with a decision for the user. It is 45 lines plus a 44-pattern catalog, and it has what [the anti-slop eval](anti-slop-eval.md) wanted from `stop-slop` "if `stop-slop` ever needs local edits": a false-positive floor and a no-new-facts rule. It also fits our house style better: it allows em-dashes that are not a crutch, and passives when the actor is unknown. If we take it, it replaces `stop-slop` in the "Other prose" slot of `review-staged` (step 1), and the em-dash override there goes away. Removing the `hardikpandya/stop-slop` line from `upstream-sources.txt` needs a yes.
- **`wtf`.** Optional, low priority. A 33-line, user-invoked "explain that last message plainly". `simple-english` Plain mode does the same work without the one-word trigger.

### On demand

- **`ce-debug`.** Skip. It creates branches, commits and opens PRs "Do not ask first" (`SKILL.md:109-125`). Harvest into `diagnosing-bugs`:
  - **Name the bound** (`references/investigate.md:34`, also `ce-optimize/references/loop.md:137`). A performance measurement explains the slowness, or supports a fix, only when it names what limits the number: CPU, disk, a lock, a pool, a round trip, a rate limit, or the measuring setup itself. With no named limit, the claim is inconclusive. This is the best single rule in the cluster. Ours stops at "Measure first, fix second."
  - Uncommitted work is a suspect (`investigate.md:46-54`). Propose a stash experiment and ask first. Upstream stashes without asking.
  - Search past PRs and tickets before you fix. A merged fix for the same symptom while the bug persists is evidence against that fix (`investigate.md:66-80`).
  - When the deciding fact needed a deep dig, propose a cheap always-on signal: a log field, a metric or an assertion (`SKILL.md:64`).
- **`ce-optimize`.** Skip. One approval covers a long experiment loop that commits. Note for skill editing (`references/text-targets.md:10`): "every rule you want preserved needs a case that fails without it".
- **`ce-pov` and its oracle panel.** Skip. The panel scripts are 3.7k lines, and the reconcile rounds multiply frontier-model calls. Harvest:
  - Into `third-opinion` step 5 (`references/cross-model-panel.md:472-476`). Agreement between models is not proof, because models share blind spots. A recommendation added after the panel is the host's own, and the host names it so.
  - Into `decision-record` (`references/method.md:14`). "Keep the incumbent" and "do nothing" are real options.
- **`ce-bakeoff`.** Skip. `design-an-interface` already runs one subagent per design. Harvest into its synthesis step (`references/verification.md:5-9`): before you declare a combined design, work a concrete counterexample against each required guarantee.
- **`ce-prototype`.** Skip. Our `prototype` covers it. The annotation overlay server is 2.1k lines of JavaScript that can bind to `0.0.0.0`. Harvest into `prototype/UI.md` (`references/preview.md:89`): look at the rendered screen of each variant before handover. An HTTP 200 is not a check. If you cannot see the render, say so.
- **`ce-explain`, `ce-ideate`.** Skip. `AGENTS.md` Evidence Discipline already holds the rules of `ce-explain`. `ce-ideate` is an expensive idea fleet that feeds a pipeline we do not run.

### Git, PR, ops and testing

- **`ce-commit`.** Harvest into `ship-session` § 5 (`SKILL.md:46-58`). Stage named paths, and commit with a pathspec (`git commit -F <msg> -- f1 f2`), so that work the user staged earlier cannot ride along. Today only `parallel-sessions` states path-limited staging.
- **`ce-resolve-pr-feedback`.** Skip, because it posts and resolves threads by default. Harvest into `review-staged` step 3 (`references/evaluation-rubric.md:18-25`). For a finding against instruction prose (a `SKILL.md`, references, a rule file): if the stated condition already decides the case, it is not a fix. Fix the condition or move the rule, and never "add the case". On a second round against the same block, remove the additions and restate the block. This repo is mostly instruction prose.
- **`ce-handoff`.** Harvest only if we vendor `handoff`, which is a community install today (`references/create.md:72,76`). At each pointer, name what matters there, with a line range. Mark each decision as the user's, an inference, or the agent's own call.
- **`ce-commit-push-pr`, `ce-babysit-pr`, `ce-sweep`, `ce-polish`, `ce-dogfood`.** Skip. Each one commits, pushes or posts on its own.
- **`ce-proof`, `ce-promote`, `ce-product-pulse`, `ce-riffrec-feedback-analysis`, `ce-test-xcode`.** Skip. Vendor products, analytics, or platforms we do not use.
- **`ce-test-browser`.** Skip. Native `/run` covers it, and it forbids Playwright, which we use through MCP.

## The lesson store

The proposed minimum is modelled on `decision-record`, which fills the same kind of gap for decisions:

- **Store.** `docs/solutions/<slug>.md`, one lesson per file. Frontmatter: `title`, `applies_when` (a situation, not a topic), `tags`. Body: Problem, Symptoms, What didn't work, Solution, Why, Prevention (`ce-compound/references/research.md:97-104`).
- **Writer.** A new `lesson-record` skill, or one step in `diagnosing-bugs` Phase 5 and in `ship-session` step 2. It applies the counterfactual bar and the form ladder: a test or a lint rule first, a lesson only for what code cannot hold. "Not worth a lesson" is a valid result, as "Not worth an ADR" is in `decision-record`.
- **Readers.** The readers matter more than the writer. `craft` and `diagnosing-bugs` already read `docs/adr/`. Each of them, and `multi-session-plan`, also reads the `docs/solutions/` entries whose `applies_when` matches the area. Upstream greps the frontmatter first and reads bodies only on a match (`ce-plan/references/research.md:19,57`).
- **Boundaries.** `papercuts` stays for friction in the environment, and `revise-claude-md` stays for what the user taught. The lesson store is for what the product code taught.

This is a design fork. Record it with `decision-record` before we build it.

## Ideas worth noting that are not skills

- **Name what you did not check.** A review report names what it did not assess and counts the findings that policy removed (`ce-code-review/references/depth-paths.md:26`), "so a quiet review never looks cleaner than it was". `review-staged` lists refuted findings, but it has no "not assessed" line.
- **Pre-existing against newly exposed** (`ce-code-review/references/subagent-template.md:149`). If the diff newly calls broken code, the bug belongs to the diff. A truly pre-existing bug could become a `census` row instead of being dropped.
- **Enforced against cooperative.** Before content leaves the machine, label each restriction as enforced or cooperative (`ce-work/references/cross-model-execution.md:75-83`). `ce-pov/scripts/cross-model-pov.sh:464` says: "The codex adapter does not enforce its read-only mode." That concerns their ACP adapter mode, not `codex exec -s read-only`, which `third-opinion` uses (inferred, not tested).
- **Cost notice before a fan-out** (`ce-ideate/references/scope-gates.md:129-133`). Before a multi-agent dispatch, state the cost in one line.
- **Author-side PR feedback.** Our kit reviews other people's MRs (`review-mr`), but nothing answers review feedback on our own PR or MR. The verdict lists (fix, reply, decline, needs-human) and the reply templates in `ce-resolve-pr-feedback/references/evaluation-rubric.md:91-147` are a start if we build one in the write-to-file, do-not-post style.

## Proposed changes

The grill decided which of these to apply. See the Outcome section.

1. Lesson store: an ADR, then the writer skill and the three reader lines.
2. `verifier`, `review-staged`, `review-mr`: the UNRESOLVED verdict for protected subjects.
3. `diagnosing-bugs`: name the bound, plus the WIP, past-PR and always-on-signal steps.
4. `AGENTS.md` § Before You Add Code: the two-condition test and "never narrow requested behavior". The `multi-session-plan` template gets "Considered and not built".
5. `papercuts`: the cheapest-fix order, declined fixes, and grading landed fixes.
6. `review-staged` step 3: instruction prose is not code, and settled decisions are report-only.
7. `craft` § 3: break each guard alone, no test-only hooks, remove dead approaches, references to deleted files, and the two false-confidence test shapes.
8. `ship-session` § 5: the pathspec commit.
9. Smaller single lines: `grill-me` (settlement, integration check), `multi-session-plan` (safe after every merge, one owner per rule, stable IDs), `doc-check` (already shipped), `third-opinion` (agreement is not proof, depth by consequence), `decision-record` (do-nothing option), `design-an-interface` (counterexample), `prototype/UI.md` (look at the render), `parallel-sessions` (base SHA), `AGENTS.md` § Comments (no plan IDs).
10. Decisions for the user: replace `stop-slop` with a vendored `ce-noslop`; add `wtf`.

## Evidence

- Executed: we cloned the repo at `fcb5e3ad` into a scratch directory. Six read-only subagents read every `SKILL.md` in full, read the references selectively, and compared each one against our skills, `AGENTS.md` and `skill-flow.md`. We spot-checked these citations against both trees, and they match: `ce-compound/SKILL.md:33`, `ce-compound/references/form.md:9-21`, `ce-debug/references/investigate.md:34`, `ce-plan/references/structure.md:150-161`, `ce-babysit-pr/SKILL.md:29`, `ce-code-review/references/validator-batch-template.md:27-45`, `ce-retro/references/placement-and-routing.md:7-15`, `ce-resolve-pr-feedback/references/evaluation-rubric.md:18-25`, `ce-pov/scripts/cross-model-pov.sh:464`, and our `verifier.md:26`, `review-staged` step 1 and step 2 and the security line of step 3, and `anti-slop-eval.md:29`.
- Inferred, read by a subagent only: the other line citations, and the "not covered" claims about our skills. Each claim rests on a subagent's grep. One subagent found that a plain `grep` came back empty through the `rtk` rewrite where a redirected `grep` found the hit (logged in `~/.papercuts/log.md`). Re-check each "not covered" claim when you apply its change.
- Not executed: any upstream script, its test suite, any skill run, and the base-SHA drift that upstream reports for harness worktrees.

## Outcome (2026-11-24)

A grill settled the proposals. [The harvest plan](../compound-engineering-harvest-plan.md) records each change as built.

1. The lesson store is built as `lesson-record` plus three reader lines, per [ADR-0001](../adr/0001-lesson-store.md). The store path is `docs/lessons/`, not the proposed `docs/solutions/`. Its falsifier: no lesson cited in any product repo by 2027-02-24.
2. Changes 2, 3, 4, 6, 7 and 8 are applied as proposed. In change 9, four items were dropped: stable IDs, the base-SHA check, no plan IDs in comments, and depth by consequence.
3. `stop-slop` is now a custom skill for prose that people read. It merges the `ce-noslop` body and catalog with three rules from the old `stop-slop`, and replaces the upstream install. `simple-english` keeps text a reader follows exactly. `wtf` is vendored.
4. Change 5 (`papercuts`) waits. The papercuts log had 85 open entries and no `notes.md`, so the triage had never run. Tune it after its first run.
5. Not done: none of the edited skills has been run since its edit.
