# Skill trim — Overview

> **Read this first.** It is the index for the cleanup. Each session doc lists its skills, the findings to act on, and its acceptance checks. The trim rules and the acceptance procedure below apply to every session; session docs cite them and do not restate them.

## What we're doing

Cut excess from the custom skills in `custom-skills/`: duplication, rules already in `AGENTS.md`, positioning prose, descriptions that carry the body, and branch-only reference kept in `SKILL.md`. Fix the defects the review found along the way. The source is a read-only review of 27 skills on 2026-11-25 against the `writing-for-agents` criteria; `grill-me` was trimmed first as the calibration case (commit `dec444e`). The estimated saving is 4–5k of about 47k words, an inference from the review.

## Goals

- Every skill passes the trim rules below, or its session doc records why a line stays.
- No behaviour is lost by accident: each removed behaviour is either listed as an intended cut in the session doc or restored.
- The defects in each session doc are fixed.
- Living docs (`README.md`, `docs/user-invoked-skills.md`, `docs/notes/skill-flow.md`, `CONTEXT.md`) match the new skill set.

## Trim rules

Each rule has its owner here. Session docs cite a rule by its number.

- **R1 — AGENTS.md restatement.** Cut a line that repeats a rule in `AGENTS.md`: no commit unless asked, deletion and moves need consent, smallest change, run the checks, discover commands, terse writing, no hard wraps. `AGENTS.md` is loaded on every host: Claude Code through `CLAUDE.md`, Gemini through `GEMINI.md:6`, Codex through the `~/.codex/AGENTS.md` link in `bootstrap.sh`. Keep the line only when the skill text around it would otherwise lead the agent the opposite way; then make it one positive sentence.
- **R2 — Positioning prose.** Cut "Where this fits", "Why this shape works", "The core, if you remember nothing else", and "Theoretical foundation" sections. Before you cut, check that each fact lives in `docs/notes/skill-flow.md` or `docs/user-invoked-skills.md`; move a fact that lives nowhere else. Keep one routing line when it changes what the agent does next.
- **R3 — Descriptions.**
  - Model-invoked skill: what it is, then one trigger per branch. No identity the body carries, no synonym triggers, no rationale.
  - User-invoked skill (`disable-model-invocation: true`): one line for the human. No trigger list.
- **R4 — Branch-only reference.** Material that only some runs need moves to a sibling file in the skill folder, behind a one-line pointer that names the branch. `bootstrap.sh` copies the whole folder, so sibling files deploy.
- **R5 — Duplication inside a skill.** Keep one copy, where it bites: in the step or the template that is read at that moment.
- **R6 — Negation.** State the target behaviour positively. Keep a prohibition only as a hard guardrail, paired with the positive target.
- **R7 — No-ops.** Cut a sentence that does not change behaviour versus the model default. When unsure, keep it and say so in the session notes.
- **R8 — Attribution.** The skills are ours now (D1). Change `Vendored from` to `Adapted from <source> at <version> (<license>)`. Take the version from the current `<sub>` line or the eval note it links; for `mattpocock/skills` that is v1.2.3 (`docs/notes/mattpocock-skills-eval.md:3`). If no version is recorded, ask the user. Drop re-pull and re-apply instructions. Keep each `LICENSE` file. Keep the `<sub>` line itself; it is a kit convention. Change the skill's `README.md` row from "Vendored" to "Adapted" in the same session.

Findings in the session docs are the reviewers' inferences from reading, not from running the skills. Line numbers refer to commit `dec444e`; each finding quotes a few words so it can be found after earlier edits shift lines.

## Acceptance procedure

Run this for every session before you tick it.

1. Record `wc -w` for each changed `SKILL.md` and its reference files, before and after, in the session's entry in the session index below.
2. **Replacement check.** Give an independent subagent the old version (`git show HEAD:<path>`) and the new version of each changed skill folder. It lists every behaviour the old text produced that the new text does not. Each item must be an intended cut named in the session doc; anything else is restored or added to the doc as a deliberate cut with the user's OK.
3. Run `review-staged` on the staged session diff.
4. For a session that owns an adapted skill (R8): `grep -rn "Vendored from\|vendored-from" custom-skills/<session skills>` returns nothing (a plain `vendored` grep hits the legitimate use at `census/SKILL.md:25`), `grep -ni vendored README.md` shows no row for those skills, and no `<sub>` line keeps re-pull or "body verbatim" text. Skip this step for a session with no adapted skill.
5. Each changed `SKILL.md` still has `name` equal to its folder name and a `description`.
6. The user commits; the session does not commit on its own.

## Session index

Sessions are batches by file ownership: each skill belongs to exactly one session. The exceptions are single lines that follow a rename into another session's file; both docs name each one. The order below is a recommendation by payoff, not a dependency chain.

**Status legend:** ☐ not started · ◐ in progress · ☑ done.

- ☐ [Session 01 — grammar-tutor](./session-01-grammar-tutor.md)
  - Goal: fix the skill, then move it to `passive-skills/`.
