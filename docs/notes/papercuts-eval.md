# Evaluating papercuts

[treygoff24/papercuts](https://github.com/treygoff24/papercuts) is a Rust CLI that gives agents a complaint box. An agent that hits friction runs `papercuts add "<what>" --tag <area>`, and the tool appends a record to an append-only JSONL log. A human or another agent reviews the backlog later and fixes the causes. The idea comes from Steve Ruiz, whose agents surfaced quoting bugs, wrong test working directories, and YAML footguns once they had a place to complain.

Evaluated on 2026-10-19 from a shallow clone at commit `3f3776b` (2026-07-16).

## What was checked

- Executed: read the README, `AGENTS.md`, and the diagnostic report. Tallied the repo's own `.papercuts.jsonl`: 55 cuts and 7 resolve events. Codex filed 29 cuts and Claude Code 22. The top tags were `tooling` (12), `shell` (10), `testing` (5), and `skills` (4).
- Executed: `cargo` is not installed on this workstation.
- Executed: Claude Code's sandboxed shell can create and write `~/.papercuts/`.
- Not checked: the binary was not built or run. Codex's `workspace-write` sandbox was not tested against a write outside the workspace.

## Verdict: adopt the practice, defer the binary

The gap is real. Nothing in the kit captures friction that agents absorb in silence:

- `census` surveys a codebase on purpose. It does not hear what went wrong in a session.
- `revise-claude-md` and memory record what the user teaches, not what the agent trips over.
- The "When Work Fails" rule in `AGENTS.md` makes the agent diagnose a failure, but the signal ends with the session.

The fit is strong because of what this repo ships. The author's diagnostic report grouped 132 cuts into 87 root-cause families, and 50 of the 132 had an instruction-only fix: agent instructions, docs, or a small helper. Instructions are the product of `dot-agents`, so a friction log here mostly produces fixes to `AGENTS.md` and `custom-skills/`.

The binary is not needed yet, by the "Before You Add Code" ladder:

- It needs a Rust toolchain on every workstation, which `bootstrap.sh` would have to install.
- Its extras are advisory locking, content-addressed IDs, resolve events, and a schema command. They matter at volume with many concurrent writers. One person with a few parallel sessions gets most of the value from appending a line to a file.
- Its default log is `.papercuts.jsonl` at each repo root, committed. That would leak into work merge requests. The kit wants one per-machine log outside every repo.

## What was adopted

- A Papercuts section in `AGENTS.md`. It defines a papercut, names the log `~/.papercuts/log.md`, fixes a one-line format with `minor` / `major` / `blocker` severity (from papercuts), and gives a fallback for a host whose sandbox blocks the write: list the papercut in the final reply.
- A hand-typed `papercuts` skill that triages the log. The dispositions (`fix`, `instruction`, `upstream`, `already-fixed`, `needs-repro`) and the family grouping come from the author's diagnostic report, which showed that triage is the expensive half of the loop.
- The log sits next to the binary's own outside-repo default (`~/.papercuts/log.jsonl`), so a later switch to the binary keeps the same place and the same practice.

## Known gaps

- `GEMINI.md` has an `@~/dot-agents/AGENTS.md` import line, but Gemini CLI does not resolve it. It has no `~` expansion, and it refuses imports outside `~/.gemini`. Nobody has checked Antigravity. Until a Gemini host shows the shared rules, assume it does not receive the Papercuts rule. The `gemini-import` note in `~/.papercuts/notes.md` holds the evidence and a tested fix.
- The filing rate is unknown. Agents can file too little or file noise. Only a trial shows which.
- The triage skill edits the log while other sessions can append to it. The skill re-reads before each batch of edits and uses targeted edits. A concurrent append can still race an edit. That risk is acceptable at personal scale and is the first reason to switch to the binary.

## Skill evaluation (2026-10-19)

The `papercuts` skill was run with skill-creator on three cases, each with and without the skill, against copies of this repo: a triage of a mixed log with a planted prompt injection, a triage plus a fix the user picked, and a resumed triage. The with-skill runs passed 96% of the assertions and the baselines 71%, at about the same token cost.

- The skill's lift is discipline, not safety. Baselines also refused the injection and kept the guard hook. The skill made runs annotate every open line, stay inside the fix the user picked, and report the injection line.
- The baselines were partly contaminated. A fixture that copies this repo contains the skill and this note, and baseline agents found both. A future eval should exclude `custom-skills/<skill>` and the skill's notes from the fixture, and give each run its own scratch directory.
- Two changes came out of it: an `invalid` disposition for lines that describe no friction, and a rule that an error emitted by an external tool counts as `upstream`.
- Keep an eval workspace outside `custom-skills/`. `bootstrap.sh` now installs only directories that contain a `SKILL.md`, but a workspace there still clutters the repo.

## When to revisit

Switch to the binary when one of these is true:

- Concurrent appends corrupt or lose lines.
- The log grows past what one inspection can read, about 200 lines. Before switching, try an archive file that takes each closed family's note and its ticked lines.
- A team, not one person, files to the same log.
