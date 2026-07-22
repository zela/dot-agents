---
name: ship-session
description: >-
  Close out a completed build session from a multi-session plan: verify its
  acceptance checks actually pass, optionally run a review pass, convert the
  session doc from forward-plan to as-built reference, tick its box and update
  counts in the overview index, capture findings/decisions, and commit. Use when
  the user wants to "ship / finish / close out / wrap up a session", "mark a
  session done", "convert the plan to a reference", or finalize a session's work.
  Companion to multi-session-plan, which creates the plan this skill closes out.
---

# Ship a Session

## What this does

The closing ritual for one build session in a `docs/`-based multi-session plan (the kind `multi-session-plan` produces). It performs the **mechanical and verification half** of "convert plan → as-built reference": confirm the work actually passes its acceptance checks, turn the forward-looking session doc into a grounded record of what shipped, update the index so status stays truthful, capture anything learned, and commit.

The point is to keep the plan **self-maintaining**. The overview index is the project's memory across sessions — if it drifts from reality, the next session re-derives context from zero. This skill is what makes the loop compound instead of leak.

## The boundary — read this first

This skill does the mechanical and verification work. It explicitly does **not**:

- **Make product, composition, or architecture decisions.** Those belong to the human. If closing the session surfaces such a choice, stop and ask.
- **Auto-apply review findings.** Surface them and let the user decide what's worth fixing ("fix what makes sense"). Apply only what the user greenlights, or only obvious mechanical nits if the user has pre-authorized that.
- **Flip the status box on unverified work.** "Done" is a claim, not a proof. Tick `☑` only after the acceptance checks actually pass in this run — never on the basis of "it should pass."

When you hit one of those edges, hand back to the user rather than pushing through. This is the deliberate human-in-the-loop checkpoint; do not optimize it away.

## Steps

### 1. Verify acceptance

Open the session doc and find its **Acceptance / verification** section. Run the project's real quality gates — discover them, don't assume (check `AGENTS.md` / `CLAUDE.md` / `package.json` scripts / `Makefile`). A typical set is build + typecheck, lint, test, format-check. Run each and confirm green. If any acceptance criterion is subjective (visual composition, editorial voice, "reads well"), you cannot self-grade it — flag it for the user.

If a gate fails: stop. Report the failure with output. Do not proceed to flip the box.

### 2. Review pass (maker ≠ checker)

Run a review on the session's diff — the project's review skill/subagent if one exists (e.g. `/code-review`, a `code-reviewer` or domain reviewer subagent), otherwise a focused review of the changed files. Use a *different* agent than the one that wrote the code where possible; the author is too generous grading its own work.

Present findings grouped by severity. The user triages. Apply only what they approve. Re-run gates after any fix.

### 3. Convert plan → as-built reference

Rewrite the session doc from a **forward plan** into an **as-built reference**, preserving its section structure (don't reinvent the headings):

- Future → past tense: "will extract" → "extracts"; "Files to create" → the real files that now exist, with paths.
- Replace planned specifics with what actually shipped — real function/module names, the approach taken, test counts.
- Record **deviations from the plan** and **gotchas encountered** explicitly. These are the highest-value lines in the doc; a later session learns from them.
- Keep it scannable and executable as a description of current reality — enough to understand the subsystem without re-reading all the code, not a duplicate of it.

Honor the project's prose conventions (e.g. a "one line per paragraph, no hard wraps" rule if the repo has one).

### 4. Update the index

In the overview doc (`00-overview.md` or equivalent):

- Flip the session's status box `☐`/`◐` → `☑` (legend: not started · in progress · done).
- Add the commit hash + a one-line milestone result in the Notes column.
- Update any **aggregate counts** the index tracks (total tests, generated pages, data-cohort numbers) so they stay accurate.

### 5. Capture findings & decisions

If the session produced genuine investigations (a data-quality dig, a perf finding, a reconciliation), write or extend a `findings-*.md`. If it settled a trade-off, append to the **decisions log (ADR-lite)** with rationale and a "revisit if…" trigger — so it isn't re-litigated later. This is the loop's memory; skipping it is how knowledge evaporates between sessions.

### 6. Commit

Commit per the repo's conventions — check first, don't assume:

- **Branch policy:** some repos want a feature branch; others (solo, session-sized history) commit straight to the default branch. Check project memory / recent history before branching.
- **Message style:** match the existing log (conventional commits, session tags like `feat: session N — …`). If the repo separates docs commits from feature commits, follow that.
- Include any required trailer (e.g. a `Co-Authored-By` line) the repo uses.

Then report what shipped: gates status, what the review surfaced and what was fixed, the commit, and anything left for the user (subjective acceptance items, deferred findings).

## Adapting to scale

A small 3-session plan may have no separate review skill, no findings docs, and no ADR log — then steps 2 and 5 collapse to "eyeball the diff" and "note anything surprising in the session doc." The non-negotiable core is always: **verify before you tick, convert the doc to reflect reality, keep the index truthful, commit.** Everything else scales with the project's ceremony.
