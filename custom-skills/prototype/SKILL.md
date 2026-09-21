---
name: prototype
description: Build a throwaway prototype to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
---

# Prototype

A prototype is throwaway code that answers one question. The question decides the shape.

## Where this fits

`design-a-feature` produces the divergent designs on paper. This skill is the runnable half: the UI branch builds the designs on one route, so that the user compares them by clicking, not by reading. The logic branch tests a state model before `design-an-interface` fixes its shape. When the prototype settles the question, `decision-record` writes the answer down.

## Pick a branch

Identify which question you answer. Use the user's prompt, the surrounding code, or ask if the user is present.

- "Does this logic or state model feel right?" → [LOGIC.md](LOGIC.md). Build one shareable HTML file with free-play buttons and tabbed guided walkthroughs. It pushes the state machine through the cases that are hard to reason about on paper. A non-developer can drive it. In Claude Code, the Artifact tool can publish this file as a private page.
- "What should this look like?" → [UI.md](UI.md). Generate several structurally different UI variations on one route, switchable through a URL search parameter and a floating bottom bar.

The two branches produce very different artifacts. If the question is ambiguous and the user is away, take the branch that matches the surrounding code (a backend module → logic, a page or component → UI) and state the assumption at the top of the prototype.

## Rules for both branches

1. Throwaway from day one, and marked as such. Put the prototype next to the module or page it prototypes, so that the context is obvious. Name it so that a casual reader sees that it is a prototype. For a UI route, follow the routing convention the project already uses.
2. Trivial to run. A UI prototype starts with one command in the project's task runner. A logic demo is one HTML file that the user double-clicks.
3. No persistence by default. State lives in memory. If the question is about a database, use a scratch database or a local file with a clear "PROTOTYPE, wipe me" name.
4. Skip the polish. No tests. No error handling beyond what makes the prototype runnable. No abstractions.
5. Surface the state. After every action (logic) or on every variant switch (UI), print or render the full relevant state.
6. Capture it when done. Fold the validated decision into the real code. Then propose what happens to the prototype itself: keep it on a `prototype/<name>` branch as a primary source with a pointer from the plan or issue, or leave it in the working tree. The user decides, and the user commits. Do not create the branch, commit, or delete the losing variants without an explicit yes. When the answer is load-bearing, record it with `decision-record`.

---

<sub>Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) `prototype` (MIT); `LOGIC.md` and `UI.md` are upstream with their capture steps adjusted. Changed: rule 6 proposes the branch and the cleanup instead of doing them, and the answer goes to `decision-record`. See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
