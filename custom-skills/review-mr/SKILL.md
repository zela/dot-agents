---
name: review-mr
description: Review the current GitLab MR branch against its target (default main) and save the findings as ready-to-paste MR comments in docs/. Use when the user asks to review an MR / merge request / mr/NNN branch, or wants review findings formatted as GitLab comments.
---

# review-mr

Wraps the `code-review` skill with GitLab MR context and comment persistence.
Never post to GitLab directly — the deliverable is a file in the repo, which
the user pastes from.

## Step 1 — MR context

- Branch `mr/NNN` → MR IID `NNN`; otherwise ask (it's the `!NNN` in the MR URL).
- Target branch: `main` unless stated otherwise.
- Capture diff refs: `BASE_SHA` = `git merge-base <target> HEAD`,
  `HEAD_SHA` = `git rev-parse HEAD`.
- If the working tree is dirty, warn: comments anchor to `HEAD_SHA`;
  uncommitted fixes aren't reflected, and pushing later invalidates anchors.

## Step 2 — Review

Invoke the `code-review` skill against the target branch (pass through any
requested effort level).

Then re-check its output before it becomes an MR comment. Send each candidate
finding to its own `verifier` subagent in parallel (general subagent if this
host has no `verifier`), giving it only the bare claim and `file:line` — never
`code-review`'s reasoning, never the other findings. Discard anything that
comes back DOES-NOT-REPRODUCE; those are Step 3's "Checked, not an issue"
material, not comments. Surviving findings feed Step 3.

A wrong finding costs more here than in a local review: it goes to a colleague
under your name.

## Step 3 — Draft comments

One block per finding, most severe first (bugs before cleanup):

```markdown
## <N>. <emoji> `<file>:<line>` — <one-line title>

**<Severity>:** <what's wrong + the concrete evidence: quoted old vs new code,
measured values, specificity math>

**Fix:** <the concrete change>
```

Emoji: 🐛 bug / ⚠️ risky behavior / 🎨 style & token reuse / 🧹 cleanup.

Optionally end with a **"Checked, not an issue"** section for refuted
candidates a human reviewer would likely also flag — saves re-litigating them
in the MR.

Verify every line anchor against the file (`sed -n '<line>p'`) before
finalizing — the review pipeline sometimes reports a nearby symbol's line, and
a mispositioned GitLab discussion is worse than an unpositioned one.

Anchor rules:
- Added/changed line → `new_path` + `new_line`.
- Deleted code → `old_path` + `old_line`.
- File not in the diff (e.g. dead dep in `package.json`) → general note.

## Step 4 — Persist

Write file (leave uncommitted):

`docs/mr-<IID>-review-comments.md` — branch, IID, diff refs, then the
comment blocks. This is what the user pastes from.

## Step 5 — Report

Finding counts by severity, the file path. Remind: pushing new
commits changes `HEAD_SHA` — post first, or regenerate after.