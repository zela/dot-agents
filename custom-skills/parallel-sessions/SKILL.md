---
name: parallel-sessions
description: Run plan sessions at once in separate git worktrees, one session doc per worktree, and bring them together on main. Covers the rules for a worktree session, its setup and its review. Use when you start or run a worktree session, prepare or join a wave of sessions, adopt parallel sessions in a project, or a project doc says its sessions follow parallel sessions.
---

# Parallel sessions in worktrees

A plan that runs in **waves** runs several sessions at once. Each session runs one session doc in its own worktree, on its own branch. The work comes back to `main` in a **join**: a local merge in the primary checkout, or the user's merge of an MR.

Each project has a **project doc** (for example `docs/operations/parallel-sessions.md`) with its own values. Read it with this skill. When the project doc and this skill disagree, the project doc wins. A project without one adopts the practice by [`adopt.md`](adopt.md).

## Roles

- **Primary checkout.** The repository's own clone, on `main`. Wave preparation, every join, every deploy and the coordinator run here. The gitignored state that matters (secrets, caches, local data, local instruction files) lives only here.
- **Worktree session.** One session in one worktree on one branch. It runs one session doc of the current wave.
- **Review session.** A new session in the same worktree, after the worktree session ends (§ Review).
- **Coordinator.** The session in the primary checkout that prepares a wave, joins it, and keeps the shared docs. Its procedures are in [`coordinator.md`](coordinator.md). Read that file when you are the coordinator.

## Usage

The user starts each role with one prompt. Replace the angle brackets.

- **Prepare a wave**, in the primary checkout: "Prepare wave <n> of <plan doc> by parallel sessions."
- **Launch a worktree session**: the user creates the worktree, runs the setup command in it, and starts the agent there with "Implement <session doc>. Worktree session, slot <n>, rules in <project doc>." A setup script prints this prompt.
- **Review**, in a new session in the same worktree: "/review-staged high <base>...HEAD — review session for <session doc>, rules in <project doc> § Review."
- **Join**, in the primary checkout: "Join wave <n> by <join doc>." For MRs: "Coordinate <session doc>: check its report and its merge gates."
- **Adopt**, in a project without a project doc: "Adopt parallel sessions in this repo."

## The project doc

The project doc gives these values. A rule below that names one of them reads it from the project doc.

- The primary checkout's path, and the state that only it has.
- The branch name pattern, and where the session docs are.
- The shared docs (rule 4), the fixed contracts (rule 5) and the remote systems (rule 7).
- Whether the user grants commit approval for worktree sessions (rule 8).
- The setup command, the port slots and the checks command.
- Where evidence goes.
- How work merges: a local join, or MRs that the user merges.

## Rules for a worktree session

1. Create the worktree from local `main`, after the previous join. A worktree from `origin/main` misses every join that was not pushed. When MRs merge on a remote, pull `main` first.
2. Name the branch by the project's pattern.
3. Edit only the files that your session doc lists. If a change you need falls outside the list, stop and ask the user. It may belong to another session of the same wave. Your own evidence (screenshots, probe output, a report) goes where the project keeps evidence, without a listing.
4. Do not edit the shared docs. Write the change you need under `## Notes for the join` in your own session doc.
5. Do not change a fixed contract. If you need a change, stop and ask the user.
6. Do not add a dependency or a migration unless your doc says so. Two branches that both change the lockfile, or both take the next migration number, conflict at the join.
7. Do not deploy, and do not write to a remote system that the project doc names. A paid run needs the user's approval for that run.
8. If the project doc grants commit approval for worktree sessions, commit on your own branch without asking. The grant covers only your own branch. A commit to `main`, a push, a merge, a rebase of another branch and a commit on any other branch each still need the user's approval for that action.
   - Commit each seam when its checks pass.
   - Stage only the paths that you edited, and check `git diff --staged --name-only` before each commit.
   - End the session with a clean tree, except for the links from setup and the helpers that your doc names.
9. Run your acceptance in the worktree. Report each check with the command and its result. Leave the items marked **(join)** for the join.
10. When the session passes, convert your own doc to as-built and set its Status line. Do not change the markers in the plan's overview.

## Running a worktree

- **Create.** From the primary checkout: `git worktree add ../<repo>-<slug> -b <branch> main`.
  - A sibling directory keeps sibling repositories resolving as they do from the primary checkout.
  - A worktree inside the checkout can be picked up by repository-wide globs, such as `eslint .` or a test runner's `**/*.spec.*` (inferred from the configs, not tested).
  - A Claude Code worktree under `.claude/worktrees/` branches from `worktree.baseRef`. With `"head"` it branches from the HEAD of the session that creates it, so create it from a session in the primary checkout. A reused worktree name reopens at its old tip.
- **Set up.** Run the project's setup command once, from inside the new worktree. Setup installs from the frozen lockfile and gives the worktree its own port slot. It links the state that only the primary has, and never copies it. The user runs the steps that touch secrets.
- **Start the session in the worktree.** Launch the agent from the worktree directory. Then check `git rev-parse --show-toplevel` and `git branch --show-current`. If either is not your own worktree and branch, stop.
  - A worktree has no git-excluded or untracked file of the primary, such as `CLAUDE.md` or `CLAUDE.local.md`. Setup links them.
  - When `docs/` is outside git, launch with `--add-dir <primary>/docs`, and write only your own session doc there, through its absolute path.
  - Start in the worktree, not in the primary followed by `EnterWorktree`. Its isolation refuses every write outside the worktree, some shell forms and some rewritten git commands, and it survives `/clear`. It refused 73 actions in one wave (2026-10-28).
- **Secrets.** Read no secrets file (`.env*`, `.dev.vars*`, credential files). A command that prints only part of each line still prints a whole line when that line is not in the expected form.
- **Ports.** Each checkout runs its dev server on its own slot. When only one port reaches a shared backend, only one dev server at a time can run a real check. Start it so it fails on a taken port, and check the port before you plan around it: a doc that says another session holds it can be stale.
- **Stopping a dev server.** Stop only a server that your session started. Note its PID when you start it. Any other process on a port belongs to the user or another session, even when its working directory is your worktree: ask the user. A `pkill -f` on a command line, or a kill by port, also stops the other checkouts' servers.
- **Shared machine state.** Some state is one per machine, not one per checkout: a tool's dev registry, a browser profile, a debugger port. The last process to start owns it. Ask the user before you take it from another session.
- **Caches.** A check that reads a cache that only the primary has runs at the join.
- **Before and after.** Leave your working tree on your branch, and read the base through git. For one file, `git show <base>:<path>` into your scratch directory. For a build or screenshots at the base, `git worktree add --detach <scratch>/base <base>`, then set it up on a free slot. List that worktree for the user at the end: removing it is the user's call. `git checkout <base> -- <files>` overwrites your branch's files.

## Review

Each worktree branch gets a review before the join. Reviews still find real defects after every doc check.

- Start the review in a new session in the same worktree, after the worktree session has ended. One worktree holds one live session.
- Run `/review-staged <effort> <base>...HEAD`. The base is `main`, or the parent branch for a stacked MR. Name the session doc in the prompt, so that the review checks the spec.
- The review keeps the session doc's file list. A fix that needs another file stops the review, as in rule 3.
- The review commits on the branch under rule 8, and updates the doc's as-built part when a fix changes it. It does not rewrite history to regroup commits that are already made.
