# Coordinator

The procedures of the coordinator in [`parallel-sessions`](SKILL.md): prepare a wave, share the primary checkout, and join the wave. The rule numbers are the ones in `SKILL.md`.

## Before a wave

A wave starts after the join before it. Do these steps in the primary checkout on `main`, in this order. A worktree branches from `main`, so a doc change made after the launch does not reach the sessions.

Keep the wave small and its file lists disjoint. Six branches in one wave hit four merge conflicts at the join, and two branches hit none (2026-11). A session that owns most of the wave's hotspots, or is much heavier than the others, runs on `main` before the launch. The hotspot then has one owner.

1. **Grill each session doc.** Run `/grill-me` on one session doc at a time, and `/clear` between docs. Start with the riskiest session: one that changes the deploy shape, or one that shares a contract with another session. Grill two sessions that share a contract together.
   - Write each answer into the session doc. Write the behaviour and the acceptance, not the exact `grep` or `curl`: the session that implements the doc reads the code and writes the command. Name an exact command only when the command is itself the decision, for example a check that a script trap can make pass without testing anything (a script that sets a variable inline overrides the caller's value).
   - Commit the doc to `main` when its grill ends, before `/clear`: one commit per grill. Each grill's decisions then stay reviewable on their own, and a `/clear` cannot lose them.
2. **Grill the join doc.** Run one `/grill-me` on the wave's join doc. It covers the merge order, the hotspot files, and the changes that make a session stop and ask (rules 3, 5 and 6). It also collects the approvals that the join needs in one batch. A grill of one session does not cover how the sessions interact. Commit the join doc when its grill ends.
3. **Run the doc check.** Use the `doc-check` skill on every session doc and the join doc, against `main` with every grill committed. The project doc names the docs that each must agree with and where the report goes. The check can also run before step 1, to give the grill its facts. After the grills, run it again on each doc that a grill changed.
4. **Launch the worktrees.** Create each worktree from a session in the primary checkout (`SKILL.md` § Running a worktree). Give the user one launch prompt per worktree. A question about the session's own implementation can still come up in its worktree. A question about a contract stops the session (rule 5).

## Several sessions in the primary checkout

The primary checkout often runs several sessions at once: a grill beside a join, a review beside the next build step.

- Stage only the paths that you edited, then check `git diff --staged --name-only` before each commit. Another session's changes stay unstaged and untouched.
- A file that changed without your edit belongs to another session. Leave it, and tell the user.
- Slot 0 belongs to the primary checkout. One session there runs the dev server at a time.

## Join

### Local join

1. Check that each branch of the wave has a clean tree, a passed review, and a session doc whose Status says it passed.
2. Merge in the order that the join doc gives. For each branch, rebase it onto `main`, then run `git merge --ff-only <branch>`. Resolve the hotspots that the join doc lists. Regenerate a generated file instead of merging it by hand.
3. After each merge, run the project's checks command.
4. Run the join doc's cross-session checks and the items marked **(join)**.
5. Fold each `## Notes for the join` section into the shared docs. Then remove the section from the session doc.
6. Set the markers in the plan's overview.
7. Hand each release to the user as the join doc says. Deploys run from the primary checkout on `main`.
8. List the merged worktrees and branches for the user. Removing them is the user's call. Each live worktree holds a port slot, so remove the merged ones before the next wave's setup.
9. Start the next wave with § Before a wave. Its doc check runs against the `main` that this join made.

### MRs that the user merges

- When a session reports, check that the branch head and the tree match the report (`git -C <worktree> log --oneline main..HEAD` and `git -C <worktree> status --short`). Read its Status line, and fold its notes into the docs they name.
- Before the user merges an MR, list every gate that the plan puts on that merge, each with its state. If a gate has not run, say so before the merge, and record the user's call in the plan. A gate that no one lists is skipped without anyone noticing.
- For stacked MRs that squash on merge: before the parent merges, keep its tip (`git tag tmp/<parent>-tip origin/<parent>`). After the merge, `git rebase --onto origin/main tmp/<parent>-tip <child>` replays only the child's commits. Check with `git range-diff` that the commits are unchanged. The force-push needs the user's approval.
- Set a session to done in the overview when its MR merges, with the MR link.
- List the merged worktrees and branches for the user. Removing them is the user's call.
