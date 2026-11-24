---
name: lesson-record
description: 'Keep what a solved problem taught in its cheapest durable form: a check, a coding standard, or one lesson file under docs/lessons/. Use after a fix or a session when a later engineer who works from the current tree can make the same mistake or do the same investigation again.'
---

# Lesson-record

Keep the lesson, not the story. A session that solved a hard problem knows what the code does not show: the approach that failed, the symptom that misled, the real cause. This skill puts it where the next session in the same area reads it. The decision behind the store is [ADR-0001](../../docs/adr/0001-lesson-store.md).

## Where this fits

- **Callers.** `diagnosing-bugs` Phase 6 runs it after the fix and the cleanup. `ship-session` step 2 runs it at the end of a session. From `ship-session`, report a check. Do not write it.
- **Readers.** `craft`, `diagnosing-bugs` and `multi-session-plan` read the lessons whose `applies_when` matches the area.
- **Not this skill.** Friction in the agent environment goes to `papercuts`. What the user taught goes to `revise-claude-md`. A design choice goes to `decision-record`.

## The bar

Search `docs/lessons/` first. Grep the titles, the `applies_when` lines and the tags for the area and the symptom. If a lesson covers this problem, update it instead of adding a duplicate. If a lesson became wrong, update it, even when the current problem does not pass the bar.

Then apply the counterfactual test. Without a record, is a later engineer who works from the current tree likely to make the mistake again or to do a substantial investigation again? If no, write nothing. Effort, diff size and a finished task do not pass the test. Neither does knowledge that the code, a test, a comment or a doc already holds.

"Not worth a lesson" is a valid result. One run records one lesson. If a session taught two, run the skill twice.

## Choose the form

Take the first form that holds:

1. **A check.** A test or a lint rule that the repo already runs can detect the defect, and its failure tells the reader what to fix. Prove the check before you add it:
   1. Copy the working tree, with your uncommitted changes, to a temporary directory outside the repo. Do not put the defect in the working tree.
   2. Add the check to the copy, and run it the way the repo runs it. It must pass on the current code.
   3. Put the defect's shape in the copy. The check must fail.
   4. If the behavior rests on more than one guard, break each guard alone. The check must fail each time.

   Add the check to the working tree only after you saw every result. If the check does not pass and fail as required, report it as the recommended form and take the next form. If the check needs a change to product code (a type, a log field, a metric) or a new tool or dependency, report it instead of writing it.
2. **A standard.** An author must prevent the defect when they write the code, a reviewer can see it in a diff, and no check can hold it. Add one condition to the coding-standards doc that governs the affected code, in that doc's style. If the repo has no such doc, do not create one. Take the next form.
3. **A lesson.** The lesson holds reasoning that code, tests and standards cannot hold: the failed approaches, a measured fact, the cause behind a shape that looks wrong.

After you write a check or a standard, apply the bar again to the updated tree. Write a lesson only for what is still lost, and cite the check or the standard in it. If you reported a check instead of writing it, the lesson file holds the full lesson and names that check under Prevention.

## Write the lesson

1. Write `docs/lessons/<slug>.md` in the product repo. If `docs/lessons/` does not exist, create it. The slug names the problem in kebab case, with no date.
2. Write the frontmatter:
   - `title`: the problem in one line.
   - `applies_when`: the situation in which a reader needs the lesson, not a topic. "You change how a session token expires" is a situation. "Auth" is a topic.
   - `tags`: a few area words that a grep will find.
3. Write the body in six short sections: Problem, Symptoms, What didn't work, Solution, Why, Prevention. Write "What didn't work" from the session, not from the final diff, because no later reader can recover it.
4. Ground each claim about code behavior in the current tree. Cite the file and the symbol that defines it (a function, a class, a configuration key), not a line number, which goes stale. Mark a claim that you cannot prove as the conclusion of this session.

## Boundaries

- **Solved problems only.** A fix without proof that it works has no lesson yet.
- **No product code.** A guard, a log field or a metric stays a proposal in the report.
- **Do not commit unless asked.** Write the files and leave them uncommitted. The caller or the user commits them with the fix.

The skill is done when you report one of these results:

- The check, with the commands that showed it pass and fail.
- The new line of the standard.
- The lesson path.
- "Not worth a lesson", with the reason.

---

<sub>The bar, the form ladder and the body sections are adapted from `ce-compound` in [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) (MIT) at `fcb5e3ad`. Dropped: refresh, packs, transcript mining, subagent research and edits to instruction files. See [the evaluation](../../docs/notes/compound-engineering-eval.md).</sub>
