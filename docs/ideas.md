# Ideas

Ideas worth building, not yet scheduled. Each entry says where it came from, where it would plug into the kit, and the smallest next step. When an idea ships, move it to the relevant skill or doc and delete the entry. When it is rejected, record why in its evaluation note.

## HTML pages for oversight and learning

Source: [Karpathy output-format evaluation](notes/karpathy-output-formats-eval.md). Every page built for oversight follows the rules in that note: it is built from evidence, it keeps the executed / inferred / assumed labels, it is generated in a subagent, and it works at phone width.

### 1. Branch walkthrough

- **What.** After a large branch or a `parallel-sessions` wave, one page groups the diff by intent. Each change shows its `file:line`, the test and lint receipts, and the open risks. Each claim carries its evidence label.
- **Why.** It targets the problem the post names: understanding what the agent did. Text review output lists findings; it does not show the shape of the change.
- **Plugs into.** An optional step after `review-staged`, or in `ship-session`.
- **Next step.** On the next large branch, ask for the page by hand. Compare it with the `review-staged` text. Two wins make it a skill step.
- **Open questions.** Which input decides the grouping by intent: commit messages, the session doc, or the diff alone? Does the `diagram` skill cover its diagrams, or does it need its own layout?

### 2. Review findings with per-finding comments

- **What.** A review publishes its findings as an Artifact. The user comments on each finding: fix, skip, or why. The session reads the comments through `ArtifactComments` and applies the decisions.
- **Why.** It replaces copying findings between the review output and the chat. Each decision stays attached to its finding.
- **Plugs into.** `review-staged`, `code-review`, `review-mr`. `review-mr` already writes one block per comment, so its output shape fits.
- **Next step.** Publish one real review this way and apply it from the comments.
- **Constraint.** Artifacts and their comments exist only in Claude Code. Codex and Gemini keep the text output.

### 3. Interactive concept explainer

- **What.** A page with a small simulation that teaches one concept, for example a consistent-hashing ring or a token-bucket rate limiter.
- **Why.** It is the post's main use. The page explains a concept, not agent output, so the risk of a convincing but wrong claim is lower.
- **Plugs into.** `system-design-mentor` and `teach`. Ask for it ad hoc; no skill change is needed until the pattern repeats.
- **Next step.** Ask for one in the next mentoring session and note whether it beat the prose explanation.

### 5. Wave dashboard

- **What.** One page for a `parallel-sessions` wave: each session's Status line, its worktree and branch, commits ahead of `main`, the acceptance results, and the dependency graph from the plan overview.
- **Why.** At three or more sessions, the state is spread across worktrees and docs. One page shows which session is blocked, done, or waiting for the join.
- **Plugs into.** `parallel-sessions`, at the join. It is generated on demand and discarded; the plan docs stay the source of truth.
- **Complexity: medium, and mostly in one place.** Most inputs already exist in a fixed format: the overview status table (☐ ◐ ☑), the Status line in each session doc, `git worktree list`, and `git log main..<branch>`. The gap is acceptance results. A session reports them in the chat (`parallel-sessions` step 9), so no file holds them. The dashboard needs each session to write its acceptance receipts to its doc or to a small state file first.
- **Next step.** Decide where a session writes its acceptance receipts. Then build the page by hand for one real wave.
