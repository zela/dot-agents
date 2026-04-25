---
name: design-an-interface
description: Generate multiple radically different interface designs for a module. Use when user wants to design an API, explore interface options, compare module shapes, or mentions "design it twice".
---

# Design an Interface

Based on "Design It Twice" from *A Philosophy of Software Design* by John Ousterhout: your first idea is unlikely to be the best. Generate multiple radically different interface designs for the same module, then compare. The **module's responsibilities** are the stable anchor — what it must do stays fixed across all variants; only the shape of the interface changes.

## Workflow

### 1. Gather Requirements

Before designing, understand:

- [ ] What problem does this module solve?
- [ ] Who are the callers? (other modules, external users, tests)
- [ ] What are the key operations?
- [ ] Any constraints? (performance, compatibility, existing patterns)
- [ ] What should be hidden inside vs exposed?

Ask: "What does this module need to do? Who will use it?"

### 2. Generate Designs

Produce 3+ radically different designs. Enforce divergence by assigning a different constraint to each:

- **Design 1 — Minimal surface**: Minimize method count — aim for 1-3 methods max. What's the smallest interface that does the job?
- **Design 2 — Maximum flexibility**: Support as many use cases as possible. Expose more, assume less.
- **Design 3 — Optimized for the common case**: Make the most frequent usage path as simple as possible, even at the cost of edge cases.
- **Design 4 — Pattern borrowed from [paradigm/library]**: Take inspiration from a well-known interface shape (e.g. streams, builders, middlewares, repositories). Assign based on context.

For each design, produce:

1. **Interface signature** — types, methods, params
2. **Usage example** — how callers actually use it in practice
3. **What it hides** — complexity kept internal
4. **Trade-offs** — what this design is good at and where it breaks down

### 3. Present Designs

Present designs one at a time so the caller can form an impression before seeing the next. Don't front-load comparison.

### 4. Compare Designs

After presenting all designs, compare on these criteria (discuss in prose, not tables):

- **Interface simplicity**: Fewer methods, simpler params = easier to learn and use correctly
- **General-purpose**: Can it handle future use cases without changes? Beware over-generalization
- **Implementation efficiency**: Does the interface shape allow efficient internals, or does it force awkward implementation?
- **Depth**: Small interface hiding significant complexity = deep module (good). Large interface with thin implementation = shallow module (avoid)
- **Ease of correct use vs ease of misuse**: How hard is it to call this wrong?

Highlight where designs diverge most — those are the real design decisions.

### 5. Synthesize

The best design often combines elements from multiple options. Ask:

- "Which design best fits your primary use case?"
- "Any elements from other designs worth incorporating?"

## Theoretical Foundation

**John Ousterhout — *A Philosophy of Software Design***
The primary reference. Key principles directly used in comparison:
- *Deep modules*: the best modules have small interfaces and large implementations
- *General-purpose interfaces*: slightly general-purpose tends to age better than slightly special-purpose
- *Information hiding*: complexity that callers don't need to know should stay inside
- *Design it twice*: the first design is rarely the best; contrast forces better decisions

## Anti-Patterns

- Don't let designs converge — if two designs feel similar, push one further
- Don't skip the usage example — the value is in imagining the caller using the interface, not just the signature
- Don't implement — this is purely about interface shape
- Don't evaluate based on implementation effort
