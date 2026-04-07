1. The Dynamic Dictionary (Iterative Refinement)

To ensure the dictionary doesn't stagnate or cause collisions as you work on different projects, we shouldn't hardcode it all into a single massive prompt. Instead, we can use Antigravity's filesystem awareness.

- Create a teal-dict.json or TEAL_DICT.md: Store this in your dot-agents.
- Create a teal-manager Skill: Create a skill that Antigravity can call (in /Users/amo/dot-agents/custom-skills/teal-manager/SKILL.md). This skill would have instructions like:
  Instruction: "Whenever you encounter a structural conflict in reasoning, or find yourself repeatedly typing a long domain-specific phrase, propose an addition to TEAL_DICT.md."
  This allows the framework to dynamically adapt to the specific codebase (e.g., if we are working on a React app, we add cmp for component, ctx for context).

2. Multi-Agent / Third-Opinion Handoffs

Antigravity has access to the third-opinion skill (consulting Claude or Copilot via CLI). When Antigravity formats the prompt to send to that sub-agent, it should use the TEAL "Agent-to-Agent Protocol":

- Instead of: "I am trying to fix a bug in the database connection pool, here is the error..."
- Antigravity sends: err db_pool!conn. repro: GET /api/data. req third-opinion → optimal retry+backoff impl?
