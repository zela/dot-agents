---
name: domain-modeling
description: Build and sharpen a project's domain glossary in CONTEXT.md. Use when discussing codebase terminology, when a term is fuzzy or overloaded, or when writing or editing a CONTEXT.md.
---

# Domain Modeling

Build the project's shared language as you design. Challenge terms, invent edge-case scenarios, and write the glossary down the moment a term crystallises. This is the active discipline. Reading `CONTEXT.md` for vocabulary is a one-line habit that any skill can do. Use this skill when you change the model, not when you consume it.

## Why a glossary

At the start of a project, the developer and the domain expert speak different languages. An agent has the same problem. Dropped into a repo, it decodes the jargon as it goes and uses twenty words where one will do. A glossary fixes the words once. The payoff compounds: variables, functions, and files get consistent names, the codebase becomes easier to navigate, and prompts get shorter.

## File structure

Most repos have one context:

```
/
├── CONTEXT.md
└── src/
```

If a `CONTEXT-MAP.md` exists at the root, the repo has several contexts and the map points to each one. See [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md) for both layouts and the entry format.

Create files lazily, only when you have something to write. If no `CONTEXT.md` exists, create it when the first term is resolved.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with `CONTEXT.md`, say so at once. "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses a vague or overloaded term, propose a precise canonical term. "You say 'account'. Do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships come up, stress-test them with specific scenarios. Invent cases that probe the edges and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, make sure that the code agrees. If you find a contradiction, surface it. "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Do not batch. Use the format in [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).

`CONTEXT.md` holds no implementation details. It is not a spec, a scratch pad, or a place for decisions. It is a glossary and nothing else.

### Decisions go to decision-record

When a hard-to-reverse choice with a real trade-off surfaces, do not record it here. Use `decision-record`, which writes an ADR under `docs/adr/`. Its test for when to write one is the same three-part test: hard to reverse, surprising without context, the result of a real trade-off.

## Composition

- With `grill-me`: run both in one session when the plan touches domain terms. The interview sharpens the plan, and this skill keeps the words honest.
- With `design-an-interface`, `multi-session-plan`, and `census`: they read `CONTEXT.md` for names and do not change it.

---

<sub>Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) `domain-modeling` (MIT), glossary half only. Changed: the ADR half is removed and points at `decision-record`, which already covers it with a stronger template. See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
