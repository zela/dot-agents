# Skill trim — Doc check

- Base commit: `2fc3079`. No file under `custom-skills/` changed between `dec444e` (the commit the plan's line numbers refer to) and the base.
- Docs checked: `docs/skill-trim/session-01` to `session-07`, each against `00-overview.md` and `roadmap.md`.
- Method: one read-only agent per session doc, 2026-11-25. Every blocker and harm finding was spot-checked by re-reading the cited lines.
- Launch gate, from the repository root: `shasum -a 256 -c docs/evidence/skill-trim-doc-check.md.sha256`

Severity legend:

- **blocker**: a task or an acceptance item cannot be done as written.
- **wrong**: a fact is wrong, and the work can proceed.
- **harm**: a step that can cause harm, or a check that can pass without testing anything.
- **gap**: a missing refusal case, file, hotspot, claim marker or acceptance item.
- **drift**: a `file:line` that moved.

Each finding ends with its status: **fixed** in the plan docs after the check, or **left** for the session, which re-reads each line before it edits it.

## Cross-cutting

- **gap, fixed.** Every file list omits `00-overview.md`, which each session edits for its tick and word counts. Acceptance step 1 also named a "Notes" column that the list-form index does not have. The overview now says every session edits it, and step 1 names the index entry.
- **harm, fixed, spot-checked.** Overview acceptance step 4 (`grep -rn "Vendored from"`) passes without any change in sessions that own no adapted skill (Session 05). It also misses the `vendored-from` metadata key, the "body verbatim" text, and the README rows. Step 4 now applies only to sessions with adapted skills and covers all three.
- **wrong, fixed.** `README.md` still says "Vendored" for `diagnosing-bugs` (`:116`), `domain-modeling` (`:119`), `prototype` (`:126`), `simple-english` (`:132`) and `wtf` (`:136`). No session owned these lines. R8 now covers README rows; Sessions 02, 06 and 07 list theirs.
- **gap, fixed.** R8 asks for a version, but `census` (`shadcn/improve`) and the `codebase-design` harvest line record none, and Session 07 did not name the source. R8 now names v1.2.3 for `mattpocock/skills` and asks the user where no version is recorded. The roadmap lists `shadcn/improve`.
- **wrong, fixed.** Old design-skill names in files that other sessions own: `census/references/audit-categories.md:66`, `diagnosing-bugs/SKILL.md:118`. The `design-a-*` shorthand at `decision-record/SKILL.md:40`, `decision-record/assets/adr-template.md:11` and `docs/notes/skill-flow.md:148` escaped the Session 06 grep. Session 06 now owns each line, and its grep catches `design-a-`.
- **wrong, fixed.** Sessions 04 and 05 each said to match the other's verifier-fallback file name, and neither named it. Both now use `references/verifier-fallback.md`.

## Session 01 — grammar-tutor

- **blocker, fixed, spot-checked.** The acceptance grep could not pass after correct work: the README row moves rather than disappears, and `simple-english/SKILL.md:294` also matches. The grep now names its expected hits.
- **gap, fixed.** Task 5's pointer used a repo path that the deployed skill cannot see. It now names `~/.agent/workflows/grammar-hook.md` and the destination if task 7 moves the file.
- **gap, fixed.** The "plugin layout" claim is now marked inferred.
- **gap, fixed.** The `bootstrap.sh` run rewrites the tracked `.custom-skills.prev`; the acceptance now says so.
- **gap, left.** No acceptance item runs the hook in real Claude Code. The skill goes passive, so the test waits until the user turns it on.

## Session 02 — prose skills

- **blocker, fixed, spot-checked.** `grep -rn grammar-tutor custom-skills` fails while `custom-skills/grammar-tutor/` exists, which depends on Session 01. It is now scoped to the three session skills.
- **wrong, fixed.** "Common swaps" (`:232`) repeats `checklist.md:23-25`, not `word-swaps.md`.
- **gap, fixed.** Moving the modal ladder, Section 7 and the (S) rows breaks `checklist.md:14`, `:45`, `:55`, `SKILL.md:28` and `strict-vocabulary.md:74`. Task 3 now lists them.
- **gap, fixed.** "Reaches no model" for `wtf` is now marked: checked for Claude Code and Codex, inferred for the other hosts.

## Session 03 — planning skills

- **wrong, fixed.** The file list named `references/coordinator.md` and `references/adopt.md`; both sit at the skill root.
- **wrong, fixed.** `run-state:37-40` repeat the rules at `:45`, `:46`, `:54` and `:58`. Discarding the reasoning is at `:54`/`:58`, not `:45`/`:46`.
- **wrong, fixed.** The `AskUserQuestion` acceptance excepted "Claude-only skills". There are none: `bootstrap.sh` deploys every custom skill to all hosts.
- **gap, fixed.** Renaming "join" also touches `README.md:125` and `doc-check/SKILL.md:57`. Task 1 now owns both lines.
- **gap, fixed.** Converting the templates leaves table wording at `multi-session-plan:14`, `:29`, `:93` and `:103`; now listed.
- **drift, fixed.** "(if any)" is at `:57`, not `:59`.
- **gap, left.** No acceptance item checks the `run-state` status fix, the table conversion, the wide-refactor pointer or the new `parallel-sessions` pointer. The replacement check catches only lost behaviour.
- **gap, left.** "`AskUserQuestion` is Claude-only" has no checked marker.

## Session 04 — census

- **harm, fixed, spot-checked.** The acceptance grep for "not swept" was case-sensitive and missed "Not swept" at `assets/ledger-template.md:8`. It is now `grep -rni`.
- **wrong, fixed.** The ledger template is `assets/ledger-template.md`, not `references/`.
- **wrong, fixed.** `ledger-template.md:25` does not hold the `min`-tier criteria; only `:14` does.
- **gap, fixed.** R8 for the two `shadcn/improve` lines (`SKILL.md:109`, `audit-categories.md:111`), which record no version.
- **gap, left.** The acceptance has no item for tasks 2–5 and 7: the commit rule, reconcile, the fallback move, the `min` rules, `complexity-optimizer`.
- **gap, left (inferred).** Task 6 puts the subagent boundary rules in the reference header. `SKILL.md:49` tells subagents to read only named sections, so the header may not reach them. The session must keep the verbatim copy in the brief (`:52`) or put the rules in a section that subagents read.
- **gap, left.** `README.md:109` mirrors the description that task 6 cuts, and R2 may move facts to `docs/notes/skill-flow.md`. Neither file is listed.

## Session 05 — review and ship

- **harm, fixed, spot-checked.** Overview step 4 was vacuous here; see Cross-cutting.
- **wrong, fixed.** "about 550 words" read as the size of `ship-session` (1561 words). It now says that 550 is the estimated cut.
- **wrong, fixed.** `papercuts:16` does not repeat `AGENTS.md` word for word: its last field differs. Task 7 now says it restates the format with a different field.
- **wrong, fixed.** The `review-staged` instruction-prose rule covers a `SKILL.md`, a skill's references, `AGENTS.md` and rule files, not only two file types.
- **gap, fixed.** `lesson-record:10-14` "Where this fits" was not addressed.
- **gap, fixed.** `doc-check:49` "Replacement" also duplicates `multi-session-plan:89`.
- **gap, left (inferred).** Task 1's counts decision should also say whether this plan's own word counts are snapshots.
- **gap, left (inferred).** No acceptance item checks that each new pointer resolves to an existing file.

## Session 06 — design skills

- **gap, fixed.** `domain-modeling:64` says "Vendored from" with no R8 task, so overview step 4 would fail.
- **gap, fixed.** The diagram generator is `archify`, archived (`docs/notes/skill-flow.md:5`). Task 4 now asks the user: re-render or hand-edit.
- **gap, fixed.** No acceptance item checked that `design-it-twice` is user-invoked.
- **drift, fixed.** The quote at `CONTEXT-FORMAT.md:29` was a paraphrase.
- **gap, left.** The `bootstrap.sh` removal claim has no checked marker. It holds: `bootstrap.sh:83-89`, `.custom-skills.prev:6-7`.

## Session 07 — code skills

- **wrong, fixed.** Task 6 told the session to remove an upstream line that leads to a commit. No such line exists: `:12` already replaced it. The task is now an R1 call on `:12`.
- **wrong, fixed.** The "existing reference file (196 words)" in `diagnosing-bugs` is `scripts/hitl-loop.template.sh`, a script.
- **wrong, fixed.** `multi-session-plan:44` reads only lessons, not `CONTEXT.md` or ADRs. Corrected here and in the roadmap.
- **gap, fixed.** `prototype` is user-invoked, yet its description carries a trigger list; R3 now covers it.
- **gap, fixed.** `README.md:116-117` and `:126` were missing from the file list.
- **gap, left.** The two tool claims have no checked marker: "a user-invoked skill it cannot start", and "the Artifact sentence restates the host's tool description".

## Re-check of the fixed lines

One read-only agent checked only the lines changed by the fixes above. Each finding ends with its status.

- **wrong, fixed, spot-checked.** The new overview step 4 (`grep -rni vendored`) fails on correct work: `census/SKILL.md:25` uses "vendored file" legitimately. Step 4 now greps `Vendored from\|vendored-from`, which hits only the six adapted skills.
- **wrong, fixed, spot-checked.** The `archify` entry is `upstream-sources.txt:25`; `:24` is its comment.
- **gap, fixed.** The single-line edits across sessions (03 → `doc-check:57`, 06 → `audit-categories:66`) were recorded only in the editing doc. The owning docs now name them, and the overview qualifies "each skill belongs to exactly one session".
- **drift, fixed.** `strict-vocabulary.md:74` stays true, because the self-check (`simple-english/SKILL.md:251`) does not move. That item was removed from Session 02.
- **drift, fixed.** A `references/` folder would break `review-mr`'s layout of sibling files at the skill root. Session 05 now uses `VERIFIER-FALLBACK.md` at the skill root. The two copies are shared only if roadmap item 3 decides to.
- **gap, fixed.** Session 01's acceptance grep now allows a `grammar-hook` README row if task 7 adds one.
- **drift, left.** The Session 02 claims about Claude Code and Codex invocation are not marked checked, and `~/.agents/skills` may be the Codex directory.

No fix-worthy finding remains, so the check stops here.
