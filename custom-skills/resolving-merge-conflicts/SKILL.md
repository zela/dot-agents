---
name: resolving-merge-conflicts
description: Use when you need to resolve an in-progress git merge or rebase conflict.
---

# Resolving merge conflicts

1. See the current state of the merge or rebase. Read the git history and the conflicting files.
2. Find the primary sources for each conflict. Understand why each side made its change and what it intended. Read the commit messages, the PRs or MRs, and the original issues or tickets.
3. Resolve each hunk. Preserve both intents where possible. Where the intents conflict, pick the one that matches the stated goal of the merge and note the trade-off. Do not invent new behaviour. Always resolve. Never run `--abort`.
4. Find the project's automated checks and run them: typecheck, then tests, then format. Fix what the merge broke.
5. Show the user the resolved hunks and the trade-offs. Then stop. Finish the operation (stage, commit, or `--continue`) only when the user says yes. For a rebase, ask again at each conflicting commit.

<sub>Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) `resolving-merge-conflicts` (MIT). Changed: step 5 waits for the user before the commit or `--continue`.</sub>
