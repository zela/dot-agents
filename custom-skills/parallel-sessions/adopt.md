# Adopt parallel sessions in a project

The setup of [`parallel-sessions`](SKILL.md) for a new project. Do it once, from the primary checkout. Ask the user before each step that writes outside the repository or grants an approval.

1. **Check the fit.** Parallel sessions pay off when a plan has session docs with file lists, and two or more sessions can own disjoint files. A plan without them gets them from the `multi-session-plan` skill first. Sessions that must run in sequence need only one worktree, or none.
2. **Write the project doc.** Copy [`assets/project-doc.md`](assets/project-doc.md) to `docs/operations/parallel-sessions.md`, or to where the plan keeps its docs. Fill each placeholder from the repository: the scripts in the manifest, the gitignored and git-excluded files, the dev server's port setting, the deploy commands. Delete a section that does not apply. Mark each value that you inferred and did not run.
3. **Point to it.** Add one line to the project's agent instruction file (`CLAUDE.md` or `AGENTS.md`): "Sessions in worktrees follow `docs/operations/parallel-sessions.md`."
4. **Set up the worktree.** Give the project one setup command that a user runs from inside a new worktree. Start with the commands in the project doc. Turn them into a script when a wave has more than two worktrees, or the steps have more than one branch. The script:
   - refuses to run in the primary checkout (`git rev-parse --absolute-git-dir` equals `--git-common-dir` there);
   - installs from the frozen lockfile;
   - links each file that only the primary has (secrets, env files, local instruction files), and never copies one;
   - prepares local data from committed seeds;
   - gives the worktree its own port slot, and refuses a slot that another worktree has;
   - prints the launch prompt and the review prompt (§ Usage in `SKILL.md`).

   Example: `scripts/worktree-setup.sh` in `oninvest-drafter`.
5. **Give each checkout its own ports.** Make the dev server read its ports from a per-checkout setting (a gitignored slot file or an environment variable). If a shared backend accepts only one origin, say so in the project doc: only one checkout at a time can run a real check.
6. **Guard the shared things.** Each guard is a project hook or a check in a script:
   - Block the Read, Edit and Write tools on secrets files (`.env*`, `.dev.vars*`). A shell command still gets through, so the project doc repeats the rule.
   - Make the deploy command refuse to run in a worktree.
   - If a worktree can sit inside the checkout, exclude its directory from lint and test globs.
7. **Check the settings.** Ask the user before you change either one:
   - In `~/.claude/settings.json`, once per machine: `"PLAYWRIGHT_MCP_ISOLATED": "true"` under `env`, so that each session gets its own browser.
   - In the project's `.claude/settings.json`: `worktree.baseRef` set to `"head"`, if worktrees are created with Claude Code instead of `git worktree add`.
8. **Record the approvals.** The user decides whether worktree sessions may commit on their own branch without asking (rule 8). Write the user's answer, with its date, into the project doc. Never write a grant that the user did not give.
9. **Run a trial wave.** Two sessions with disjoint files. After the join, add to the project doc what the trial found.
