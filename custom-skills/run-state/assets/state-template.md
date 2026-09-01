# Run state — <task name>

<!-- The single source of truth for this run. Durable progress lives HERE, not in the conversation.
     Any step (or the whole session) can be /clear'd and resumed from this file alone. -->

Spec: [<procedure doc>](../<path-to-spec>.md) · Started: <YYYY-MM-DD> · Updated: <YYYY-MM-DD> @ <commit-or-note>

## Invariants
<!-- Facts that must stay true across every step. Re-assert, never re-derive. -->
- <e.g. every migrated call site keeps the same return type>
- <e.g. no step commits; the user commits>

## Cursor
- Phase: <current phase / batch>
- Next unit: <the very next thing to do — precise enough to act on cold>

## Ledger
<!-- One row per unit of work. Status: · pending  → in progress  ✓ done  ⊘ skipped (reason)  ⚠ blocked -->
| # | Unit | Status | Note |
|---|------|--------|------|
| 1 | <unit> | ✓ | <what changed / evidence> |
| 2 | <unit> | → | |
| 3 | <unit> | · | |

## Decisions
<!-- Choices made mid-run that later steps depend on. Record the choice + why, once. -->
- <decision> — <why> (<date>)

## Blockers
<!-- Anything ⚠ in the ledger, with what would unblock it. Empty when clean. -->
- <unit #> — <what's blocking> → <what unblocks it>

## Done when
<!-- The acceptance check that ends the run. Copy verbatim from the spec. -->
- <e.g. all rows ✓ or ⊘, `pnpm test` green, no `oldApi(` left in src/>
