# ADR-0001: Keep product lessons in docs/lessons/, written by lesson-record and read by three skills

- Status: Accepted
- Date: 2026-11-24
- Deciders: the user, Claude (grill of the compound-engineering harvest)

## Context

When a session solves a problem in a product repo, the lesson has no place where a later session reads it. `ship-session` writes gotchas into that plan's own session doc. `revise-claude-md` writes to `CLAUDE.md`, which every session loads in full. `craft` and `diagnosing-bugs` read `CONTEXT.md` and `docs/adr/`, and nothing else from past work. `papercuts` covers friction in the agent environment and excludes product defects by rule. The [compound-engineering evaluation](../notes/compound-engineering-eval.md) found that `ce-compound` fills this gap upstream with one lesson per file and a planner that reads them. The papercuts log shows the failure that comes from writing without reading: 85 entries, none triaged, and one friction logged three times.

## Options

1. **A `lesson-record` skill, with reader lines in `craft`, `diagnosing-bugs` and `multi-session-plan`.** One owner states the bar and the format. The cost is one more skill and three more reads.
2. **An inline writer step in `diagnosing-bugs` and `ship-session`, with no new skill.** No new skill, but the bar and the format are stated twice and drift.
3. **Write lessons to the product repo's `CLAUDE.md` with `revise-claude-md`.** No new code, but every session pays for every lesson, relevant or not.
4. **Do nothing.** No cost, and agents keep finding the same facts again.

## Decision

We will add a `lesson-record` skill. It writes one lesson per file to `docs/lessons/<slug>.md` in the product repo, with `title`, `applies_when` (a situation, not a topic) and `tags` in the frontmatter. It writes a lesson only when a future engineer who works from the current tree would likely repeat the mistake or the investigation. It prefers a test or a lint rule, and writes a doc only for what code cannot hold. `diagnosing-bugs` Phase 6 and `ship-session` step 2 call it. `craft`, `diagnosing-bugs` and `multi-session-plan` read the lessons whose `applies_when` matches the area. When a lesson changes what the agent does, the agent cites the lesson path in the plan doc or the commit message.

## Trade-off accepted

One more skill, and one more read before each task in an area that has lessons. The writer's bar rejects most candidates, so the store grows slowly. A lesson that a check could hold becomes a check, not a doc.

## What breaks if we're wrong

The signal: by 2027-02-24, `git log --grep docs/lessons/` and a grep of the plan docs find no citation in any product repo. That shows the store is written but not read. Then remove `lesson-record` and the three reader lines, and supersede this ADR. The blast radius is small: the readers skip a missing directory, and the lesson files stay as plain docs.

## Consequences

- Enables: a plan or a fix that starts from what an earlier session learned in the same area.
- Constrains: `papercuts` stays for environment friction, and `revise-claude-md` stays for what the user taught. A lesson about the product code goes to `docs/lessons/`.
- Work: [the harvest plan](../compound-engineering-harvest-plan.md), change 1.