- ☐ [Session 02 — prose skills](./session-02-prose-skills.md)
  - Goal: `simple-english`, `stop-slop`, `wtf`. Take ownership of the two vendored bodies and restructure `simple-english`.
- ☐ [Session 03 — planning skills](./session-03-planning-skills.md)
  - Goal: `multi-session-plan`, `parallel-sessions`, `run-state`. Settle the two meanings of "join".
- ☐ [Session 04 — census](./session-04-census.md)
  - Goal: restructure `census`; trim `complexity-optimizer`.
- ☐ [Session 05 — review and ship](./session-05-review-ship.md)
  - Goal: `review-mr`, `review-staged`, `ship-session`, `doc-check`, `lesson-record`, `papercuts`. Resolve the counts conflict.
- ☐ [Session 06 — design skills](./session-06-design.md)
  - Goal: merge the two design skills into `design-it-twice`; trim `decision-record`, `domain-modeling`, `system-design-mentor`, `third-opinion`.
- ☐ [Session 07 — code skills](./session-07-code-skills.md)
  - Goal: `craft`, `diagnosing-bugs`, `prototype`, `diagram`, `cross-engine-check`, `resolving-merge-conflicts`.

Plus the [roadmap](./roadmap.md) for later work.

## Dependencies & parallelization

```
01 ─┐
02 ─┤
03 ─┤
04 ─┼─ any order, one at a time
05 ─┤
06 ─┤
07 ─┘
```

- No session needs another's output. Each skill has one owning session, apart from the single-line rename edits that both docs name: Session 03 edits `doc-check/SKILL.md:57` (Session 05), and Session 06 edits `prototype/SKILL.md:13`, `diagnosing-bugs/SKILL.md:118` (Session 07) and `census/references/audit-categories.md:66` (Session 04).
- Several sessions edit the same living docs: `README.md`, `docs/user-invoked-skills.md`, `docs/notes/skill-flow.md`. Run the sessions one at a time on `main`. This repo has not adopted `parallel-sessions`.
- Run 01 before 02 if you can: 02 removes the routing lines that point at `grammar-tutor`, and it reads more naturally once the skill is gone.

## Risks & watch-items

- **A cut removes behaviour that mattered.**
  - Impact: a skill silently stops doing something.
  - Mitigation: the replacement check in the acceptance procedure, every session.
- **A sentence looks like a no-op but counters a real default.**
  - Impact: behaviour drifts back to the default.
  - Mitigation: R7 keeps a line when unsure. The reviewers marked their unsure findings; leave those for last and decide each one with the user.
- **Renamed or removed skills leave dangling references.**
  - Impact: a link or routing line points at a skill that no longer deploys.
  - Mitigation: Sessions 01 and 06 grep living docs and skills for the old names. Dated records under `docs/notes/` and the harvest plans keep the old names; they are history.

## Decisions log (ADR-lite)

- **D1 — The adapted skills are ours.**
  - Decision: no re-pull from upstream. `simple-english` and `wtf` lose their "body verbatim" promise and get trimmed like the rest.
  - Rationale: the user's call (2026-11-25). Upstream changes are evaluated from time to time instead; see the roadmap.
  - Revisit if: an upstream release changes a skill so much that a re-adapt costs less than a merge.
- **D2 — Merge `design-an-interface` and `design-a-feature` into `design-it-twice`.**
  - Decision: one skill with the shared five-step loop in `SKILL.md`, and one branch file per domain.
  - Rationale: the two share the workflow almost word for word and have already drifted apart. Only the interface skill runs one subagent per design and tests the synthesis against breaking cases, and both improvements apply to UI work. The user delegated the call.
  - Revisit if: a branch file grows steps of its own that the other branch never needs.
- **D3 — `grammar-tutor` goes passive.**
  - Decision: fix it, then move it to `passive-skills/`.
  - Rationale: the user does not want it now, and a fixed skill is ready when they do.
  - Revisit if: the user wants grammar tutoring again.
- **D4 — Nested lists, not tables, in these docs.**
  - Decision: the plan docs use nested lists where the `multi-session-plan` templates use tables.
  - Rationale: `AGENTS.md` § Writing takes precedence over the skill's templates.

## How to use these docs

- Start each session by reading this overview (the trim rules and the acceptance procedure), then the session doc top to bottom.
- Read `~/.claude/skills/writing-for-agents/SKILL.md` before the first edit; the trim rules use its vocabulary.
- Finish a session only when the acceptance procedure passes. Then tick its box and put the word counts in its index entry. Every session edits this overview for that; the session file lists do not repeat it.

## Reference materials

- `~/.claude/skills/writing-for-agents/SKILL.md` and `SKILL-MECHANICS.md`: the criteria behind the rules.
- `docs/notes/skill-flow.md`: where positioning facts live (R2).
- `docs/user-invoked-skills.md`: the human index of user-invoked skills.
- `custom-skills/grill-me/SKILL.md`: the calibration case for a tight skill.
