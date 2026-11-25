# Session 02 — Prose skills

**Goal:** Take ownership of `simple-english` and `wtf` (D1), restructure `simple-english`, and trim `stop-slop`. These three share routing lines and an overlapping list of AI tells, so they change together.

**Prerequisites:** none. Session 01 first reads better, because this session removes the routing to `grammar-tutor`.

> **Sizing:** `simple-english` is about 6.3k words with its references. If the session runs long, split it: 02a `simple-english`, 02b `stop-slop` and `wtf`. Acceptance applies to the combined result.

## Tasks

1. **Ownership (R8).**
   - `simple-english/SKILL.md:294`: rewrite the `<sub>` line as "Adapted from … at 2.0.0 (MIT)". Drop "body verbatim" and "To update, re-pull…".
   - `simple-english/SKILL.md:9`: change the `vendored-from` metadata key to `adapted-from`. Nothing else in the repo reads that key (a grep for `vendored-from` found only this line, executed 2026-11-25).
   - `wtf/SKILL.md:35`: the same rewrite, keeping "v3.38.3".
2. **`simple-english`: remove duplication (R5).**
   - The "make sure that" / `configuration` rule is at `:22` (step 3), `:229-230` (Word Choice) and `:258` (self-check 4). Keep one.
   - `:232` "Common swaps" repeats `references/word-swaps.md` and `checklist.md:23-25`. Point at the reference.
   - `:23` (step 4, "Define a technical term…") repeats Plain rule 2 at `:53`. "This step is not optional" is at `:25` and `:253`.
   - `:28` (check-mode reporting, "invented rule numbers") repeats `checklist.md:55`. The Limits section (`:283`) repeats `checklist.md:56`.
   - `:240-249` "Your Reply to the User" and `:220` "Collaborative leftovers" both ban "I hope this helps".
3. **`simple-english`: move branch-only reference out (R4).** Plain mode never needs these. Move them to `references/` behind pointers:
   - the (S) rows in the catalog (`:70`, `:102`, `:192`), which repeat `references/strict-vocabulary.md:9-19`;
   - Section 7 Safety (`:157-168`);
   - the modal ladder (`:198-207`), which partly repeats `:110-111`;
   - the Full Example (`:264-277`);
   - Limits.
4. **`simple-english`: description (R3).** Collapse the list "docs, READMEs, runbooks, procedures…" into the branch it names: text a reader follows exactly and reads cold. Replace "`grammar-tutor`" in the routing fence; that skill is passive now (D3).
5. **`stop-slop`.**
   - Description (R3): "Rewrite, check, or draft prose" and "de-slop or tighten … check it for AI tells" are one branch. Cut "or when another skill loads it". Drop `grammar-tutor` from the routing.
   - `references/patterns.md:34`, `:38`, `:39`, `:40` (rules 21–24) repeat `SKILL.md` tests 1, 4, 3 and 6. Shorten each to its name plus "see test N"; keep the examples (R5).
   - `references/patterns.md:7` "What an edit may change" restates `SKILL.md:20`. Keep the examples (R5).
   - Fold `references/terminology.md` (66 words) into test 7 ("Gloss the identifier"), then remove the file and its pointer. Removing the file needs the user's OK at the time.
   - `SKILL.md:23` "Note that the pattern catalog did not apply inside detect findings…" is hard to parse. Reword it; do not cut it, because its effect is unclear.
6. **`wtf`.**
   - Description (R3): it is user-invoked. One human line. The routing sentence to `simple-english` and `stop-slop` reaches no model; cut it.
7. **Cross-skill.** `simple-english:209-223` and `references/word-swaps.md` overlap `stop-slop/references/patterns.md` (#1, #10, #12, #36). Keep each tell in one skill: `stop-slop` owns AI tells in prose; `simple-english` keeps only the ones that are STE word-choice rules. Point across where needed.

## Files to create / modify

- `custom-skills/simple-english/SKILL.md`, `custom-skills/simple-english/references/*`: new reference files for task 3.
- `custom-skills/stop-slop/SKILL.md`, `custom-skills/stop-slop/references/patterns.md`, `custom-skills/stop-slop/references/terminology.md`.
- `custom-skills/wtf/SKILL.md`.

## Reuse references (read-only)

- `custom-skills/simple-english/references/`: the existing reference layout to extend.
- `custom-skills/grill-me/SKILL.md`: the calibration for a tight skill.

## Acceptance / verification

- The overview's acceptance procedure.
- `grep -rn grammar-tutor custom-skills` returns nothing.
- `simple-english/SKILL.md` falls by at least 500 words. This target is from the review's estimate; record the real number.

## Out of scope

- Changes to the STE rule catalog itself. This session moves and de-duplicates rules; it does not change what they say.
- Comparing with upstream: roadmap.

**Considered and not built:**

- Merging `simple-english` and `stop-slop`: they serve different readers (text followed exactly vs prose read), and their descriptions already fence each other.
