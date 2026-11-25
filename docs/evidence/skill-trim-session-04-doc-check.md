# Skill trim — Session 04 doc check

- Base commit: `93c4150`, with the grilled `session-04-census.md` uncommitted in the working tree. No file the doc cites changed between `dec444e` and the base.
- Docs checked: `docs/skill-trim/session-04-census.md`, against `00-overview.md`, `roadmap.md`, `session-05-review-ship.md`, `session-06-design.md`, `docs/notes/skill-flow.md`, `docs/user-invoked-skills.md` and `README.md`.
- Method: one read-only agent, 2026-11-25, after the grill of the same day. Each harm finding was spot-checked by re-running the commands. The re-check (step 6) covered only the changed lines: the scanner commands were re-run, and the expected `secret` hits were compared with the grep.
- Launch gate, from the repository root: `shasum -a 256 -c docs/evidence/skill-trim-session-04-doc-check.md.sha256`
- This report replaces the Session 04 part of `skill-trim-doc-check.md` for launch. That file's hash for `session-04-census.md` and `session-05-review-ship.md` no longer matches, because both changed after it.

Severity legend:

- **blocker**: a task or an acceptance item cannot be done as written.
- **wrong**: a fact is wrong, and the work can proceed.
- **harm**: a step that can cause harm, or a check that can pass without testing anything.
- **gap**: a missing refusal case, file, hotspot, claim marker or acceptance item.
- **drift**: a `file:line` that moved.

## Findings

- **harm, spot-checked, fixed.** The scanner acceptance item ran the script, not the edited text, so it passed before and after the change. Now it checks that the new text links the script relative to the skill folder and that the bare command is gone.
- **harm, spot-checked, fixed.** "Check that it produces a report" passed on a wrong root: `/nonexistent/xyz` exits 0 with "No obvious complexity hotspots found". It now runs on `custom-skills/complexity-optimizer` and expects `## HIGH nested-loop`.
- **wrong, fixed.** The `secret` grep had three hits that are neither owners nor pointers: `SKILL.md:79` ("whether a prod secret is set"), `audit-categories.md:105` (`wrangler secret list`), and "secrets exposure" after it moves to `references/verifier-fallback.md`. The acceptance now lists them as unrelated hits.
- **wrong, fixed.** "No other line permits zero subagents at standard depth" was false, because "≤4" includes zero. The new reason: step 2 opens with "Fan out".
- **wrong, fixed.** Task 2 said "one positive sentence" but quotes two. It now names the second as the paired guardrail (R6).
- **wrong, fixed.** `session-05-review-ship.md:62` called `census/SKILL.md:66` "the other copy … for the shared path". No shared file is planned (roadmap item 3), and Session 04 moves the copy. The line now names both locations.
- **gap, partly fixed.** The scanner path fix assumes the host tells the agent the skill's base directory. That holds on Claude Code, is unverified on Codex and Gemini, and `craft:51` relies on the same assumption. The task now marks the assumption inferred and records the defect as executed: the bare command exits 2. No probe step was added.
- **gap.** The acceptance greps cover three terms only. Greps that can fail for the other tasks: `monoton` (one hit, step 1); `protected subject` (only `references/verifier-fallback.md`); `uncommitted\|git commit` (boundary only); `provably\|defensive-only` (step 3 only); `÷ effort\|divided by effort` (template only); `modern-web-guidance` (one hit, step 3); `03369ee` in both `<sub>` lines and `v1.2.3` in `audit-categories.md`; `What not to do\|Run tests + lint` in `complexity-optimizer/SKILL.md` (nothing). The plan-wide check recorded the same gap.
- **gap, fixed.** The doc did not name these removed behaviours as intended cuts, so the replacement check (overview step 2) would have raised each one for the user's OK. The user kept the first item, folded into task 2's guardrail. The doc now lists the rest under "Intended cuts".
  - `:27`: "a repo convention or a prior session's approval is not it", and "in this session".
  - `:66`: "record what was observed, not what you inferred", and the two example triggers.
  - `:17`: "All three are read-only, so they stay inside census's boundary".
  - `audit-categories.md:3`: "a 2k-line library gets a lighter pass than a 500k-line monorepo".
  - `:105`: "Depth and ceremony scale with the repo".
  - The `complexity-optimizer` description: the routing to `code-review` and `simplify`.
- **gap.** The new `census` description contains `: `, so it must stay quoted in YAML. Overview step 5 checks that the field exists, not that the frontmatter parses.
- **gap.** Task 4 keeps a "reader-facing legend" at template `:14`. Template `:10` already defines `min`. Keep the cut line and the lift rule at `:14` without repeating `:10`.
- **gap.** `README.md:109` names no source for `census`, while other adapted rows do (`ad40248`). R8 requires only Vendored → Adapted, so this is optional.
- **gap.** The doc gives "repeats `SKILL.md:23`" as the reason to cut `audit-categories.md:5`. But `SKILL.md` does not reach subagents, and `:5` sits in a header that the brief does not name. The cut probably loses nothing, but the stated reason ignores the context split.

## Checks that found nothing

- References: every cited `file:line` matches the base.
- Cited commits: `18b6b54`, `7f53a73`, `b5c7f47` and the v1.2.3 line hold. The agent did not verify `03369ee` (that needs the network). The grill session got it from `gh api` the same day.
- The "not swept" and "complexity-optimizer" greps fail before the change (4 hits each), and their expected owners match what the tasks leave.
- Superseded decisions: no passage in the doc, the overview, the roadmap or Sessions 05 and 06 states a behaviour the grill replaced.
- Already shipped: no task is done in the code.
- Overlap: Session 06's edit to `audit-categories.md:66` is named in both docs and the overview.
- Living docs do not contradict the new descriptions. The R2 facts cut from `:13`, `:101` and `:105` still live in `skill-flow.md`.
