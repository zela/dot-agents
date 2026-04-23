1. The Dynamic Dictionary (Iterative Refinement)

To ensure the dictionary doesn't stagnate or cause collisions as you work on different projects, we shouldn't hardcode it all into a single massive prompt. Instead, we can use Antigravity's filesystem awareness.

- Create a teal-dict.json or TEAL_DICT.md: Store this in your dot-agents.
- Create a teal-manager Skill: Create a skill that Agentic Coder can call (in /Users/amo/dot-agents/custom-skills/teal-manager/SKILL.md). This skill would have instructions like:
  Instruction: "Whenever you encounter a structural conflict in reasoning, or find yourself repeatedly typing a long domain-specific phrase, propose an addition to TEAL_DICT.md."
  This allows the framework to dynamically adapt to the specific codebase (e.g., if we are working on a React app, we add cmp for component, ctx for context).

2. Multi-Agent / Third-Opinion Handoffs

Antigravity has access to the third-opinion skill (consulting Claude or Copilot via CLI). When Antigravity formats the prompt to send to that sub-agent, it should use the TEAL "Agent-to-Agent Protocol":

- Instead of: "I am trying to fix a bug in the database connection pool, here is the error..."
- Antigravity sends: err db_pool!conn. repro: GET /api/data. req third-opinion → optimal retry+backoff impl?

3. Empirical Validation of Reasoning Compression

Previous reports stated that TEAL's core claim (reasoning/thinking token compression) was untestable and false because models like Claude don't expose or apply instructions to internal thinking blocks.

Recent `teal_benchmark.py` runs on Gemini (e.g., `gemini-2.5-flash`) disprove this limitation:

- Gemini explicitly exposes `thoughts_token_count` via its API metadata.
- Our A/B test demonstrated a **55.1% reduction** in thinking tokens (from 3,574 down to 1,606) when TEAL instructions were provided.
- This proves that TEAL **does** successfully compress internal reasoning and structural logic on models that support extended thinking, leading to substantial latency improvements (up to 70% faster response times).

TEAL probably needs either (a) much more aggressive reinforcement in CLAUDE.md, (b) explicit "respond in TEAL" per-message, or (c) \*\* **acceptance that it works best for structured subtasks (bug investigation, decision trees, handoffs) rather than as a universal reasoning style.**
