---
name: craft
description: Make it work, then make it right. Design checks before the first edit of a code change, and finish checks with CRAP and duplication scores before you call it done. Use when a change adds a variant to a domain type, writes data (a migration, backfill, job, webhook, or form submit), parses outside input (URL, storage, API, env), touches state that several actors update, extends an already complex function, or refactors; when scoring a branch's changed files; or when the user says "craft".
---

# Craft

Make it work, then make it right. The red-green loop belongs to `tdd`. A bug belongs to `diagnosing-bugs`. Domain words belong to `domain-modeling`. For a one-line fix or a mechanical change, do step 3 only.

Before step 1, read `CONTEXT.md` if it exists. Read the ADRs in `docs/adr/` for the area you touch.

## 1. Shape

Give each item an answer before the first edit to the logic. Most answers are one line. "Not applicable" is an answer.

- **Data shape first.** Write the types for the change before the functions. Make illegal states unrepresentable. For example, a discriminated union replaces booleans and optional fields that are valid only in some combinations. If a shape is clear and local, keep it.
- **Parse at the boundary.** Name each place where outside data enters: a request body, a form, URL params, `localStorage`, env, a file, a third-party response. Parse the data there once, into a domain type, with the validator the project uses. The code inside trusts that type. Keep decisions in pure functions, and put I/O at the edges.
- **One decision, one place.** If the rule you plan to write exists already, call it. If it exists in two places, join them first.
- **Make the change easy, then make the easy change.** If the code around the change makes it hard, reshape that code first. Do the reshape as its own step, with the behaviour unchanged and the tests green.
- **Edit or redesign.** If the requirement becomes a special case in a shape that did not expect it, redesign. The signs are a new boolean flag, the same new branch in several places, or a parameter that only one caller passes. Reshape as if the requirement existed from the start. Deliver the reshape in steps that each leave the tests green (expand–contract, as in `multi-session-plan`). In all other cases, make the smallest edit.
- **Idempotent.** Make each thing that writes idempotent: a migration, a script, a handler, a retry, a webhook, a form submit. If it runs twice, or runs again after a crash halfway, the end state is the same.
- **Single writer.** If two actors (components, requests, workers, tabs) use the same mutable state, give each actor its own copy. If they must share the state, allow one writer. Make the structure enforce it: one module owns the state, and the other actors call that module.

Done when each item has an answer and your reply shows the answers as a **Shape** note, before the first edit. The note has one line for each item that applies, and one line that lists the items that do not apply. If you plan the change with the user, the Shape note is part of the plan.

## 2. Work

Build in vertical slices with `tdd`: one test, one minimal implementation, then the next slice. Each slice ends green. A slice can leave the code mid-reshape only if the plan says so and the step is reversible.

When you are stuck:

- **Name the premise.** If a second fix fails the same check, write the assumption that both fixes share in one sentence. Test that assumption directly, with a loop as in `diagnosing-bugs`. If the assumption is false, drop every fix that rests on it. Then try the next fix.
- **Build the lever.** If the remaining work is many similar units that are not obvious at a glance, do one unit by hand. Write a script that produces that unit. Diff the script output against your hand-made unit until the two match. Then run the script on the rest. A long run goes to `run-state`.

Done when the planned slices are green.

## 3. Right

Before you call the change done, go through each item against the diff.

- **Fix the type, not the checker.** The diff passes the project's own type checker and linter as written. If the project has none, say so in the Right note. Each `any`, `as`, non-null `!`, `@ts-ignore`, `@ts-expect-error`, or `eslint-disable` in the diff becomes a true type. If it must stay, give it a one-line reason that a reviewer can accept.
- **Both sides of each boundary.** For each threshold, limit, or range in the change, a test sits on each side of it: exactly 500 and 499.99, the last valid value and the first invalid one.
- **Empty-return test.** For each new or changed test, imagine that the function under test returns `undefined`, `[]`, or `{}`. If the test still passes, it proves nothing. Sharpen the assertion until it fails for that return.
- **Pin, change, prove.** Start a refactor from a test that pins the current behaviour. Change the structure. Then run that test unchanged.
- **Root cause.** Fix the cause at the lowest shared layer. A guard that only hides the crash leaves the bug in place. Give a real bug to `diagnosing-bugs`.
- **Scores on the changed files.** Read [references/scores.md](references/scores.md) first, because the run has a cost. Then run [scripts/check-changed.sh](scripts/check-changed.sh) from the project root. To score a whole branch, run `check-changed.sh --since <branch>`.

Done when each item has an answer and your reply ends with a **Right** note. The note has one line for each item that found something, with what you did about it, and one line that lists the items that found nothing. Keep the rest of the reply to the result and what the user must decide.

---

<sub>Rewritten from [unclebob/ub-mode](https://github.com/unclebob/ub-mode) at `57a8bdd`, which builds on poteto's `poteto-mode`. Kept: First Make it Work and Then Make it Right, as checks at the moment each applies. Dropped: the Practice section, which `AGENTS.md` covers or contradicts (push to main, reclaim disk, delete dead code). Also dropped: the TDD and test-behaviour rules, which `tdd` owns. Changed: crapper and dryer run on changed files only, through a wrapper that installs nothing. Deferred: mutator. See [the evaluation](../../docs/notes/ub-mode-eval.md).</sub>
