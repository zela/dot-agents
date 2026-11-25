# Session 02 — Prose skills

**Goal:** Take ownership of `simple-english` and `wtf` (D1), restructure `simple-english`, and trim `stop-slop`. These three share routing lines and an overlapping list of AI tells, so they changed together.

**Status:** done on 2026-11-25, in commits `582e033` to `6fc8350`. The word counts are in the overview's session index.

**Prerequisites:** none. `grammar-tutor` was already passive (commit `48bf995`), so the routing lines to it could go.

> **Sizing:** `simple-english` was about 6.3k words with its references. The session ran as one; it did not need the 02a/02b split.

## Tasks

1. **Ownership (R8).**
   - `simple-english/SKILL.md`: the `<sub>` line reads "Adapted from … at 2.0.0 (MIT, see `LICENSE`)", without "body verbatim" or re-pull text. The metadata key is `adapted-from`. Nothing else in the repo reads that key (a grep for `vendored-from`, executed 2026-11-25).
   - `wtf/SKILL.md`: the same rewrite, at v3.38.3.
   - `README.md`: the `simple-english` and `wtf` rows say "Adapted". The `simple-english` row also names its source, AminBlg/SimpleEnglish.
2. **`simple-english`: duplication (R5).**
   - The "make sure that" / `configuration` rule lives in step 3. Word Choice and self-check 4 point back at it.
   - Step 4 points at Plain English rule 2 instead of restating it. Deviation: rule 2 is stricter than the old step 4, so documents now also get its limits. Standard names (Postgres, S3, HTTP, JSON) get no definition, a definition stays under ten words, a sentence has at most one, and a definition holds no synonym. The replacement check found this change, and the user kept it (2026-11-25).
   - "This step is not optional" stays only in step 6.
   - The check-mode reporting rule stays at `SKILL.md:28`. Its copy in `checklist.md` is gone.
   - Kept on purpose: "Common swaps" in Word Choice, although `references/checklist.md:23-25` repeats it. The swaps apply on every run, and the checklist only to a full audit.
   - Kept on purpose: both bans on "I hope this helps". "Collaborative leftovers" covers documents and replies, and "Your Reply to the User" covers replies only.
3. **`simple-english`: branch-only reference (R4).** Plain mode never needs this material, so it moved to `references/` behind pointers.
   - The Strict-only rows (1.1–1.4, 1.6, 3.1, 9.2) left the catalog. `references/strict-vocabulary.md` already held them. The catalog intro points there without a list of rule numbers, because a copied list went stale at once: it missed GR-5 and GR-8.
   - Section 7 Safety moved to the new `references/safety.md`. The pointer names its trigger: a warning or a caution, injury, damage, data loss, a destructive flag, an irreversible migration.
   - The check-mode citation rule (`SKILL.md:28`) names `strict-vocabulary.md` and `safety.md`, so the moved rules stay citable. `checklist.md:45` points at `safety.md` for rules 7.1–7.3. The self-check stays in `SKILL.md`, which keeps `references/strict-vocabulary.md:74` true.
   - The section headers keep the standard's full rule ranges, including the rules that live in a reference file.
   - Kept on purpose: the modal ladder. Modals occur in almost every draft, and Section 3 gives no replacement for "may", "might" and "would".
   - Kept on purpose: the Full Example. It shows the whole method on one passage, and every rewrite uses that method.
   - Kept on purpose: Limits. Its compliance line covers write mode, which `checklist.md` does not.
