---
name: design-a-feature
description: Generate radically different UI/UX designs for a feature by holding the user task stable and varying interaction patterns. Use when the user wants to design a frontend feature, explore UX options, compare interaction patterns, or mentions "design it twice" in a frontend context.
---

# Design a Feature

*A Philosophy of Software Design* gives the principle: your first idea is rarely the best. This skill applies it to frontend design, through Norman, Nielsen, Krug, and Tidwell. Generate several radically different interaction designs for one user task, then compare them.

## Core Framing

The **user task** is the stable anchor. The variants are different ways to accomplish that task. Each varies the interaction patterns, information architectures, progressive disclosure strategies, and mental models.

## Workflow

### 1. Gather Requirements

Before designing, understand:

- [ ] What is the user trying to accomplish? (the task, not the feature)
- [ ] Who is the user? (experience level, context, device)
- [ ] What does the user already know when they arrive at this feature?
- [ ] What are the constraints? (existing design system, platform, performance)
- [ ] What does success look like for the user?

Ask: "What is the user trying to do, and what do they know when they start?"

### 2. Generate Designs

Produce 3+ radically different designs. Enforce divergence by assigning a different constraint to each:

- **Design 1 — Minimal steps**: Optimize for fewest clicks/views to task completion. What is the most direct path?
- **Design 2 — Maximum clarity**: Optimize for zero ambiguity. The user never wonders what to do next, even at the cost of extra steps.
- **Design 3 — Progressive disclosure**: Start with the simplest version of the task. Reveal complexity only as needed.
- **Design 4 — Pattern borrowed from [domain]**: Take inspiration from a well-known interaction pattern (for example, wizard, dashboard, inline edit, or conversational UI). Assign based on context.

For each design, produce:

1. **Interaction sketch** — describe the screens/states and how the user moves through them
2. **Usage walkthrough** — narrate the user completing the task step by step
3. **What it hides** — what complexity is kept out of sight, and how
4. **Trade-offs** — what this design is good at and where it breaks down

### 3. Present Designs

Present designs one at a time so the user can form an impression before seeing the next. Do not front-load comparison.

### 4. Compare Designs

After presenting all designs, compare on these criteria (discuss in prose, not tables):

- **Simplicity**: How much does the user need to understand before they can act?
- **Ease of correct use**: How hard is it to make a mistake? How recoverable are errors?
- **Predictability**: Does the interface behave the way the user expects based on prior experience?
- **Clarity**: Is the current state and available actions unambiguous at every step?
- **Task completion cost**: How many clicks, views, or decisions does it take to complete the task?
- **Depth**: Does the interface hide complexity well, or does it expose implementation details to the user?

Highlight where designs diverge most. Those are the real design decisions.

### 5. Synthesize

The best design often combines elements from multiple options. Ask:

- "Which design best fits how your users think about this task?"
- "Any elements from other designs worth incorporating?"

## Theoretical Foundation

**Donald Norman — *The Design of Everyday Things***
Affordances, feedback, mapping, and mental models. Use to evaluate whether the interface communicates what actions are possible and what happened as a result.

**Jakob Nielsen — 10 Usability Heuristics**
Canonical evaluation rubric. Particularly relevant: visibility of system status, match between system and real world, error prevention, recognition over recall.

**Steve Krug — *Don't Make Me Think***
Practical simplicity. If the user has to pause and figure something out, the design failed. Use as the gut-check criterion.

**Jenifer Tidwell — *Designing Interfaces***
Pattern catalogue. Use when generating Design 4 (pattern-borrowed) or when comparing against known interaction shapes.

## Anti-Patterns

- Do not let designs converge. If two designs feel similar, push one further.
- Do not skip the walkthrough. The value is in imagining the user moving through the design, not in the static layout alone.
- Do not evaluate based on implementation effort
- Do not design the component. Design the task flow instead.
