---
name: decision-record
description: 'Capture an architectural or design decision as a terse ADR under docs/adr/: the choice that commits us, the trade-off accepted, what breaks if we are wrong, and the options rejected. Use at a design fork once a call is made, or to write down a decision already taken so it survives a /clear. Closes the one gap in the skill flow: every phase persists its state except Design, where a decision otherwise lives only in the chat. Not for planning the build (multi-session-plan) or surveying standing debt (census).'
---

# Decision-record

Write down the decision, not the discussion. At a design fork you weighed options, chose one, and accepted a cost. Right now that reasoning lives only in the conversation, where it evaporates on the next `/clear`. This skill fixes the choice as a small **ADR** (Architecture Decision Record) under `docs/adr/`, so a cold reader (including future-you next session) knows *what* was decided. More importantly, it says *why*, and what can prove it wrong.

## Where this fits

This is the missing write in the [skill flow](../../docs/notes/skill-flow.md): every phase persists its state except **Design**. `multi-session-plan` writes the plan, `run-state` writes its ledger, `census` writes findings, `ship-session` writes the as-built. But the decision that *shaped* all of them had no home. decision-record is that home.

It composes with the design phase instead of duplicating it:

- **`design-a-feature` / `design-an-interface`** generate the divergent options (the forks). decision-record records *which won and why*, and keeps the losers as rejected alternatives, so you do not re-propose them next session.
- **`grill-me`** pressure-tests the choice before you commit it. Run it *first* when the decision is load-bearing. Then record the survivor.
- **`census`** reads `docs/adr/` and treats a tradeoff settled there as **by-design, not a finding**. As a result, a recorded ADR actively stops the next census from re-auditing a closed question. This is the payoff of writing to `docs/adr/` specifically: it closes the loop.
- **`multi-session-plan`** carries the decision out. Link the plan from the ADR's Consequences.

It is **not** a planning tool (that is `multi-session-plan`) and **not** a review ledger (that is `census`). One ADR = one decision.

## When to write one — and when not

Write an ADR when a choice is **hard to reverse, load-bearing for later work, or non-obvious**. These include a data-model shape, a boundary, a dependency you are committing to, a pattern the codebase will now follow. The test: *will someone six months from now ask "why on earth is it done this way?"* If yes, record it.

**Do not** record a reversible one-liner, a choice with no trade-off (if nothing was given up, there is nothing to explain), or a decision the code already makes self-evident. A padded `docs/adr/` is as useless as an empty one. "Not worth an ADR" is a valid call.

## How to write it

1. **Number monotonically.** Scan `docs/adr/` for the highest `NNNN` and take the next. Create `docs/adr/` if absent. Filename: `docs/adr/NNNN-<kebab-slug>.md` (for example, `0007-postgres-over-dynamo.md`).
2. **Fill [assets/adr-template.md](assets/adr-template.md).** Six short sections: Context, Options, Decision, Trade-off accepted, What breaks if we are wrong, Consequences. The two that carry the weight and that people skip:
   - **Options**. Record the forks *honestly*. A straw-man alternative you never seriously considered is a lie to your future self. List the ones that were genuinely in play, one real trade-off line each.
   - **What breaks if we are wrong**. This is the falsifier. Name the concrete signal that proves this decision wrong and the blast radius when it does. An ADR without this is a press release.
3. **Keep it under a page and terse.** House style: plain words, no hedging, say why not what. The ADR explains a decision. It does not re-derive the whole design.
4. **Status lifecycle.** New records are `Accepted` (or `Proposed` if the call is not final). When a later decision overturns an earlier one, do not edit the old ADR's content. Flip its status to `Superseded by [ADR-XXXX]` and write a new record. The trail of superseded decisions *is* the value. If you delete it, you lose the why.

## Boundaries

- **Record, do not decide.** If you did not make the decision yet, this is the wrong tool. Go back to `grill-me` or `design-a-*`. An ADR fixes a call you already made, not one you are dodging.
- **Do not commit unless asked.** Write the file, leave it uncommitted. Committing is the user's explicit call in-session — same rule the rest of the kit follows.
- **Never edit an accepted ADR's substance.** Supersede it with a new one. History is the point.

## The core, if you remember nothing else

**One decision, one page, under `docs/adr/`. Record the real options, the trade-off you accepted, and the signal that proves you wrong. Then supersede, never rewrite. It is the Design phase finally writing to the doc backbone, so a decision survives the `/clear` and census reads it as by-design.**

---

<sub>The decision-layer framing — *the choice that commits us · the trade-off · what breaks if we're wrong · rejected alternatives* — is harvested from [show-me-blueprint](https://github.com/tmoody1973/show-me-blueprint) (its one idea that didn't overlap the existing kit); the ADR form itself is the Nygard convention. See [the blueprint evaluation](../../docs/notes/show-me-blueprint-eval.md) for why only this layer was taken.</sub>
