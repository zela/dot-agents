---
name: multi-session-plan
description: >-
  Create and maintain a multi-session implementation plan as linked markdown
  docs under a project's docs/ folder — an overview/index, one doc per build
  session, and a deferred-work roadmap. Use when the user wants to plan a build
  across sessions, break a large feature or greenfield project into a sequenced
  roadmap, turn a PRD/design/spec into a staged plan, or track progress across
  sessions — including "plan this out", "break this into steps", "make a
  roadmap". Also use to edit/extend an existing plan: add a session, re-sequence,
  or tick off completed work.
---

# Multi-Session Implementation Plan

## What this produces

A small, navigable set of markdown files under `docs/` that a team (or a sequence of fresh AI sessions) can execute one session at a time. The deliverable is **planning docs, not code** — the goal is that someone can open `docs/00-overview.md`, see exactly where the build stands, pick the next session, and have everything they need to execute it without re-deriving context.

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

Bundled templates live in `assets/templates/`. Read them when writing each doc and fill the placeholders — don't reinvent the structure. The templates are the contract that keeps every session doc uniform.

## Why this shape works

- **The overview is the single source of truth for status.** A checkbox table means anyone can glance and know what's done. Keeping plans *executable across sessions* is the whole point — context is lost between sessions, so the docs must carry it.
- **Sessions are uniform** (same seven headings) so executing one is muscle memory, and **scoped to roughly one working block** so they finish.
- **The dependency graph prevents false linearity.** Most plans look like a straight chain but aren't — surfacing what's actually parallel lets work proceed on independent tracks and shows what the true bottleneck session is.
- **The decisions log (ADR-lite) captures *why*,** so a later session doesn't re-litigate a settled trade-off, and a wrong call is easy to find and revisit.

## Workflow

Don't jump straight to writing docs. A good plan is mostly research and a few sharp decisions; the writing is the easy part.

### 1. Explore the codebase first

Understand what already exists before planning anything new. Look for: existing patterns to match, utilities/pipelines to reuse, the build/deploy setup, conventions (lint, test, types), and any prototype or spec docs. If a sibling repo or monorepo is referenced, explore it too — reuse beats rebuild.

Prefer launching `Explore` (or general-purpose) subagents in parallel for breadth; you want the conclusions, not the file dumps. Capture concrete file paths — they become the "Reuse references" in each session doc.

### 2. Resolve the decisions that change the plan

Before sequencing, surface the choices that genuinely reshape the work, and ask the user rather than guessing. The recurring high-impact ones:

- **Data/dependency availability** — is the real data source / upstream dependency available now, or do early sessions work against mocks/fixtures behind an adapter?
- **Code location** — new repo, existing repo, or monorepo package? (Watch for ownership/IP boundaries when a personal project touches client code, or vice versa.)
- **Scope depth** — how many stages get detailed now vs left as a lighter roadmap?
- **Build order** — **frontend-first** (reach a clickable UI on fixtures early, then back it with real data behind a stable contract) or **data-first** (pipeline produces real outputs, then UI consumes them)? Frontend-first gives visible progress and validates UX early; data-first surfaces real numbers and data-shape problems early. Pick per the project's main risk.

Use `AskUserQuestion` for these — they're real forks, and recommend a default with reasoning. Record each answer in the decisions log.

### 3. Fix the shared contract (if any)

If sessions exchange data, nail the canonical model **once** in `data-model.md` before sequencing: the types/schemas, where they live so every track imports one source, and any reconciliation between a prototype's shape and a spec's shape. This contract is what lets a "frontend-first" plan swap mocks for real data with near-zero UI change — make that seam explicit.

### 4. Sequence the sessions

Break the work into sessions of roughly one working block each. For every session decide: what it depends on, what it produces, and how you'll know it's done.

- **Front-load the foundation**: scaffold, then the shared contract — these unblock everything.
- **Map true dependencies, not a default chain.** Draw the dependency graph (see overview template). Identify independent tracks (e.g. a UI track on fixtures running parallel to a data track) and the single join session where they merge.
- **Flag oversized sessions** (e.g. "port three complex components + assemble page") and note a split (2a/2b) rather than pretending it fits.
- **Name the cross-cutting risks** that span sessions — data gaps, full-cohort/whole-dataset requirements that break partial-run dev modes, volume/perf limits, statistical caveats — and put each in the risks register pointing at the session that handles it.

### 5. Write the docs

Use the templates. Write `00-overview.md` and `architecture.md` first (and `data-model.md` if needed), then one session doc per session, then the roadmap. Every session doc gets all seven sections — an empty "Out-of-scope" is a smell that scope isn't pinned.

Keep each doc **scannable but executable**: enough that a fresh session can act without re-discovery, not so much that it duplicates the codebase. Link liberally between docs (overview ↔ sessions ↔ data-model). Reference real file paths found in step 1.

Cross-check before finishing: does every output produced by one session get consumed by a later one? Does every "needs X" have a session that produces X earlier? A benchmark series used by the backtest but never extracted is the classic miss — trace each data dependency end to end.

### 6. Maintain the plan

This skill also edits existing plans. When a session completes, **tick its box in the overview table** (`☐` → `☑`) and add the commit/PR link in the Notes column. When scope shifts: add or split a session doc, update the dependency graph, and append to the decisions log rather than silently rewriting history. The plan is a living document — its value is that it always reflects reality.

## Status legend (use consistently)

`☐` not started · `◐` in progress · `☑` done. Tick when a session's Acceptance checks pass.

## Adapting to scale

Match the ceremony to the project. A 3-session feature doesn't need a risks register or a data-model doc — an overview with a status table plus three session docs is plenty. A multi-stage greenfield build wants the full set. Start with the overview + session docs; add architecture / data-model / roadmap / risks only when they're carrying weight. When in doubt, fewer docs that stay current beat a thorough set that goes stale.
