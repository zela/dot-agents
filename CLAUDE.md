@~/dot-agents/AGENTS.md
@~/.claude/RTK.md

# Claude Code

## Planning

- If the shared planning rules require a formal plan, use `EnterPlanMode`.
- Treat files under `~/.claude/plans/` as working context, not repository deliverables.
- Treat an approved `ExitPlanMode` plan as working context, not a repository deliverable.

## Subagent models

The `model` parameter of the Agent call sets the model of the subagent. When you omit it, a built-in agent uses the main model. A fork always uses the main model.

For these tasks only, spawn `general-purpose` with `model: "sonnet"`:

- One part of a parallel implementation, with a clear spec for that part
- A test-suite run or a smoke run

If this subagent changes files, read its diff before you report the result.

For every other subagent, omit `model`. An eval run must use the main model, because the eval measures that model.
