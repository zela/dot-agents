# Evaluating self-improvement-loops

[`self-improvement-loops`](https://github.com/muratcankoylan/Agent-Skills-for-Context-Engineering/tree/main/skills/self-improvement-loops) from muratcankoylan/Agent-Skills-for-Context-Engineering, last changed at `7638f30` (2026-10-01), MIT. It is one of 19 skills in a context-engineering collection. It has a 22 KB `SKILL.md` and one 14 KB reference, `loop-design-evidence.md`, with dated per-paper results. We evaluated it on 2026-11-25 against the meta-loop in the [skill flow](skill-flow.md).

## Verdict: skip the skill, keep one warning

The skill is a well-sourced survey for people who build automated optimizers: a loop that proposes edits to its own harness, scores each candidate on a benchmark, and keeps the winners. It covers the optimization ladder (prompt → context → workflow → harness code → optimizer code), two-split acceptance gates, experience archives, diversity preservation, and reward hacking.

Our meta-loop is not that kind of loop. `papercuts`, `lesson-record` and `revise-claude-md` propose changes, and the user accepts each one by hand. The skill's own readiness checklist rules it out. Item 1 asks for "a fast, deterministic, automatable evaluator", and the skill says that domains with slow, ambiguous or judge-only evaluation "are where this loop family fails". Our only skill evaluator is a skill-creator run with model-graded assertions ([papercuts eval](papercuts-eval.md)). That evaluator is slow and judge-only.

Further reasons to skip:

- It is a reference essay, not a procedure. It has no steps for an agent to follow, and it loads 22 KB to give advice that we cannot act on.
- It routes work to six sibling skills that we do not install (`harness-engineering`, `evaluation`, `advanced-evaluation`, `hosted-agents`, `project-development`, `self-managed-context`). Without those skills, the routing text points at nothing.
- Its description is about 600 characters and names "self-improving harnesses". It could trigger on our own config work (`papercuts`, `lesson-record`), where it does not apply.

## What already maps to the kit

Most of the rules that transfer are already in the kit:

- **Same-model generator and evaluator** (gotcha 7). `third-opinion` and the cross-provider option in `doc-check` cover this ([claudex-loop eval](claudex-loop-eval.md)).
- **Self-reported success. Bind each number to a raw artifact** (gotchas 3 and 9). This is the Evidence Discipline section of `AGENTS.md` and the SHA-256 binding in `doc-check`.
- **Fix at the lowest rung that can express the fix.** This is the "Before You Add Code" ladder, and the `instruction` versus `fix` dispositions in `papercuts`.
- **Keep rejected candidates as first-class artifacts.** Every eval note records what we rejected and why. `docs/ideas.md` asks for the same.
- **Itemized deltas, never a monolithic rewrite** (gotcha 4). `papercuts` uses targeted edits and never writes the whole log back. The memory rules update one file per fact.
- **Constraints in prompt text evolve away. Enforce them in the runtime** (gotcha 1). This is why `hooks/` exists next to `AGENTS.md`.

## The one warning worth keeping: brevity bias

The skill names two failure modes of a loop that rewrites its own instructions (§ Context Evolution). The evidence comes from the ACE paper (arXiv 2510.04618):

- **Brevity bias.** An optimizer converges on short, generic instructions and drops the domain-specific heuristics that carried the value.
- **Context collapse.** One monolithic model rewrite shrank an accumulated context from 18,282 tokens to 122 tokens. Accuracy dropped below the baseline with no adaptation.

The [skill-trim plan](../skill-trim/00-overview.md) is a human-gated version of that loop. It already has the right guard: "each removed behaviour is either listed as an intended cut in the session doc or restored". That rule turns each trim into an itemized delta. The plan measures `wc -w`, but no step checks behaviour. A word count rewards brevity bias. If a trim session cuts a skill heavily, run a skill-creator comparison of the old and the new skill on two or three cases. Use cases that the editor did not write, so that they act as a held-out split. That is an option for the plan's owner, not a change that we made.

## Evidence

- Executed: we fetched `SKILL.md` and `references/loop-design-evidence.md` through the GitHub API and read both in full. We listed the sibling skills, the license and the last commit for the path. We grepped `docs/skill-trim/` for regression and eval steps, and found the intended-cut rule and the `wc -w` step.
- Not executed: the skill was not installed or run. We did not check its paper citations or the numbers in the reference file. The reference file says that its 2026 results are "single-lab and mostly unreplicated".
- Not checked: the other 18 skills in the collection. Several of them (`evaluation`, `harness-engineering`, `memory-systems`) can overlap the kit more than this one does.
