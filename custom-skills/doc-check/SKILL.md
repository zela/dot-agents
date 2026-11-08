---
name: doc-check
description: Check plan session docs against the current code before a session implements them, with one read-only agent per doc. Finds stale references, acceptance checks that cannot run or cannot fail, unmarked tool claims, contradictions and incomplete file lists. Use before you launch a session or a wave of parallel sessions, after a grill changes a session doc, or when the user says "doc check".
---

# Doc check

A grill finds wrong decisions. A doc check finds wrong facts: about the code, the scripts and the tools, which the previous session can make wrong. It edits no code, and it changes a doc only through step 5.

## Steps

1. **Scope.** Name the session docs to check, and for each one the docs it must agree with (the plan overview or umbrella doc, the contracts, the ADRs, the decisions log). Run against committed state: commit each grill's doc first. Note the base commit (`git rev-parse --short HEAD`). Done when every doc has its list and the tree is clean for those docs.
2. **Dispatch.** Start one read-only subagent per session doc, all in parallel. Give each one:
   - the doc path, the docs it must agree with, and the base commit;
   - § Checks and § Secrets below, copied verbatim;
   - the output format: one finding per line, with a severity from § Severity, the doc line, `file:line` evidence, and "checked" or "inferred";
   - the limits: edit nothing; run only local, free, read-only commands (`--help`, a dry run, a grep); never a deploy, a remote write, a paid run or a command that changes the tree.
3. **Spot-check.** Re-read the cited code for every blocker and every harm finding yourself. Mark each one **spot-checked** or drop it. Merge a finding that two or more agents report into a cross-cutting section.
4. **Record.** Write the report where the project keeps evidence (`docs/evidence/<plan>-doc-check.md` unless the project names a place). Start it with the base commit, the docs checked and the severity legend. Then the cross-cutting findings, then one section per doc.
5. **Fix the fix-worthy findings.** These are the fix-worthy kinds:
   - a **blocker**;
   - a **wrong** fact that would mislead a session or a release;
   - a **harm** finding;
   - when sessions run in parallel, a missing file in a file list, and a file that two docs list without a hotspot entry. Each one makes a session stop and ask, or makes two branches collide.

   Ask the user for each fix that needs a decision. Leave every other finding in the report: the session re-reads each line before it edits it, and adds refusal cases when it writes its tests. Each detail you add to a doc is one more thing the next check can find wrong. Commit the fixes when the project's procedure or the user says so.
6. **Re-check.** Run the check again only on a doc whose fix changed a task or an acceptance item, and only on the changed lines plus the lines they reference. Stop when a pass finds no fix-worthy finding. A check always finds something, so a count of findings is not a stop signal.

For a single sequential session, or a wave of two or three docs: one full pass in step 2, then line-scoped passes in step 6.

## Checks

- **References.** Each `file:line` still points at the code that the doc describes.
- **Commands.** Each acceptance command runs as written against the current scripts. Read the script: an inline variable overrides the caller's (`TENANT=x` inside the script beats `TENANT=y pnpm …`), a `--filter` changes the working directory for relative paths, and a positional argument can be missing.
- **Can fail.** Each acceptance item names an input that makes it fail. A check that passes without the change is harm.
- **Refusals.** The acceptance names the wrong inputs that the code must refuse, not only the inputs that must pass.
- **Tool claims.** Each claim about how a tool or a library behaves is marked checked, with a date or a source, or inferred. A task that depends on an inferred claim has a probe step before any edit.
- **Consistency.** The doc does not contradict itself, the docs it must agree with, or a fixed contract.
- **File list.** Trace each task to the code it changes and derive the files from that trace. Do not only confirm the listed files. Include:
  - the callers of each function, type or export that the task changes;
  - the tests and snapshots to update;
  - generated files and script registries;
  - the place where the session's outputs go: evidence, screenshots, reports.

  Every file that a task edits is in the list.
- **Overlap.** For parallel sessions: each file that another doc of the wave also lists is a hotspot in the join doc, or one doc gives it up.

## Severity

- **blocker**: a task or an acceptance item cannot be done as written.
- **wrong**: a fact is wrong, and the work can proceed.
- **harm**: a step that can cause harm, or a check that can pass without testing anything.
- **gap**: a missing refusal case, file, hotspot or claim marker.
- **drift**: a `file:line` that moved.

## Secrets

Read no secrets file: `.env*`, `.dev.vars*`, credential files, key stores. A command that prints only part of each line still prints a whole line when that line is not in the expected form. If key names matter, read them from the example file, from the code that reads them, or ask the user.
