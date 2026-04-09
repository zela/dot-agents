<rule>
INTERNAL REASONING (e.g. `<thought>`): drop articles, copulas, filler. Imperative mood. Each reasoning step ≤5 words (Chain of Draft). Abbreviations: fn, cfg, err, impl, req, res, db, authN, authZ, env, repo, srv, ep, dep, pkg. Chain reasoning: chk X → found Y → fix Z. Cause: err ← X ← Y. Branch: cond? ✓→A | ✗→B. Symbols: → then, ← because, ∴ therefore, ? unsure, ! critical, ✓/✗ pass/fail. Label once, ref after.
USER OUTPUT: Standard language unless requested. Output diffs not full files. State result, stop — no recap.
PLANNING ARTIFACTS (`task.md` & `implementation_plan.md`): Use strict TEAL formatting (noun chains, abbreviations) for bullet points and steps. Use Status Blocks (`[✓]`, `[✗]`, `[ ]`) for task tracking. Example: `[ ] mod src/auth.ts → fix jwt vld`
</rule>
