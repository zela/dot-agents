# Parallel sessions in worktrees

How sessions run in worktrees in this repo. The procedure is the `parallel-sessions` skill: its rules for a worktree session, its review, and its `coordinator.md`. Load it with this doc. This doc gives the project's values and the rules that apply only here. Rule numbers are the skill's.

## Roles

- **Primary checkout.** `<absolute path>` on `main`. Wave preparation, every join and every deploy run here. Only this checkout has `<gitignored and git-excluded state: secrets, env files, caches, local data, local instruction files>`.
- **Session docs.** `<path pattern>`. The plan's overview is `<path>`. Each wave's join doc is `<path pattern>`.
- **Merge path.** `<A local join in the primary checkout (coordinator.md § Local join) | MRs that the user merges (coordinator.md § MRs that the user merges)>`.

## Before a wave

Follow `coordinator.md` § Before a wave. The doc check's inputs:

- Each doc must agree with `<the overview, the fixed contracts, the ADRs>`.
- The report goes to `<path>`.

## Rules for a worktree session

The project's values for the skill's rules:

- **Rule 2.** Name the branch `<pattern>`, for example `<example>`.
- **Rule 3.** Evidence goes under `<path>`.
- **Rule 4.** The shared docs: `<list>`.
- **Rule 5.** The fixed contracts: `<list or path>`.
- **Rule 6.** A migration is `<the project's kind>`.
- **Rule 7.** The remote systems: `<list>`.
- **Rule 8.** `<The user granted commit approval on YYYY-MM-DD for the session's own branch only | No grant: ask before each commit>`. Commit style: `<the repo's style>`.
- **Rule 10.** The Status line: `<format>`.

Rules that apply only here:

- `<rule>`

## Review

Follow the skill's § Review. The base is `<main, or the parent branch for a stacked MR>`.

## Running a worktree

- **Create.** From the primary checkout: `git worktree add ../<repo>-<slug> -b <branch> main`.
- **Set up.** The user runs `<setup command>` once, from inside the new worktree. `<What it links, installs and prepares.>`
- **Start.** `<launch command, for example claude, or claude --add-dir <primary>/docs>` in the worktree.
- **Secrets.** `<the secrets files, and the guard that blocks the tools on them>`.
- **Ports.** `<the slot scheme, or the one port that reaches the shared backend>`.
- **Stopping a dev server.** `<the project's stop command, and the pattern that a pkill would also match>`.
- **Caches.** `<caches that only the primary has, and the checks that read them>`.

## Join

Follow `coordinator.md` § `<Local join | MRs that the user merges>`, with these values:

- The checks command is `<command>`.
- The markers to set: `<overview rows>`.
