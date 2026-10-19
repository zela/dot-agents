# Re-review

A re-review covers only the delta: what changed since the last reviewed head (`PREV_HEAD`). The earlier round's findings are threads now, or they still sit unposted in the review file. The thread check covers the first kind. The file refresh below covers the second.

## Find `PREV_HEAD`

1. The `- Reviewed head:` line of `docs/mr-<IID>-review-comments.md`. Older files can hold a short SHA. Git resolves it.
2. If no file exists, take the `created_at` of the newest diff thread you wrote. `PREV_HEAD` is the `head_commit_sha` of the newest version created before it (versions list, step 2 below). A thread's `position.head_sha` is no help here: GitLab moves it forward on each push.

If `PREV_HEAD` equals `HEAD_SHA`, nothing is new. Skip `code-review` and its verifiers. Run only the thread check.

## Isolate the delta

1. Make sure `PREV_HEAD` exists locally: `git cat-file -e <PREV_HEAD>`. If it is missing, run `git fetch --no-tags origin <PREV_HEAD>`. GitLab serves the head of an earlier MR version by SHA, also after a force-push.
2. Run `glab api projects/:id/merge_requests/<IID>/versions > $T/versions.json`. Find the version whose `head_commit_sha` starts with `PREV_HEAD`. Read its `base_commit_sha`.
3. If that base equals `BASE_SHA`, the delta is `git diff <PREV_HEAD> <HEAD_SHA>`. This compares two trees, so it is correct after an amend or a force-push, when `PREV_HEAD` is no longer an ancestor of `HEAD_SHA`.
4. If the base differs, the author rebased, and the tree diff mixes in target-branch changes. If no version matches `PREV_HEAD`, the earlier round reviewed a head that GitLab never had. In both cases, run a full review and give the reason in Step 5.

## Scope

Pass `code-review` the delta as its scope: the hunks of `git diff <PREV_HEAD> <HEAD_SHA>`. The full MR diff (`BASE_SHA..HEAD_SHA`) is context. A finding in code outside the delta stays only if the delta caused it or exposed it.

## Unposted findings

A finding in the review file that matches no thread was never posted. Send each one to a `verifier` in the thread-check batch, with its claim and its anchor quoted from `git show <PREV_HEAD>:<path>`. If it still reproduces, keep it and re-anchor it to `HEAD_SHA`. If it does not, drop it.

## Refresh the file

Update `docs/mr-<IID>-review-comments.md` in place, so that it shows the state at `HEAD_SHA`:

- Header: the new diff refs and `- Reviewed head: <HEAD_SHA>`.
- `## Existing threads`, the findings, and `## Spec`: replace them with this round's results. The findings are the new ones plus the unposted findings that still reproduce, renumbered.
- `## Checked, not an issue`: keep the entries the delta did not touch. Re-check the others.
- `## Spec source`: keep it. Add any spec text pasted this round.
