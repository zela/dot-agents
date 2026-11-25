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

Facts are your job, never the user's. When a frontier question needs a fact from the environment (the codebase, the filesystem, a tool), find it yourself. Use a subagent when the search is wide. Do not block on it. A running search is an unsettled prerequisite, so only the questions downstream of it wait. Ask the rest of the frontier now. Decisions are the user's. Put each one to them and wait. Do not ask again about a decision that the user made after they saw the trade-off. A bare directive ("build it with X") gets exactly one challenge. Never mark your own proposal as settled.

Collect domain terms as the rounds go. A term names a project-specific concept, never a general programming idea or a field name. A term counts when the session settles its meaning. This happens when the user chose between two meanings, corrected your word, or named a concept that had no name. Before the first round, read `CONTEXT-MAP.md` and the context files that it lists. If the repo has no map, read the root `CONTEXT.md` if it exists. If the user gives a term a different meaning than its entry, ask about the conflict in the next round.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Before you call it empty, combine the user's answers with your own defaults and look for effects nobody asked about. Ask one question per real combination. Do not act on the plan until the user confirms that you reached a shared understanding. In the message that asks for that confirmation, list the terms that the session settled. Use the format below. Ask whether to write them to `CONTEXT.md`. Mark each entry that changes an existing definition. Quote the old definition next to it. If the session settled no terms, leave the list out. If the outcome is a load-bearing decision, offer `decision-record`.

```
**<Term>**:
<What it is, in one or two sentences.>
_Avoid_: <the synonyms that the session rejected>
```

If the repo has a `CONTEXT-MAP.md`, ask which context each term belongs to. Write each term to the `CONTEXT.md` of its context. If the repo has neither file, create `CONTEXT.md` at the repo root. Give it a `# <Project>` heading, one line about the project, and a `## Language` section. Offer the `domain-modeling` skill only for a larger glossary job, such as one glossary built from terms spread across many docs. Only the user can invoke it.

If the plan is a doc in the repo, record the grilling date in it after the user confirms. Put a `Grilled: YYYY-MM-DD` line under the doc's title. If the line exists, replace its date. Get the date from the system with `date +%F`.

<sub>The frontier-and-rounds model is from the `grilling` primitive in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT), the successor of the one-question-at-a-time `grill-me` this skill started as. See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
