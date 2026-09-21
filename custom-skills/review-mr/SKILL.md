---
name: review-mr
disable-model-invocation: true
description: Review the current GitLab MR branch against its target (default main) and save the findings as ready-to-paste MR comments in docs/. Use when the user asks to review an MR / merge request / mr/NNN branch, or wants review findings formatted as GitLab comments.
---

# review-mr

Wraps the `code-review` skill with GitLab MR context and comment persistence.
Never post to GitLab directly. The deliverable is a file in the repo, which
the user pastes from.

## Step 1 — MR context

- Branch `mr/NNN` → MR IID `NNN`. Otherwise ask (it is the `!NNN` in the MR URL).
- Target branch: `main` unless stated otherwise.
- Capture diff refs: `BASE_SHA` = `git merge-base <target> HEAD`,
  `HEAD_SHA` = `git rev-parse HEAD`.
- If the working tree is dirty, warn: comments anchor to `HEAD_SHA`. Uncommitted fixes are not reflected, and pushing later invalidates anchors.

## Step 2 — Review

Invoke the `code-review` skill against the target branch (pass through any
requested effort level).

Then re-check its output before it becomes an MR comment. Send each candidate
finding to its own `verifier` subagent in parallel (general subagent if this
host has no `verifier`). Give it only the bare claim and `file:line`. Do not give it `code-review`'s reasoning or the other findings. Discard anything that
comes back DOES-NOT-REPRODUCE. Those are Step 3's "Checked, not an issue"
material, not comments. Surviving findings feed Step 3.

A wrong finding costs more here than in a local review: it goes to a colleague
under your name.

**Spec axis.** A change can follow every convention and still build the wrong
thing. Find the spec: the MR description and its linked issue (`glab mr view
<IID>` if `glab` is installed, otherwise ask the user to paste them), or a plan
session doc under `docs/`. If one exists, run one more subagent in parallel
with the review. Give it the diff refs and the spec text, and ask for three
lists, each item quoting the spec line: requirements that are missing or
partial, behaviour the spec did not ask for, and requirements that look
implemented but wrong. Under 400 words. If there is no spec, say so in Step 5.

## Step 3 — Draft comments

One block per finding, most severe first (bugs before cleanup):

```markdown
## <N>. <emoji> `<file>:<line>` — <one-line title>

**<Severity>:** <what is wrong + the concrete evidence: quoted old vs new code,
measured values, specificity math>

**Fix:** <the concrete change>
```

Emoji: 🐛 bug / ⚠️ risky behavior / 🎨 style & token reuse / 🧹 cleanup.

Spec findings go under their own `## Spec` heading after the code findings. Do
not merge or rerank them against the code findings. The two axes are separate
on purpose, so that one cannot mask the other.

Optionally end with a **"Checked, not an issue"** section for refuted
candidates a human reviewer is also likely to flag. This saves re-litigating them
in the MR.

Make sure that every line anchor matches the file (`sed -n '<line>p'`) before
finalizing. The review pipeline sometimes reports a nearby symbol's line, and
a mispositioned GitLab discussion is worse than an unpositioned one.

Anchor rules:
- Added/changed line → `new_path` + `new_line`.
- Deleted code → `old_path` + `old_line`.
- File not in the diff (for example, a dead dep in `package.json`) → general note.

## Step 4 — Persist

Write file (leave uncommitted):

`docs/mr-<IID>-review-comments.md` — branch, IID, diff refs, then the
comment blocks. This is what the user pastes from.

## Step 4b — MR description (on request)

When the user asks for the MR description too, write it to
`docs/mr-<IID>-description.md` with this shape:

~~~markdown
## Summary

<the smallest view that makes the point: pseudocode for logic, a call tree for
control flow, a shallow file tree for a refactor, a diff-sketch when the shape
already exists, Mermaid for interaction>

## Evidence

- **Before:** <screenshot / output / failing test>
- **After:** <screenshot / output / passing test>

## Merge danger

**Door:** one-way or two-way. A two-way door rolls back cheaply. Destructive
migrations and hard-to-reverse decisions are one-way.

**Blast radius:** <one word, then what it touches: layout shift, consumers,
mobile, a shared type>
~~~

Skip preambles. Use the terms from `CONTEXT.md` if the repo has one. A
screenshot is the best evidence for a visual change. A test that failed and
now passes is the best for everything else.

## Step 5 — Report

Finding counts by severity, the file path. Remind: pushing new
commits changes `HEAD_SHA`. Post first, or regenerate after.

---

<sub>The Spec axis is from `code-review`, and the description shape from `pr` (which credits HumanLayer's `show-me`), both in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
