# <Project> — Implementation Overview

> **Read this first.** It is the index for the whole build. Each session has its own doc with concrete tasks, files, reuse pointers, and acceptance criteria.

## What we're building

<2–4 sentences: the goal, the core pieces, who it's for. Link the source spec(s)/design if any.>

## Goals

- <Concrete, testable goal for the stage in scope.>
- <Keep the data/contract seam stable so mock and real are interchangeable — if applicable.>

## Decisions locked this session

| Topic | Decision | Why |
|-------|----------|-----|
| <Code location> | <e.g. separate repo / monorepo package> | <rationale> |
| <Data availability> | <real now / mock-first behind adapter> | <rationale> |
| <Scope> | <Stage 1 deep, rest roadmap> | <rationale> |
| <Build order> | <frontend-first / data-first> | <rationale> |

## Session index

<One line on the overall order, e.g. "Frontend-first: 0–N produce a clickable site on fixtures; then the data track; the last session joins them.">

**Status legend:** ☐ not started · ◐ in progress · ☑ done. Tick when a session's Acceptance checks pass; link the commit/PR in Notes.

| # | Status | Doc | Goal | Milestone | Notes |
|---|:---:|-----|------|-----------|-------|
| 0 | ☐ | [session-00-<slug>](./session-00-<slug>.md) | <short goal> | <observable milestone> | |
| 1 | ☐ | [session-01-<slug>](./session-01-<slug>.md) | <short goal> | <observable milestone> | |
| … | ☐ | … | … | … | |

Plus [<stage-n>-roadmap](./<stage-n>-roadmap.md) for later.

## Dependencies & parallelization

<The plan is rarely a straight chain. Draw the real graph; mark independent tracks and the single join.>

```
0 Scaffold ─▶ 1 Contract ─┬─▶ 2 … ─▶ 3 …  (track A)  ─┐
                          └─▶ 4 … ─▶ 5 …  (track B)  ─┴─▶ N Join + ship
```

- **Hard prerequisite for everything:** <usually the shared-contract session>.
- **Independent tracks:** <which sessions can run in parallel>.
- **The only true join:** <the final integration session> — must come last.

## Risks & watch-items

| Risk | Impact | Mitigation / where handled |
|------|--------|----------------------------|
| <e.g. data gaps / missing records> | <what breaks> | <policy + which session owns it> |
| <whole-dataset requirement> | <partial-run dev mode gives wrong results> | <which sessions assert the full set> |
| <volume / perf> | <build memory / bundle size> | <partitioning strategy> |

## Decisions log (ADR-lite)

| # | Decision | Rationale | Revisit if… |
|---|----------|-----------|-------------|
| D1 | <decision> | <why> | <trigger to reconsider> |
| D2 | <decision> | <why> | <trigger> |

## How to use these docs

- Start each session by reading its doc top-to-bottom, plus [architecture](./architecture.md) (and [data-model](./data-model.md) if present).
- Each session lists **Reuse references** — files to read and adapt, not rebuild.
- Finish a session only when its **Acceptance / verification** checks pass, then tick its box above.

## Reference materials

- <prototype/spec/design folders in this repo and what they're for>
- <sibling repo / monorepo paths used as read-only reference>
