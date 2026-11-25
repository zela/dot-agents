# Session 04 — census

**Goal:** Restructure `census`, where several meanings appear three or four times, and trim `complexity-optimizer`, which `census` names as a fixer.

**Prerequisites:** none.

## Tasks

1. **`census`: positioning and skill lists.**
   - Cut `SKILL.md:11-18` "Where this fits" (R2). `:13` duplicates `docs/notes/skill-flow.md:78` and the description.
   - The fixer list ("`complexity-optimizer` for a perf hotspot, `simplify`…") is at `:18`, `:81` and `references/audit-categories.md:38`. Keep `:81` (R5). The sharpener list at `:17` repeats `:66`; keep `:66`.
2. **`census`: the commit rule (R1, R6).** `:27` ("no `git add`, no `git commit`… 'looks good', 'nice'") restates `AGENTS.md` and names the forbidden behaviour at length. `:83` echoes it. Make it one positive sentence: leave the ledger uncommitted; commit only on an explicit commit instruction. The clause "approval of findings is not approval to commit" has been in the skill since its first commit `18b6b54` (executed `git log -S`), so no later incident is on record. Ask the user whether to keep that clause.
3. **`census`: reconcile.** `:43` "If `docs/census/` already exists, this is really a reconcile" and `:83` "reconcile, do not duplicate" are one meaning split in two, and they nearly contradict (do not re-sweep vs sweep and skip). Put the rule in one place.
4. **`census`: step 3 at `:66` (311 words).**
   - The verifier-bar fallback ("If this host has no `verifier`… protected subject…") applies to one branch: move it behind a pointer (R4).
   - The `modern-web-guidance` / `cross-engine-check` sentence repeats `:17` and those skills' own descriptions. Both skills are model-invoked; naming them is enough (R5).
   - The `min`-tier criteria repeat `references/ledger-template.md:14` and `:25` (R5).
5. **`census`: step 4 at `:81` (253 words).** The `min` cut line, the "Minor / latent" lift rule, "Retired `⊘` rows are not `min`" and the leverage formula repeat `ledger-template.md:14` and `:23-25`. The template is read at that step; keep the shape rules there (R5).
6. **`census`: smaller repeats.**
   - "What was not swept" at `:32`, `:62`, `:87` and template `:8` (R5).
   - `:101` "Reconcile is the whole point…" and `:103-105` "The core, if you remember nothing else" (R2).
   - `audit-categories.md:3` and `:5` repeat `SKILL.md:47-49` and `:23`. The secrets rule is at `SKILL.md:24`, `:52` and `audit-categories.md:25`. Put both subagent boundary rules in the reference header and make `:52` a pointer (R5). `:52` says the two rules are copied verbatim into each subagent brief because they do not survive a fresh context; keep that mechanism.
   - Description (R3): user-invoked. "The ledger is git-host-agnostic" and "Complements code-review…" repeat the body. One human line.
7. **`complexity-optimizer`.**
   - Description (R3): user-invoked. Cut the trigger list and the "Do NOT use for…" sentence.
   - `:11-13` two synonym verb lists. "Report only, unless the user asks for a change" carries both.
   - `:45-50` "What not to do" repeats the safety checklist (`:47` = `:31`, `:48` = `:32`, `:49` = `:34`). Fold `:50` (O(n log n)) into the checklist as a positive rule and cut the rest (R5, R6).
   - `:27` "Make the smallest change. Run tests + lint/build." (R1).
   - `:36-43` "Common transformations" may be textbook material the model knows. Unsure whether it primes the right fixes (R7).

## Files to create / modify

- `custom-skills/census/SKILL.md`, `references/audit-categories.md`, `references/ledger-template.md`, and a new reference file for the verifier fallback.
- `custom-skills/complexity-optimizer/SKILL.md`.

## Reuse references (read-only)

- `docs/notes/skill-flow.md:78`: where `census` positioning lives.
- `custom-skills/review-mr/SKILL.md:36`: the same verifier-fallback text; Session 05 moves it too. Use the same file name pattern so a later pass can share one file.

## Acceptance / verification

- The overview's acceptance procedure.
- Each meaning in tasks 1–6 appears once: grep for "not swept", "complexity-optimizer", and "secret" in `custom-skills/census` and check each hit is the single owner or a pointer.

## Out of scope

- The audit categories themselves. This session de-duplicates; it does not change what the census looks for.

**Considered and not built:**

- One shared verifier-fallback file for `census` and `review-mr`: skills deploy as separate folders, and a cross-folder link depends on the deploy layout. Revisit once both copies exist and match.
