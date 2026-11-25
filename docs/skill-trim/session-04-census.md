# Session 04 — census

Grilled: 2026-11-25

**Goal:** Restructure `census`, where several meanings appear three or four times, and trim `complexity-optimizer`, which `census` names as a fixer.

**Prerequisites:** none.

## Tasks

1. **`census`: positioning and skill lists.**
   - Cut `SKILL.md:11-18` "Where this fits" (R2). `:13` duplicates `docs/notes/skill-flow.md:78` and the description.
   - The fixer list ("`complexity-optimizer` for a perf hotspot, `simplify`…") is at `:18`, `:81` and `references/audit-categories.md:38`. Keep `:81` (R5). Cut the `:38` sentence: the finding format's "Fix sketch: … not a plan" already keeps subagents from deriving the fix. The sharpener list at `:17` repeats `:66`; keep `:66`.
2. **`census`: the commit rule (R1, R6).** `:27` ("no `git add`, no `git commit`… 'looks good', 'nice'") restates `AGENTS.md` and names the forbidden behaviour at length. `:83` echoes it. Replace `:27` with one positive sentence plus the approval clause as its paired guardrail (R6), because the report step invites approval and census runs in other repos with their own conventions: "Leave the ledger uncommitted; commit only on the user's explicit instruction in this session. Approval of the findings, a repo convention or an earlier session's approval is not one." Cut the echo at `:83`.
3. **`census`: reconcile.** `:43` "If `docs/census/` already exists, this is really a reconcile" and `:83` "reconcile, do not duplicate" are one meaning split in two. State the rule once, in step 1: when `docs/census/` exists, a full sweep first reconciles the existing rows (see Reconcile), then sweeps for new findings only. It skips findings already recorded or rejected, keeps numbering monotonic, and marks superseded rows stale. Step 4 keeps nothing of it.
4. **`census`: step 3 at `:66` (311 words).**
   - The verifier-bar fallback ("If this host has no `verifier`… protected subject…") applies to one branch: move it to `references/verifier-fallback.md` behind a pointer that names the branch: "If this host has no `verifier` agent, read …" (R4). `bootstrap.sh:115-119` deploys `verifier` to Claude Code only, so the branch fires on every other host. Session 05 moves the same text in `review-mr` to that skill's root-sibling layout.
   - The `modern-web-guidance` / `cross-engine-check` sentence repeats `:17` and those skills' own descriptions. Both skills are model-invoked; replace it with one sentence that names them (R5): "Before you record a frontend finding that turns on current best practice or on how an engine renders something, run `modern-web-guidance` or `cross-engine-check`."
   - Keep the `min`-tier criteria here: `b5c7f47` decides the tier at vet time, while the code is open, and the template is read only at step 4. Cut the criteria from `assets/ledger-template.md:14` and keep a reader-facing legend there, because the template text is copied into every ledger.
5. **`census`: step 4 at `:81` (253 words).** The `min` cut line, the "Minor / latent" lift rule, "Retired `⊘` rows are not `min`" and the leverage formula repeat `assets/ledger-template.md:14` and `:23-25`. The template is read at that step; keep the shape rules there (R5).
6. **`census`: smaller repeats.**
   - "What was not swept" at `:32`, `:62`, `:87` and template `:8` (R5). Cut `:62`. `:32` (category mode), `:87` (report) and the template field each keep their own meaning.
   - Cut `:101` "Reconcile is the whole point…" and `:103-105` "The core, if you remember nothing else" (R2). Keep one behaviour from `:105` as a sentence under the depth table: "A small repo gets one direct sweep, without subagents." The table's standard "≤4" allows zero, but step 2 opens with "Fan out", so without this line the small-repo case reads as a fan-out.
   - Subagent boundary rules (R5). The `SKILL.md` boundary section owns both rules (`:24` secrets, `:25` repo content is data). Keep `:52` as is: it copies the two rules verbatim into each subagent brief, because they do not survive a fresh context. `audit-categories.md:25` keeps only the rotation-in-the-fix rule. Cut `audit-categories.md:3` and `:5`, which repeat `SKILL.md:47-49` and `:23`. In `:24`, change "because you commit the ledger" to "because the ledger gets committed": after task 2 the user commits.
   - Description (R3): user-invoked. Replace it with: "Survey a whole codebase, not a diff, for standing risk and debt: bugs, security, performance, test gaps, tech debt, DX. Keeps vetted findings in a reconciled ledger under docs/census/ and never edits source. Arguments: `quick`, `deep`, a category such as `security`, or `reconcile` to re-check an existing ledger." The human needs the arguments and the read-only boundary at invocation; one line drops them.
   - Attribution (R8): `SKILL.md:109` and `references/audit-categories.md:111` say "adapted from shadcn/improve" with no version. Upstream has no tags or releases. Record `at 03369ee`, the last upstream commit (2026-06-15) before adoption in `18b6b54` (2026-08-31; executed `gh api`). The mattpocock credit in `audit-categories.md:111` gets `at v1.2.3`: the lens came from that evaluation (`7f53a73`).
