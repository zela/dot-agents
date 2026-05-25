---
name: complexity-optimizer
description: Find algorithmic complexity hotspots in a codebase — nested loops, repeated scans, N+1 queries, render-time recomputation, avoidable O(n²) — and either report them or implement safe fixes. Use when the user asks to audit/scan/profile for performance, find hotspots, reduce complexity (e.g. "O(n²) → O(n log n)"), or eliminate N+1 queries. Do NOT use for general code review or refactoring — see code-review or simplify for those.
---

# Complexity Optimizer

## Default: report-only, no edits

When the user asks to **analyze, scan, audit, review, or report** — produce the report. Do not modify files.

Only edit when the user asks to **implement, fix, optimize, apply, refactor, or change**.

## Workflow

1. **Run the scanner** for a fast first pass on repo-scale scans:
   ```bash
   python3 scripts/analyze_complexity.py <repo> --format markdown
   ```
   Treat output as leads, not proof. False positives are expected. For small/known scopes, skip the scanner and read the code directly.

2. **Rank by impact.** Hot paths, large inputs, render loops, DB/API loops, shared utilities first. Separate true algorithmic wins from constant-factor cleanup.

3. **Report.** For each finding: `file:line`, current pattern, estimated current complexity, proposed change, complexity after, risk, and what test/benchmark proves correctness.

4. **If implementing:** confirm tests exist (or add them) covering edge cases — empty input, duplicates, ordering, nulls, mutation side effects. Make the smallest change. Run tests + lint/build. Report before/after complexity and residual risk.

## Safety checklist before editing

- Input sizes large enough for complexity to matter? (Don't optimize 10-element loops.)
- Does the change preserve **output ordering, object identity, and mutation semantics** callers may rely on?
- For DB batching: does it preserve **auth, tenant, soft-delete, pagination, filters**?
- For caches: is there a valid invalidation strategy?

## Common transformations

- Nested lookup loops → build a map once: `O(a·b) → O(a+b)`
- `.includes()` / `in list` inside a loop → Set/dict membership
- Sort inside a loop → sort once outside, or use a heap
- Pairwise comparisons → sort + two pointers, sweep line, or hash bucketing
- Render-time derivation → memoize, move to selector/server, virtualize long lists
- N+1 queries → bulk fetch by IDs, joins, dataloader, batched endpoints

## What not to do

- Don't replace clear linear code with complex structures for tiny inputs or cold paths.
- Don't change public ordering unless tests prove it's irrelevant.
- Don't add a cache without an invalidation strategy.
- Don't trade O(n) for O(n log n) unless it unlocks a larger win.
