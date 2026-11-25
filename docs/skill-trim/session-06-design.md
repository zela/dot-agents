# Session 06 — Design skills

**Goal:** Merge `design-an-interface` and `design-a-feature` into `design-it-twice` (D2), and trim `decision-record`, `domain-modeling`, `system-design-mentor` and `third-opinion`.

**Prerequisites:** none.

## Tasks

1. **Create `custom-skills/design-it-twice/`.**
   - `SKILL.md`: the shared loop, user-invoked. Steps: gather requirements, generate 3+ designs with one divergence constraint each, present them one at a time, compare, synthesize with the break test. Both domains get one subagent per design and the break test; today only the interface skill has them (`design-an-interface:28`, `:68`). The anchor is the stable thing: the module's responsibilities, or the user's task. `SKILL.md` tells the agent to read one branch file, chosen by what is being designed.
   - `INTERFACE.md`: the module anchor, the gather questions (`design-an-interface:17-22`), the four constraints, the five outputs, the comparison criteria reduced to names where the vocabulary defines them (`:54`, `:56`, `:57` vs `:85`, `:89`, `:86`), the vocabulary and three tests, the dependency categories.
   - `FEATURE.md`: the user-task anchor, the gather questions (`design-a-feature:21-25`), the four constraints, the four outputs, the comparison criteria, and one line for the references: "Judge with Norman, Nielsen's heuristics and Krug; borrow Design 4 from Tidwell."
   - Description (R3): user-invoked. One human line that covers both: a module's interface or a feature's interaction design.
   - The `<sub>` line keeps the `codebase-design` attribution from `design-an-interface:119` and adds the version, v1.2.3 (R8).
2. **Cut while merging.**
   - `design-an-interface:70-77` "Theoretical Foundation": "Ousterhout" at `:9` already carries it (R2).
   - Both Anti-Patterns sections (`design-an-interface:110-115`, `design-a-feature:83-88`) repeat earlier steps. Keep one positive scope line: design the shape or the flow, not the implementation, and do not weigh implementation effort (R5, R6).
   - `design-an-interface:24` and `design-a-feature:27` "Ask:" repeat the checklists (R5). "Do not front-load comparison" restates "one at a time" (R5).
   - `design-a-feature:11-13` "Core Framing" repeats `:9` (R5).
   - `design-an-interface:108` (replace unit tests when deepening shallow modules): unsure whether it belongs in a skill that does not implement. Ask the user; it may belong in `craft` or `census` instead.
3. **Remove the old skills.** Remove `custom-skills/design-an-interface/` and `custom-skills/design-a-feature/` with `git rm`, after you show the user the two paths and get a yes. `bootstrap.sh` removes their deployed copies on the next run (manifest loop, `bootstrap.sh:70-90`).
4. **Update references to the old names.** Living docs and skills only; dated eval notes and harvest plans keep the old names.
   - `README.md:114-115`, `docs/user-invoked-skills.md:11-12`.
   - `docs/notes/skill-flow.md:19-20`, `:69`.
   - `docs/notes/diagrams/skill-flow-spine.workflow.json:39` and the rendered `skill-flow-spine.html`. The generator is `archify`, which `docs/notes/skill-flow.md:5` calls archived; re-rendering means uncommenting `upstream-sources.txt:25` and installing it. Ask the user: reinstall and re-render, or hand-edit the label in both files.
   - `custom-skills/decision-record/SKILL.md:16` and `:40` ("`design-a-*`"), `custom-skills/decision-record/assets/adr-template.md:11` ("design-a-*"), `custom-skills/domain-modeling/SKILL.md:60`, `docs/notes/skill-flow.md:148` ("`design-a-*`").
   - Lines in files that other sessions own; only these lines move with the rename: `custom-skills/prototype/SKILL.md:13` (Session 07), `custom-skills/diagnosing-bugs/SKILL.md:118` (Session 07), `custom-skills/census/references/audit-categories.md:66` (Session 04).