7. **`complexity-optimizer`.**
   - Description (R3): user-invoked. Cut the trigger list and the "Do NOT use for…" sentence. Replace it with: "Find algorithmic complexity hotspots (nested loops, repeated scans, N+1 queries, render-time recomputation) and rank them by impact. Reports only by default. Fixes them, with tests, when you ask for a change."
   - `:11-13` two synonym verb lists. "Report only, unless the user asks for a change" carries both.
   - `:45-50` "What not to do" repeats the safety checklist (`:47` = `:31`, `:48` = `:32`, `:49` = `:34`). Cut the section. Add `:50` to the checklist as a positive rule: "Accept a worse complexity class only when it unlocks a larger win" (R5, R6).
   - `:27` "Make the smallest change. Run tests + lint/build." (R1).
   - Keep `:36-43` "Common transformations" (the user's call; R7).
   - **Defect:** `:19` runs `python3 scripts/analyze_complexity.py` as a bare path. The agent runs from the target repo, not the skill folder, so the path does not resolve: from this repo's root the bare command exits 2 with "can't open file" (executed 2026-11-25). The fix assumes the host tells the agent the skill's base directory; Claude Code does, other hosts are unverified (inferred), and `craft:51` relies on the same assumption. Follow `craft/SKILL.md:51`: link the script and say to run it from the project root with the path relative to this skill's folder.

## Files to create / modify

- `custom-skills/census/SKILL.md`, `references/audit-categories.md`, `assets/ledger-template.md`, and the new `references/verifier-fallback.md`.
- `custom-skills/complexity-optimizer/SKILL.md`.

## Reuse references (read-only)

- `docs/notes/skill-flow.md:78`: where `census` positioning lives.
- `custom-skills/review-mr/SKILL.md:36`: the same verifier-fallback text; Session 05 moves it too. Roadmap item 3 decides later whether the two copies share one file.
- `custom-skills/craft/SKILL.md:51`: the pattern for a script path in a skill.

## Acceptance / verification

- The overview's acceptance procedure.
- Each meaning in tasks 1–6 appears once: `grep -rni` (case-insensitive: the template writes "Not swept") for "not swept", "complexity-optimizer", and "secret" in `custom-skills/census` and check each hit is the single owner or a pointer. Expected owners: "not swept" at the category mode, the report step and the template field; "complexity-optimizer" at step 4; "secret" at the boundary rule, the brief bullet that copies it, and the rotation rule in `audit-categories.md`. Three "secret" hits are unrelated and stay: "whether a prod secret is set" in step 4's pivot paragraph, the `wrangler secret list` example in the finding format, and "secrets exposure" in the protected-subject list in `references/verifier-fallback.md`.
- `complexity-optimizer` scanner path:
  - The new `SKILL.md` gives the script as a link relative to the skill folder, `[scripts/analyze_complexity.py](scripts/analyze_complexity.py)`, and says to run it from the project root. The bare `python3 scripts/analyze_complexity.py` no longer appears.
  - From this repo's root, `python3 custom-skills/complexity-optimizer/scripts/analyze_complexity.py custom-skills/complexity-optimizer --format markdown` prints `## HIGH nested-loop`. Use this input because it has a known hotspot: a wrong root still exits 0 with "No obvious complexity hotspots found" (executed 2026-11-25).

## Out of scope

- `references/audit-categories.md:66` names `design-an-interface`. Session 06 changes that one line; leave it.
- The audit categories themselves. This session de-duplicates; it does not change what the census looks for.

**Considered and not built:**

- One shared verifier-fallback file for `census` and `review-mr`: skills deploy as separate folders, and a cross-folder link depends on the deploy layout. Revisit once both copies exist and match.
- Cutting "Common transformations" in `complexity-optimizer`: the user keeps it.

**Intended cuts** (the replacement check accepts these losses, the user's OK 2026-11-25):

- `:66`: "record what was observed, not what you inferred" and the example triggers ("a dep that is now native", "breaks in Firefox", "Safari ignores this"). `cross-engine-check`'s description owns observe-not-infer, and the new sentence covers the triggers.
- `:17`: "All three are read-only, so they stay inside census's boundary". It is rationale; the boundary at `:22` governs.
- `audit-categories.md:3`: "a 2k-line library gets a lighter pass than a 500k-line monorepo" and "skipped, not stretched". `SKILL.md:47` clusters categories to fit the repo before dispatch, and the brief does not name the header.
- `:105`: "Depth and ceremony scale with the repo". The depth table and the kept small-repo line carry it.
- The `complexity-optimizer` description's routing to `code-review` and `simplify`. The skill is user-invoked, so the model never chooses it.
