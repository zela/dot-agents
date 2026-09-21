---
name: design-an-interface
description: Generate multiple radically different interface designs for a module. Use when the user wants to design an API, explore interface options, compare module shapes, or mentions "design it twice".
---

# Design an Interface

Based on "Design It Twice" from *A Philosophy of Software Design* by John Ousterhout: your first idea is unlikely to be the best. Generate multiple radically different interface designs for the same module, then compare. The **module's responsibilities** are the stable anchor. What it must do stays fixed across all variants. Only the shape of the interface changes.

## Workflow

### 1. Gather Requirements

Before designing, understand:

- [ ] What problem does this module solve?
- [ ] Who are the callers? (other modules, external users, tests)
- [ ] What are the key operations?
- [ ] Any constraints? (performance, compatibility, existing patterns)
- [ ] What stays hidden inside, and what is exposed?
- [ ] Which dependencies does it have, and which category is each? (See "Dependency categories" below. The category decides how the module is tested across its seam.)

Ask: "What does this module need to do? Who will use it?"

### 2. Generate Designs

Produce 3+ radically different designs. Run each design in its own subagent, in parallel. A subagent that cannot see the other designs cannot converge on them. Give every subagent the same brief (responsibilities, callers, constraints, dependency categories, and the project's `CONTEXT.md` terms) plus one constraint of its own. Fall back to inline generation only when subagents are unavailable. Enforce divergence by assigning a different constraint to each:

- **Design 1 — Minimal surface**: Minimize method count. Aim for 1-3 methods at most. What is the smallest interface that does the job?
- **Design 2 — Maximum flexibility**: Support as many use cases as possible. Expose more, assume less.
- **Design 3 — Optimized for the common case**: Make the most frequent usage path as simple as possible, even at the cost of edge cases.
- **Design 4 — Pattern borrowed from [paradigm/library]**: Take inspiration from a well-known interface shape (for example, streams, builders, middlewares, or repositories). Assign based on context.

For each design, produce:

1. **Interface signature** — types, methods, params
2. **Usage example** — how callers actually use it in practice
3. **What it hides** — complexity kept internal
4. **Trade-offs** — what this design is good at and where it breaks down
5. **Dependency strategy** — which dependencies sit behind the seam, and which adapters each one needs (see "Dependency categories" below)

### 3. Present Designs

Present designs one at a time so the caller can form an impression before seeing the next. Do not front-load comparison.

### 4. Compare Designs

After presenting all designs, compare on these criteria (discuss in prose, not tables):

- **Interface simplicity**: Fewer methods, simpler params = easier to learn and use correctly
- **General-purpose**: Can it handle future use cases without changes? Beware over-generalization
- **Implementation efficiency**: Does the interface shape allow efficient internals, or does it force awkward implementation?
- **Depth**: Small interface hiding significant complexity = deep module (good). Large interface with thin implementation = shallow module (avoid)
- **Ease of correct use vs ease of misuse**: How hard is it to call this wrong?
- **Locality**: Where does a change concentrate? Fix once, fixed everywhere is deep. A change that touches N callers is shallow.
- **Seam placement**: Where the interface lives is its own decision, separate from what sits behind it. Does the seam sit where something varies?

Highlight where designs diverge most. Those are the real design decisions.

### 5. Synthesize

The best design often combines elements from multiple options. Ask:

- "Which design best fits your primary use case?"
- "Any elements from other designs worth incorporating?"

## Theoretical Foundation

**John Ousterhout — *A Philosophy of Software Design***
The primary reference. Key principles directly used in comparison:
- *Deep modules*: the best modules have small interfaces and large implementations
- *General-purpose interfaces*: slightly general-purpose tends to age better than slightly special-purpose
- *Information hiding*: complexity that callers do not need to know stays inside
- *Design it twice*: the first design is rarely the best. Contrast forces better decisions

## Vocabulary and tests

Use these terms exactly. Do not substitute "component", "service", "API", or "boundary".

- **Module**: anything with an interface and an implementation. A function, a class, a package, a tier-spanning slice.
- **Interface**: everything a caller must know to use the module correctly. The type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics.
- **Depth**: leverage at the interface. How much behaviour a caller or a test can exercise per unit of interface they learn. Not a ratio of implementation lines to interface lines, which rewards padding.
- **Seam** (Feathers): the place where you can alter behaviour without editing in that place. The location of the interface. Where the seam goes is its own design decision.
- **Adapter**: a concrete thing that satisfies the interface at a seam. It describes a role, not substance.
- **Leverage**: what callers get from depth. One implementation pays back across N call sites and M tests.
- **Locality**: what maintainers get from depth. Change, bugs, knowledge, and verification concentrate in one place.

Three tests:

- **The deletion test.** Imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it earned its keep.
- **The interface is the test surface.** Callers and tests cross the same seam. If you want to test past the interface, the module is probably the wrong shape.
- **One adapter is a hypothetical seam. Two adapters are a real one.** Do not introduce a seam unless something varies across it, typically production and test.

### Dependency categories

Classify each dependency of the module. The category decides how the module is tested across its seam.

| Category | Example | Test strategy |
|---|---|---|
| In-process | Pure computation, in-memory state | Test through the interface directly. No adapter. |
| Local-substitutable | Postgres with PGLite, an in-memory filesystem | Run the stand-in inside the test suite. The seam stays internal. |
| Remote but owned | Your own service across a network | Define a port at the seam. An HTTP or queue adapter in production, an in-memory adapter in tests. |
| True external | Stripe, Twilio | The module takes the dependency as an injected port. Tests provide a mock adapter. |

When a design deepens a cluster of shallow modules, replace the old unit tests with tests at the new interface. Do not layer new tests over old ones.

## Anti-Patterns

- Do not let designs converge. If two designs feel similar, push one further.
- Do not skip the usage example. The value is in imagining the caller using the interface, not in the signature alone.
- Do not implement. This step is purely about interface shape.
- Do not evaluate based on implementation effort

---

<sub>The vocabulary, the three tests, the dependency categories, and the subagent-per-variant pattern are harvested from `codebase-design` in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