5. **`decision-record`.**
   - Description (R3): model-invoked, 88 words, the largest description in the kit. "Closes the one gap in the skill flow…" is rationale (`docs/notes/skill-flow.md:148` has it); the four-part list repeats the body.
   - `:10-21` "Where this fits" (R2). Keep one line: run `grill-me` first when the decision is load-bearing, and link the plan in Consequences.
   - `:33-34` duplicate the template comments `:11` and `:23` (R5).
   - Supersede-never-edit is at `:36`, `:42` and `:46`. Keep one (R5).
   - `:27` repeats template `:20` (R5, R6). `:35` "House style" (R1). `:41` no-commit (R1). `:44-46` "The core" (R2).
6. **`domain-modeling`.**
   - Defect: `:55` says `decision-record` uses "the same three-part test: hard to reverse, surprising without context, the result of a real trade-off". `decision-record:25` uses a different test. Cut the clause and leave the pointer.
   - `:11-13` "Why a glossary" (R2). `:9` "Use this skill when you change the model…" is invocation advice for a user-invoked skill (R3).
   - `:15-27` file structure repeats `CONTEXT-FORMAT.md:32-60`, including "create lazily" (R5).
   - `:57-60` Composition describes other skills; `docs/user-invoked-skills.md:10` has it (R2).
   - `CONTEXT-FORMAT.md:29` makes the "only terms specific to this project's context" point three times in one bullet (R5).
   - Attribution (R8): `SKILL.md:64` says "Vendored from"; rewrite it as "Adapted from … at v1.2.3". `README.md:119`: "Vendored" to "Adapted".
7. **`system-design-mentor`.**
   - `:9`, `:21`, `:52` say "do not give the answer first" three ways; "Socratic" is the leading word. Keep one positive line (R5, R6).
   - `:53` repeats the loop at `:24`; `:54` partly repeats `:22` (R5).
   - `:35-48` Domain Reference: a textbook topic list. Unsure whether it steers which topics come up (R7).
8. **`third-opinion`.** Tight. Optional: `:11-17` "When to use" helps the user, not the run; it could move to `docs/user-invoked-skills.md`. `:16` "strongest objection" repeats `:31`. Unsure: the cases may shape the brief. Ask the user. Also fix `docs/user-invoked-skills.md:19`, which calls it a "second review".

## Files to create / modify

- `custom-skills/design-it-twice/SKILL.md`, `INTERFACE.md`, `FEATURE.md`: new.
- `custom-skills/design-an-interface/`, `custom-skills/design-a-feature/`: removed on the user's yes.
- `custom-skills/decision-record/SKILL.md` and its template, `custom-skills/domain-modeling/SKILL.md`, `CONTEXT-FORMAT.md`, `custom-skills/system-design-mentor/SKILL.md`, `custom-skills/third-opinion/SKILL.md`.
- `README.md`, `docs/user-invoked-skills.md`, `docs/notes/skill-flow.md`, `docs/notes/diagrams/skill-flow-spine.*`, `custom-skills/decision-record/assets/adr-template.md`.
- One line each in other sessions' files: `custom-skills/prototype/SKILL.md:13`, `custom-skills/diagnosing-bugs/SKILL.md:118`, `custom-skills/census/references/audit-categories.md:66`.
- `upstream-sources.txt`: only if the user chooses to re-render the diagram.

## Reuse references (read-only)

- `custom-skills/prototype/`: the pattern of one `SKILL.md` that routes to branch files (`LOGIC.md`, `UI.md`).
- `docs/notes/mattpocock-skills-eval.md:28`: the `codebase-design` source of the vocabulary.

## Acceptance / verification

- The overview's acceptance procedure. For step 2, the old versions are both design skills together; the new version is `design-it-twice`. Every capability of each old skill appears in `SKILL.md` or its branch file, or is an intended cut named above.
- `grep -rn "design-an-interface\|design-a-" README.md docs/user-invoked-skills.md docs/notes/skill-flow.md docs/notes/diagrams custom-skills` returns nothing. The second pattern catches `design-a-feature` and the `design-a-*` shorthand.
- `custom-skills/design-it-twice/SKILL.md` sets `disable-model-invocation: true`.
- The combined word count of `design-it-twice` is below the old 1956; record the real number.

## Out of scope

- Changing the divergence constraints or comparison criteria themselves.

**Considered and not built:**

- Keeping two skills with a shared external file: two user-facing names for one loop is the cognitive load the merge removes (D2).
