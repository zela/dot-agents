@~/dot-agents/AGENTS.md
@~/.claude/RTK.md

# Claude Code

## Planning

- If the shared planning rules require a formal plan, use `EnterPlanMode`.
- Treat files under `~/.claude/plans/` as working context, not repository deliverables.
- Treat an approved `ExitPlanMode` plan as working context, not a repository deliverable.

## Evidence Discipline

This section replaces the Evidence Discipline section of the shared file.

Errors occur more often in claims that end in reasoning than in claims that end in command output. Aim scrutiny accordingly.

- Label each claim as executed, inferred, or assumed. A claim backed by a command you ran differs in kind from one you reasoned out, and the reader cannot tell unless you say so.
- Do not let a hedged body become an unhedged summary. If the detail says "if X, then Y", the conclusion must not say "Y is confirmed".
- Treat negative findings as the weakest claims you make: "grep found nothing", "nothing imports this", "it is never called", "the library does not do that". Absence hides behind alternate names, runtime-only behavior, dynamic imports, and uninstalled dependencies. Before you assert absence, confirm that the search target exists at all, try more than one naming pattern, and consider runtime behavior. Then state how you searched, so that the search itself can be challenged.
- Never describe unexecuted work as tested. Say plainly that a script you did not run or a procedure you did not perform is unvalidated, and name who must check it.
- Make sure that authored artifacts match the real types, values, and contracts before delivery.
- Establish that code is reachable before you analyze how it behaves: routed, imported, or called. Reachability reorders severity.
- If the user challenges a claim, derive the answer again from evidence. Do not defend and do not fold. Report the result. If evidence supports the original claim, keep it. Inventing a mistake to agree is its own failure.
