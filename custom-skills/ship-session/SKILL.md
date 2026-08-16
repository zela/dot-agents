---
name: ship-session
description: >-
  Close out a finished build session in a docs/-based plan: confirm the gates are
  green, convert the session doc from forward-plan to as-built reference, keep the
  index short and truthful, move raw evidence out, commit. Use when the user wants
  to "ship / finish / close out / wrap up a session", "mark a session done",
  "convert the plan to a reference", or finalize a session's work. This is the DOC
  ritual only — it does not review code; that is /code-review. Companion to
  multi-session-plan.
---

# Ship a Session

## What this does

The closing ritual for one build session in a `docs/`-based plan. It is a **documentation** job with one gate in front of it: confirm the work passes its acceptance checks, then turn the forward-looking plan into a grounded record of what shipped, keep the index truthful, and commit.

The point is to keep the plan **self-maintaining**. The index is the project's memory across sessions — if it drifts from reality, the next session re-derives context from zero.

**Scope discipline:** this skill is deliberately small. It does **not** review code — reviewing a diff, triaging findings and fixing them is separate work with its own judgement load, and `/code-review` already does it. If the session wants a review, that is a separate invocation before this one. A heavy ritual is a ritual nobody invokes.

## The boundary — read this first

- **Don't make product, composition, or architecture decisions.** Those belong to the human. If closing the session surfaces such a choice, stop and ask.
- **Don't flip the status marker on unverified work.** "Done" is a claim, not a proof. Mark it only after the acceptance checks actually pass **in this run** — never on the basis of "it should pass."
- **Don't expand the job.** Bugs, cleanups and refactors noticed while converting get *reported*, not fixed. The diff this produces should be docs plus a status marker.

When you hit one of those edges, hand back rather than push through. That checkpoint is the point; do not optimize it away.

## Steps

### 1. Confirm before you tick

Open the session doc, find its acceptance / verification section, and run the project's real quality gates — **discover them, don't assume**: check `CLAUDE.md` / `AGENTS.md` / `package.json` scripts / `Makefile`. Typically build + typecheck + lint + test.

If a gate fails, stop and report the failure with its output. Do not proceed.

If a criterion is subjective (visual composition, editorial voice, "reads well") or needs a surface you can't reach (a browser, production data), you cannot self-grade it. Say so plainly and name who has to check — an unverifiable criterion is not a passed one.

### 2. Convert the plan — never append to it

Rewrite the session doc **in place**, from forward plan into as-built reference, preserving its section structure:

- Future → past tense: "will extract" → "extracts". "Files to create" → the real files, with paths.
- Planned specifics → what actually shipped: real function and module names, the approach taken, test counts.
- Record **deviations from the plan** and **gotchas hit**. These are the highest-value lines in the doc — a later session learns from them, and they are the first thing lost if you rush.

**The failure mode this step exists to prevent is the append.** Stacking `## As-built — session 1`, `## As-built — session 2` under a design section still written in the future tense is how a 120-line plan becomes an unreadable 300-line one, with the reader left to work out which half is true. Fold each session into the section whose design it realises. If the plan already carries stacked as-built sections from earlier sessions, folding them in is part of this step, not a separate cleanup.

**If the plan opens with a head block / summary** (a five-line "problem, fix, decision, status, left" preamble or similar), that is the *first* thing to update — it is the part a human actually reads, and a stale one makes the whole doc untrustworthy.

Honour the project's prose conventions (e.g. a "one paragraph per line, no hard wraps" rule).

### 3. Update the index

In the overview doc (`00-overview.md` or equivalent):

- **Read the index's own status legend and use its markers.** Projects differ — some use `☐`/`◐`/`☑`, others `·`/`▶`/`◧`/`✓`. Never impose a vocabulary the file doesn't use.
- Keep the row **short** — one line: status + link + why the plan exists. An index is for scanning, and detail belongs in the plan (its head block, if it has one). If a row has already grown into a paragraph, this is the moment to cut it back, not to extend it.
- Update any aggregate counts the index tracks (test totals, page counts, cohort numbers) so they stay accurate.

### 4. Move raw evidence out

Sweep dumps, hand-classifications, gate output, measurement tables: these belong in `docs/evidence/` (or wherever the project already puts them), not inline. The plan states the verdict in a sentence and links the file. Conversion can absorb a session log; it cannot absorb a 30 KB measurement.

**Use length as a trigger, never as a cap.** A converted plan past ~150 lines is the signal to ask *which tier* the excess belongs to — raw evidence that should be in its own file, or a design section that was appended to rather than converted. Do not respond by compressing the prose: a budget on wordcount buys denser prose, not clearer docs, and dense-but-short is the more common failure of the two.

If the session settled a trade-off, record it where the project keeps decisions — with the rationale and a "revisit if…" trigger, so it isn't re-litigated later.

### 5. Commit

Check the repo's conventions first, don't assume:

- **Branch policy** — some repos want a feature branch; others (solo, session-sized history) commit straight to the default branch. Check project memory and recent history before branching.
- **Message style** — match the existing log. Follow any docs-vs-feature commit separation the repo keeps, and include any required trailer.
- **Approval** — if the project or user memory requires explicit per-commit approval, ask rather than assume this skill grants it.

Then report: gates status, what was converted, the commit, and anything left for the user — subjective acceptance items especially.

## The core, if you remember nothing else

**Verify before you tick. Convert rather than append. Keep the index short and truthful. Commit.** Everything else scales with the project's ceremony — a small plan may have no evidence folder and no decision log, and then step 4 is just "note anything surprising."
