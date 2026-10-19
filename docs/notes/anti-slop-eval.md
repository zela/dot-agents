# Evaluating miqdadbadjuber/anti-slop

[miqdadbadjuber/anti-slop](https://github.com/miqdadbadjuber/anti-slop) at v3.2.21 (commit `439a2ef`, 2026-10-16), MIT. It has six skills: a core filter (`antislop`) plus `antislop-ui`, `antislop-copywriting`, `antislop-human`, `antislop-layoutmobile`, and `antislop-code`. Together they hold about 24.5k words. Evaluated 2026-10-19 against the [skill flow](skill-flow.md) by reading the source. No skill was run.

## Verdict: do not install. Harvest three small ideas.

The kit is a self-contained system, not a set of composable skills. Every sub-skill says "load with the core" and cites core rules by number (R-01 to R-38), so a sub-skill installed alone carries dangling references. The core itself does not fit this kit:

- **Context load.** The core is about 9.4k words, and its description says "Load always". Our kit keeps descriptions short and makes hand-typed skills user-invoked ([mattpocock eval](mattpocock-skills-eval.md), `writing-for-agents`).
- **A blocking question every session.** The core resolves a "during or after" mode. With no saved preference, it must ask, end the response, and wait, even for a read-only request. `npx antislop-ai --mode during` saves an answer in `~/.config/antislop/settings.json`, but that is another piece of global state to keep in sync.
- **It claims priority over everything else.** The Delivery Gate "cannot be delegated or replaced" by another workflow, and the Claude plugin injects its pointer inside `<EXTREMELY_IMPORTANT>`. Our `AGENTS.md` Instruction Priority puts the user and `AGENTS.md` above any skill. The two would conflict on every UI task.
- **It writes to the entry file.** The install wizard appends a pointer block to `CLAUDE.md` or `AGENTS.md`. Here `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` are symlinks into this repo, so the wizard would edit tracked files.
- **Its state goes outside `docs/`.** After mode writes audits to `anti-slop/audit-NNN-YYYY-MM-DD.md` in the project root, not to the `docs/` backbone.
- **R-02 bans em-dashes in all agent text.** `AGENTS.md` Writing permits them in prose. `stop-slop` already has the same ban, so this is not new friction, but the core would add a hard-gate FAIL on top of it.
- **Its target is marketing UI.** Most rules are about landing pages: heroes, pricing cards, testimonials, "Trusted By" bars, bento grids. The flow builds engineering work, and `frontend-design`, `design-a-feature`, and `prototype` already cover UI direction.

## Per-skill verdicts

- **`antislop` (core): skip.** See above. The useful part is the honesty rules, harvested below.
- **`antislop-code`: skip, harvest one line.**
  - Overlap: `AGENTS.md` Comments already covers about 80% of it: explain why, do not restate code, match density, no banners, no trivial docstrings.
  - New idea: "value is not length". A justified comment is still one line, two at most. Its list of comments to keep (workarounds, protocol rules, edge cases) is the usual excuse for a paragraph.
  - Conflict: it says to drop issue numbers and history. Our agent-maintained rule asks a comment to name the file or ADR behind a non-obvious shape, so keep that pointer and drop only the narrative.
  - Harvest: add the length cap to `AGENTS.md` Comments.
- **`antislop-copywriting`: skip, harvest on the day `stop-slop` is vendored.**
  - Overlap: `stop-slop` (installed) covers the same tells with blunter rules ("kill all adverbs", "no passive voice").
  - Better than `stop-slop`: a "What NOT to flag" list, "look for clusters, not isolated tells", "signs of human writing", voice calibration from a sample, and "a rewrite adds no fact that is not in the source".
  - Conflict: it bans inline-header lists (`- **Label:** text`), which our own docs use often, and it inherits R-02.
  - Harvest: the false-positive list and the no-new-facts rule, if `stop-slop` ever needs local edits.
- **`antislop-human`: skip, harvest the contrast checker if it is needed.**
  - New idea: "never assert a contrast pair passes AA; compute it". This is our Evidence Discipline applied to color. `contrast-check.py` turns a guess into an executed claim with no browser.
  - Overlap: the `chrome-devtools-mcp:a11y-debugging` plugin skill checks contrast, focus, and keyboard use in a real browser. The rest of the skill (focus, keyboard, UI states) is standard WCAG.
  - Harvest: copy `contrast-check.py` (with attribution) into `cross-engine-check` the first time a contrast claim needs checking without a browser.
- **`antislop-ui`: skip, harvest the honesty rules.**
  - Overlap: `frontend-design` gives aesthetic direction. The rest is a landing-page purpose test with ENERGY/RHYTHM/MOTION dials that depend on the core.
  - New idea: R-17, R-18, R-36, and R-38. No invented statistics, testimonials, logos, or claims. Use real content or a visible placeholder. This is C-5 "Evidence Over Claims" in the core.
  - Harvest: one rule into `prototype` and `design-a-feature`. Mock content is a labeled placeholder, never a plausible fake number or quote.
- **`antislop-layoutmobile`: skip.**
  - Overlap: `modern-web-guidance` covers modern responsive patterns (container queries, `dvh` units, fluid type). `cross-engine-check` covers engine-specific claims.
  - What remains is marketing-page heuristics (huge padding, bottom nav, bare hamburger) with no gap in the flow.

## If the verdict changes

A project that builds marketing pages could use the kit. In that case, install it in that project only, with `npx skills add miqdadbadjuber/anti-slop -p`, and save a mode first with `npx antislop-ai --mode during`. Do not add it to `upstream-sources.txt`, because that installs it globally.
