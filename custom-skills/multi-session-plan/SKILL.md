---
name: multi-session-plan
description: 'Create and maintain a multi-session implementation plan as linked markdown docs under a project''s docs/ folder: an overview/index, one doc per build session, and a deferred-work roadmap. Use when the user wants to plan a build across sessions, break a large feature or greenfield project into a sequenced roadmap, turn a PRD/design/spec into a staged plan, or track progress across sessions, including "plan this out", "break this into steps", "make a roadmap". Also use to edit/extend an existing plan: add a session, re-sequence, or tick off completed work.'
---

# Multi-Session Implementation Plan

## What this produces

A small, navigable set of markdown files under `docs/` that a team (or a sequence of fresh AI sessions) can execute one session at a time. The deliverable is **planning docs, not code**. Someone can open `docs/00-overview.md` and see exactly where the build stands. Then they pick the next session, with everything they need to execute it and no context to re-derive.

```
docs/
├── 00-overview.md        # index: status table, dependency graph, risks, decisions log
├── architecture.md       # stack, repo layout, data flow, env, reuse pointers
├── data-model.md         # canonical types/schemas + reconciliations  (omit if no shared data contract)
├── session-00-*.md       # one doc per session
├── session-01-*.md
│   …
└── <stage-n>-roadmap.md  # deferred stages, lighter detail
```

`data-model.md` is optional — include it when sessions share a data contract (types, schemas, API shapes). For a pure-UI or scripting effort, skip it.

Bundled templates live in `assets/templates/`. Read them when writing each doc and fill the placeholders — do not reinvent the structure. The templates are the contract that keeps every session doc uniform.

## Why this shape works

- **The overview is the single source of truth for status.** A checkbox table means anyone can glance and know what is done. Keeping plans *executable across sessions* is the whole point. Sessions lose context, so the docs must carry it.
- **Sessions are uniform** (same seven headings) so executing one is muscle memory, and **scoped to roughly one working block** so they finish.
- **The dependency graph prevents false linearity.** Most plans look like a straight chain but are not. Surfacing what is parallel lets work proceed on independent tracks. It also shows the true bottleneck session.
- **The decisions log (ADR-lite) captures *why*,** so a later session does not re-litigate a settled trade-off, and a wrong call is easy to find and revisit.

## Workflow

Do not jump straight to writing docs. A good plan is mostly research and a few sharp decisions. The writing is the easy part.

### 1. Explore the codebase first

Understand what already exists before planning anything new. Look for: existing patterns to match, utilities/pipelines to reuse, the build/deploy setup, conventions (lint, test, types), and any prototype or spec docs. If a sibling repo or monorepo is referenced, explore it too — reuse beats rebuild.

Prefer launching `Explore` (or general-purpose) subagents in parallel for breadth. You want the conclusions, not the file dumps. Capture concrete file paths. They become the "Reuse references" in each session doc.

### 2. Resolve the decisions that change the plan

Before sequencing, surface the choices that genuinely reshape the work, and ask the user rather than guessing. The recurring high-impact ones:

- **Data/dependency availability** — is the real data source / upstream dependency available now, or do early sessions work against mocks/fixtures behind an adapter?
- **Code location** — new repo, existing repo, or monorepo package? (Watch for ownership/IP boundaries when a personal project touches client code, or vice versa.)
- **Scope depth** — how many stages get detailed now vs left as a lighter roadmap?
- **Build order** — **frontend-first** (reach a clickable UI on fixtures early, then back it with real data behind a stable contract) or **data-first** (pipeline produces real outputs, then UI consumes them)? Frontend-first gives visible progress and makes sure the UX works early. Data-first surfaces real numbers and data-shape problems early. Pick per the project's main risk.

Use `AskUserQuestion` for these — they are real forks, and recommend a default with reasoning. Record each answer in the decisions log.

### 3. Fix the shared contract (if any)

If sessions exchange data, nail the canonical model **once** in `data-model.md` before sequencing: the types/schemas, where they live so every track imports one source, and any reconciliation between a prototype's shape and a spec's shape. This contract is what lets a "frontend-first" plan swap mocks for real data with near-zero UI change. Make that seam explicit.

### 4. Sequence the sessions

Break the work into sessions of roughly one working block each. For every session decide: what it depends on, what it produces, and how you will know it is done.

- **Front-load the foundation**: scaffold, then the shared contract — these unblock everything.
- **Map true dependencies, not a default chain.** Draw the dependency graph (see overview template). Identify independent tracks (for example, a UI track on fixtures running parallel to a data track) and the single join session where they merge.
- **Flag oversized sessions** (for example, "port three complex components + assemble page") and note a split (2a/2b) rather than pretending it fits.
- **Name the cross-cutting risks** that span sessions — data gaps, full-cohort/whole-dataset requirements that break partial-run dev modes, volume/perf limits, statistical caveats — and put each in the risks register pointing at the session that handles it.
- **Wide refactors are the exception to vertical slicing.** A wide refactor is one mechanical change (rename a column, retype a shared symbol) whose blast radius fans across the whole codebase, so no single session can land green. Sequence it as **expand–contract**: an *expand* session adds the new form beside the old, so nothing breaks; *migrate* sessions move the call sites over in batches sized by blast radius (per package, per directory), each green because the old form still exists; a *contract* session deletes the old form once no caller remains. When even the batches cannot stay green alone, keep the sequence on an integration branch and promise green only at a final integrate-and-verify session. The migrate sessions are the archetypal `run-state` run.

### 5. Write the docs

Use the templates. Write `00-overview.md` and `architecture.md` first (and `data-model.md` if needed), then one session doc per session, then the roadmap. Every session doc gets all seven sections — an empty "Out-of-scope" is a smell that scope is not pinned.

The roadmap holds the fog: stages you can see coming but cannot yet specify. The test for whether an item is a session or a roadmap entry is not whether you can answer it now but whether you can **state its question precisely** now. A precise question is a session, even if it is blocked. A vague one stays in the roadmap until an earlier session sharpens it. Do not pre-slice the fog into session-sized pieces; one roadmap entry can become several sessions, or none.

Keep each doc **scannable but executable**: enough that a fresh session can act without re-discovery, not so much that it duplicates the codebase. Link liberally between docs (overview ↔ sessions ↔ data-model). Reference real file paths found in step 1.

Make sure before you finish: does every output produced by one session get consumed by a later one? Does every "needs X" have a session that produces X earlier? A benchmark series used by the backtest but never extracted is the classic miss. Trace each data dependency end to end.

### 6. Maintain the plan

This skill also edits existing plans. When a session completes, **tick its box in the overview table** (`☐` → `☑`) and add the commit/PR link in the Notes column. When scope shifts: add or split a session doc, update the dependency graph, and append to the decisions log rather than silently rewriting history. The plan is a living document. Its value is that it always reflects reality.

## Status legend (use consistently)

`☐` not started · `◐` in progress · `☑` done. Tick when a session's Acceptance checks pass.

## Adapting to scale

Match the ceremony to the project. A 3-session feature does not need a risks register or a data-model doc — an overview with a status table plus three session docs is plenty. A multi-stage greenfield build wants the full set. Start with the overview + session docs. Add architecture / data-model / roadmap / risks only when they are carrying weight. When in doubt, fewer docs that stay current beat a thorough set that goes stale.

---

<sub>Expand–contract and the "fog or session" test are harvested from `to-tickets` and `wayfinder` in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