4. **`simple-english`: description (R3).** The list "docs, READMEs, runbooks, procedures…" stays. Its items are distinct document types, not synonym triggers. Several of them (API guides, release notes, incident reports) are descriptive, so the branch "text a reader follows exactly" alone would route them to `stop-slop`. "Check" joined the leading verbs, because the body has a check mode. `grammar-tutor` left the routing fence (D3).
5. **`stop-slop`.**
   - Description (R3): one branch, "de-slop or tighten prose". "Or when another skill loads it" and `grammar-tutor` are gone.
   - `references/patterns.md` rules 21–24 point at `SKILL.md` tests 1, 4, 3 and 6 and keep their examples. "What an edit can change" points at edit mode in `SKILL.md` and keeps its examples, now as a list.
   - `references/terminology.md` is removed, with the user's OK (2026-11-25). Its guidance is in test 7 and in the keep line under the tests.
   - Two `terminology.md` sentences were dropped as no-ops, with the user's OK. They were "without shortening away content" (the Done line keeps every fact) and "the protections and user-voice limits still apply" (Register and Boundaries already bind). The replacement check rated the residual risk medium-low: an agent that edits the user's own text could apply test 7's jargon replacement over the Register rule.
   - The non-English sentence (`SKILL.md:23`) reads as an instruction: apply the tests only, say that the catalog did not apply, and say it only in detect findings or in a requested change line. The upstream guide confirms this reading (`docs/guides/ce-noslop.md:54` at `fcb5e3ad`): "The note that the catalog did not apply goes inside detect findings or inside a change line the caller asked for, and nowhere else."
6. **`wtf`.** The description is one human line. The routing sentence to `simple-english` and `stop-slop` is gone, because no model reads it on Claude Code (`disable-model-invocation`) or Codex (`agents/openai.yaml:5`). For Antigravity and `~/.agents/skills` this is inferred, not checked.
7. **Cross-skill.** The overlap stays between `simple-english` ("Signs of AI Writing" and `references/word-swaps.md`) and `stop-slop/references/patterns.md` (#1, #10, #12, #36). `simple-english` applies its tell list on every run, while `stop-slop` applies only when an agent loads it, so a cut from `simple-english` loosens it. The user decided on 2026-11-25 that `simple-english` keeps its length when the length delivers quality.

## Deviations and gotchas

- The word-count targets went. The user decided that word count is a record, not a goal (2026-11-25). This session removed its own 500-word target and Session 05's 400-word target, so it edited `00-overview.md` and `session-05-review-ship.md` outside its file list. `simple-english/SKILL.md` fell by 224 words.
- `review-staged` found nine writing-rule breaks in this session's own rewrites of the writing skills. One of them left rule 21 harder to read than before. The fixes went into the same commits.
- `gh api repos/EveryInc/compound-engineering-plugin/git/trees/v3.38.3` returns 404. The commit `fcb5e3ad`, which `docs/notes/compound-engineering-eval.md:3` records, does.

## Files changed

- `custom-skills/simple-english/SKILL.md`, `references/checklist.md`, and the new `references/safety.md`.
- `custom-skills/stop-slop/SKILL.md` and `references/patterns.md`. `references/terminology.md` is removed.
- `custom-skills/wtf/SKILL.md`.
- `README.md`: the two rows in task 1.
- `docs/skill-trim/00-overview.md` and `docs/skill-trim/session-05-review-ship.md`: the word-count decision (see Deviations and gotchas).

## Reuse references (read-only)

- `custom-skills/simple-english/references/`: the existing reference layout to extend.
- `custom-skills/grill-me/SKILL.md`: the calibration for a tight skill.

## Acceptance / verification

Run on 2026-11-25.

- The overview's acceptance procedure:
  1. Word counts: `wc -w` before (`9e9d41d`) and after. They are in the session index.
  2. Replacement check: an independent subagent compared `9e9d41d` with `HEAD` for the three skill folders. Each change it found is named in the tasks above. The step 4 change in task 2 has the user's OK.
  3. `review-staged` ran on the staged diff. Its fixes went into the commits without a second review pass.
  4. `grep -rn "Vendored from\|vendored-from"` over the three skills returns nothing. `grep -ni vendored README.md` shows no row for them. No `<sub>` line keeps re-pull or "verbatim" text.
  5. Each changed `SKILL.md` has `name` equal to its folder name and a `description`.
  6. The user asked for the commits.
- `grep -rn grammar-tutor custom-skills/simple-english custom-skills/stop-slop custom-skills/wtf` returns nothing.

## Out of scope

- Changes to the STE rule catalog itself. This session moved and de-duplicated rules; it did not change what they say.
- Comparing with upstream: roadmap. One sentence was checked upstream to settle its meaning (task 5).

**Considered and not built:**

- Merging `simple-english` and `stop-slop`: they serve different readers (text followed exactly vs prose read), and their descriptions already fence each other.
