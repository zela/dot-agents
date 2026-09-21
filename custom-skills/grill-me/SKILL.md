---
name: grill-me
description: Interview the user relentlessly about a plan, decision, or design until every branch of the design tree is resolved. Use when the user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview the user relentlessly until you reach a shared understanding. Map the plan as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are settled: the questions you can ask now without guessing at answers you have not heard. Ask the whole frontier in one round. Number each question and give your recommended answer. Then wait for the user's answers.

Format a round like this:

```
**Q1 · <question title>**
<question body; it can hold several paragraphs or a list of choices>
→ Recommended: <your answer, with the reason in one line>

---

**Q2 · <question title>**
...
```

Each round of answers reshapes the tree. Settled decisions push the frontier outward and unblock the questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a later round. Keep a round small. If the frontier holds more than five or six questions, the plan is too big for one interview. Say so, and ask the user which part to grill first.

Facts are your job, never the user's. When a frontier question needs a fact from the environment (the codebase, the filesystem, a tool), find it yourself. Use a subagent when the search is wide. Do not block on it. A running search is an unsettled prerequisite, so only the questions downstream of it wait. Ask the rest of the frontier now. Decisions are the user's. Put each one to them and wait.

If a term is fuzzy or overloaded, or the repo has a `CONTEXT.md`, run `domain-modeling` alongside, so that the words get fixed as the decisions do.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on the plan until the user confirms that you reached a shared understanding. If the outcome is a load-bearing decision, offer `decision-record`.

<sub>The frontier-and-rounds model is from the `grilling` primitive in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT), the successor of the one-question-at-a-time `grill-me` this skill started as. See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
