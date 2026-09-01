# Evaluating show-me-blueprint

[tmoody1973/show-me-blueprint](https://github.com/tmoody1973/show-me-blueprint) — a single-file Claude skill (~1,800 words, no deps) that extends HumanLayer's upstream `show-me`. Its thesis: fight "vibe coding" by forcing comprehension before code — a diagram before every phase, a plain-English gloss on every diagram, 2–3 design options at every fork, and a decision saved to `docs/decisions/YYYY-MM-DD-<topic>.md`. It also adds "leash markers" (`🔒` = mutates shared state, `[gate]` = needs human approval).

## Verdict: good ideas, don't deploy verbatim — harvest one piece

The *philosophy* is squarely aligned with how this kit already thinks — understand the goal not the instruction, choose from real alternatives, persist decisions. But dropping it in as-is is wrong for three reasons:

1. **It's an always-on gate.** It auto-triggers during design discussions and *blocks progress* until a drawing is approved. That's a heavy, opinionated interruption to bolt onto a setup whose `CLAUDE.md` already encodes deliberate planning discipline. Gates you didn't ask for become friction, not accountability.
2. **Tone clash.** "Say *bro* to get a simpler restatement" is charming and completely against the terse, no-filler house style every other skill here holds.
3. **Overlap with what's already here.** Its comprehension-forcing job is `grill-me`'s (verbal stress-test until every branch resolves); its diagrams are `archify` / `beautiful-mermaid`'s; its "design it twice" options-parti is literally `design-a-feature` / `design-an-interface`. Adopting the whole skill re-implements three skills to get one new thing.

## The one new thing worth taking

**Decision capture to `docs/decisions/`.** This is the exact gap the [flow map](skill-flow.md) surfaces: every phase persists its state except Design, where the decision currently evaporates into the chat. `census` already *reads* `docs/adr/` assuming ADRs exist — nothing writes them. A small skill that, at a design fork, records `{ the choice that commits us · the trade-off · what breaks if we're wrong · rejected alternatives }` to a dated ADR would close the loop, and it composes with the kit instead of fighting it: `design-a-*` generates the options, `grill-me` pressure-tests them, and the new skill *writes down which one won and why.*

The `🔒` / `[gate]` leash markers are a nice secondary idea but redundant here — approval boundaries are already the user's call per `CLAUDE.md`, not something a marker needs to enforce.

## Outcome

- **Did not** add `show-me-blueprint` to `custom-skills/` (auto-gate + tone + triple overlap).
- **Harvested** its one non-overlapping idea — the decision-capture layer — into a new `decision-record` skill that writes ADRs to `docs/adr/`, crediting show-me-blueprint the way `run-state` credits SKILL.state and `census` credits shadcn/improve. That's the piece that completes the [flow](skill-flow.md).
- The `🔒` / `[gate]` leash markers were left behind — redundant here, since approval boundaries are already the user's call per `CLAUDE.md`.

The upstream skill itself is not vendored; if a future need arises for its always-on visual gating, it can be parked in `passive-skills/` then.
