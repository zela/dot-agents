# Re-review

A re-review covers only the delta: the changes since the last reviewed head (`PREV_HEAD`). The findings of the earlier round are now threads, or they are still unposted in the review file. The thread check covers the threads. The file refresh below covers the unposted findings.

## Find `PREV_HEAD`

1. Read the `- Reviewed head:` line of `docs/mr-<IID>-review-comments.md`. Older files can hold a short SHA. Git resolves it.
2. If no file exists, take the `created_at` of the newest diff thread that you wrote. `PREV_HEAD` is the `head_commit_sha` of the newest version that GitLab created before that time. Step 2 of "Isolate the delta" gets the list of versions. Do not use the `position.head_sha` of a thread, because GitLab moves it forward on each push.

If `PREV_HEAD` equals `HEAD_SHA`, nothing is new. Skip `code-review` and its verifiers. Run only the thread check.

## Isolate the delta

1. Make sure that `PREV_HEAD` exists locally (`git cat-file -e <PREV_HEAD>`). If it is missing, run `git fetch --no-tags origin <PREV_HEAD>`. GitLab serves the head of an earlier MR version by SHA, also after a force-push.
2. Run `glab api projects/:id/merge_requests/<IID>/versions > $T/versions.json`. Find the version whose `head_commit_sha` starts with `PREV_HEAD`. Read its `base_commit_sha`.
3. If that base equals `BASE_SHA`, the delta is `git diff <PREV_HEAD> <HEAD_SHA>`. This command compares two trees. After an amend or a force-push, `PREV_HEAD` is not an ancestor of `HEAD_SHA`, and the tree diff is still correct.
4. If the base differs, the author rebased, and the tree diff includes changes from the target branch. If no version matches `PREV_HEAD`, the earlier round reviewed a head that GitLab never had. In both cases, run a full review and give the reason in Step 5.

## Scope

Give `code-review` the delta as its scope: the hunks of `git diff <PREV_HEAD> <HEAD_SHA>`. The full MR diff (`BASE_SHA..HEAD_SHA`) is context. If the delta caused or exposed a finding in code outside the delta, keep that finding. Drop the other findings outside the delta.

## Unposted findings

A finding in the review file that matches no thread is unposted. Send each unposted finding to a `verifier` in the thread-check batch. Give it the claim and the anchor, with the line quoted from `git show <PREV_HEAD>:<path>`. Also ask it for the trigger and the consequence, as in SKILL.md Step 2. If the finding still reproduces, keep it and anchor it again to the line at `HEAD_SHA`. If it comes back DOES-NOT-REPRODUCE, drop it. If it comes back UNRESOLVED, keep it as an `Unresolved` line under `## Held back` (SKILL.md Step 2).

## Refresh the file

Update `docs/mr-<IID>-review-comments.md` in place, so that it shows the state at `HEAD_SHA`:

- Header: the new diff refs, `- Reviewed head: <HEAD_SHA>`, and `- Post bar:` with the bar of this round.
- `## Existing threads`, the findings, `## Spec`, and `## Held back`: replace them with the results of this round.
- `## Checked, not an issue`: keep the entries that the delta did not touch. Make sure that the other entries are still not an issue.
- `## Spec source`: keep it. Add the spec text that the user pasted in this round.
- `- Review page:` line: keep it. Rebuild that page from the refreshed file ([REVIEW-PAGE.md](REVIEW-PAGE.md)).

The findings of this round are the new findings plus the unposted findings that still reproduce. The unposted findings include the `## Held back` lines. Grade each unposted finding again. If its grade is at or above the post bar, give it a block. If its grade is below the bar, list it under `## Held back`. Then number the blocks again.
