---
name: review-mr
description: Review the current GitLab MR branch against its target (default main) and save the findings as ready-to-paste MR comments in docs/ plus a posting script. Use when the user asks to review an MR / merge request / mr/NNN branch, or wants review findings formatted as GitLab comments.
---

# review-mr

Wraps the `code-review` skill with GitLab MR context and comment persistence.
Never post to GitLab directly — the deliverable is files in the repo; the user
posts manually or runs the generated script with their own token.

## Step 1 — MR context

- Branch `mr/NNN` → MR IID `NNN`; otherwise ask (it's the `!NNN` in the MR URL).
- Target branch: `main` unless stated otherwise.
- Capture diff refs: `BASE_SHA` = `git merge-base <target> HEAD`,
  `HEAD_SHA` = `git rev-parse HEAD`.
- Project path: from `git remote get-url origin`, strip host and `.git`,
  URL-encode `/` as `%2F`.
- If the working tree is dirty, warn: comments anchor to `HEAD_SHA`;
  uncommitted fixes aren't reflected, and pushing later invalidates anchors.

## Step 2 — Review

Invoke the `code-review` skill against the target branch (pass through any
requested effort level). Its verified findings feed Step 3.

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

Write two files (leave uncommitted; never run the script):

1. `docs/mr-<IID>-review-comments.md` — branch, IID, diff refs, then the
   comment blocks. This is what the user pastes from.
2. `scripts/post-mr-<IID>-comments.sh` — copy
   [scripts/post-mr-comments-template.sh](scripts/post-mr-comments-template.sh),
   fill `MR_IID`/`PROJECT`/`BASE_SHA`/`HEAD_SHA`, append one
   `post_new`/`post_old`/`post_note` call per comment, `chmod +x`. The
   template has the API helpers and a `diff_refs` rebase guard.

## Step 5 — Report

Finding counts by severity, the two file paths, how to post
(`GITLAB_TOKEN=... ./scripts/post-mr-<IID>-comments.sh`). Remind: pushing new
commits changes `HEAD_SHA` — post first, or regenerate after.