# Session <NN> — <Title>

**Goal:** <one or two sentences: what this session delivers and why it matters in the arc.>

**Prerequisites:** <which earlier sessions must be done, and what they provide. "none" for the first.>

> **Sizing (optional):** <if this is a heavy session, note how to split it into NNa / NNb so it fits one working block. Acceptance applies to the combined result.>

## Tasks

1. <Concrete, ordered step. Name the actual approach, not just the goal.>
2. <Step. Call out anything correctness-critical — invariants, "requires the full dataset", edge cases — inline where it bites.>
3. <Step.>

## Files to create / modify

- `<path>` — <role>
- `<path>` — <role>

## Reuse references (read-only)

- `<path>` — <what to read and adapt; prototype, spec section, or sibling-repo pattern>
- <spec/PRD section that is authoritative for this session>

## Acceptance / verification

- <Observable check — a command that passes, output that exists, a page that renders.>
- <Test expectation: which test file, what it asserts.>
- <Spot-check against a known-good case.>
- <Real output: if this session consumes another program's output, the check that runs on that program's real output, or the later session that runs it.>
- <Replacement: if this session replaces code, the old and the new code on the same inputs, and the intended differences. Any other difference fails.>

## Out of scope

- <Explicitly deferred work (which later session or roadmap item owns it). An empty section is a smell — pin the boundary.>

**Considered and not built:**

- <Concern: why it is not built, and what evidence can change the call. One line each.>
