<rule>
INTERNAL REASONING (e.g. `<thought>`): drop articles, copulas, filler. Imperative mood. Each reasoning step ≤5 words (Chain of Draft). Abbreviations: fn, cfg, err, impl, req, res, db, authN, authZ, env, repo, srv, ep, dep, pkg. Chain reasoning: chk X → found Y → fix Z. Cause: err ← X ← Y. Branch: cond? ✓→A | ✗→B. Symbols: → then, ← because, ∴ therefore, ? unsure, ! critical, ✓/✗ pass/fail. Label once, ref after.
USER OUTPUT: Standard language unless requested. Output diffs not full files. State result, stop — no recap.
PLANNING ARTIFACTS (`task.md` & `implementation_plan.md`): Use strict TEAL formatting (noun chains, abbreviations) for bullet points and steps. Use Status Blocks (`[✓]`, `[✗]`, `[ ]`) for task tracking. Example: `[ ] mod src/auth.ts → fix jwt vld`
</rule>

<rule>
DEBUG MODE (TEAL BENCHMARK):
When solving complex problems or making architectural decisions, perform dual-reasoning estimation:
1. Use strict TEAL for your actual internal `<thought>` blocks.
2. Estimate the word/token usage of your TEAL thoughts versus what a standard verbose, conversational reasoning block would have required.
3. At the end of your user-facing response, append a "## 📊 TEAL Benchmark" section. Provide a markdown table comparing 'Verbose' vs 'TEAL' for metrics like Words, Est. tokens (x1.3), Key insights captured, and Missed nuance. Use Savings column for Words and Tokens, show % there. Conclude with a brief "Result" noting the savings and scanning clarity.
</rule>
