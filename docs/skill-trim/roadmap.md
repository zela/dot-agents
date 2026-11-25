# Skill trim — Roadmap

> Work that follows the seven sessions. Detail an item into a session doc when it is picked up.

## In-scope decisions that keep later work cheap

- R8 keeps the source and version in each `<sub>` line, so an upstream comparison knows its baseline.
- R4 puts branch material in sibling files, so a later split or merge of skills moves files, not paragraphs.

## Later

1. **Upstream comparison, from time to time (D1).** For each adapted skill, read the upstream changes since the version in its `<sub>` line. Take what improves ours; update the version. Sources: `mattpocock/skills` (`domain-modeling`, `diagnosing-bugs`, `prototype`, `resolving-merge-conflicts`, `design-it-twice` vocabulary), `AminBlg/SimpleEnglish`, `EveryInc/compound-engineering-plugin` (`wtf`). A candidate for a `schedule` routine.
2. **Shared "read the context first" preamble.** `craft:10`, `diagnosing-bugs:10` and `multi-session-plan:44` each tell the agent to read `CONTEXT.md`, ADRs and matching lessons. One line in `AGENTS.md` could own it. Decide after Sessions 03 and 07, when the three copies are final.
3. **One verifier-fallback file.** `census` and `review-mr` each carry a fallback for hosts without a `verifier` agent. If the two copies match after Sessions 04 and 05, consider one shared location.
4. **`.DS_Store` in deployed skills.** `bootstrap.sh` copies skill folders with `cp -a`, so Finder files deploy. Git ignores them (`.gitignore:1`). Low priority; an exclude in the copy step would fix it.
5. **Trim the vendored upstream skills.** `tdd`, `research`, `writing-for-agents` and other skills outside `custom-skills/` were not reviewed.
