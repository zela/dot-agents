# Reading the scores

`scripts/check-changed.sh` runs [crapper](https://github.com/unclebob/crapper) and [dryer](https://github.com/unclebob/dryer) on the TypeScript and JavaScript source files that changed. It skips test files and `.d.ts` files. It does not score `.astro` components or Python.

## Before you run it

- The script runs the tests related to the changed files (`vitest run --changed`). If those tests take minutes in this project, ask the user first. Under `AGENTS.md`, that run is a heavy operation.
- The script installs nothing. For coverage, it needs `node_modules/.bin/vitest` and `@vitest/coverage-v8` or `@vitest/coverage-istanbul`. Without them, it scores complexity only. Say so in the Right note. Name the dev dependency that the user can add.
- The script writes `coverage/craft/` and `.metrics/`. Both are generated output. Keep them out of every commit.
- Exit 3 means that crapper or dryer is not on `PATH`. Give the user the lines that the script prints. Then do the other Right items by hand. The user installs the tools.
- A warning about other `lcov.info` reports means that crapper merges them into its scores. As a result, the scores can be stale. Name the files to the user. The user decides whether to remove them.

## CRAP

`CRAP = CC² × (1 − coverage)³ + CC` for each function, where CC is the cyclomatic complexity. The table shows every function in a changed file, so it also shows functions that you did not touch.

- If a function that you added or changed scores 10 or more, split it, test it, or do both. A test is often the cheaper fix, because at full coverage CRAP equals CC.
- If a flat `switch` or lookup with many cases scores high, it can still read well. Leave it, or turn it into a lookup table if that is clearer. Say which in the Right note.
- If an untouched function scores 10 or more, name it in the Right note as existing debt. Leave it as it is. The ratchet is that changed code never gets worse. Standing debt belongs to `census`.
- If no test reaches a changed file, its coverage is 0%. That score is the finding, not a tool error.
- If coverage is N/A, the table shows complexity only. A changed function with a CC of 10 or more is still a candidate for a split.

## Duplicates

Each pair scores 0.82 or more (the dryer default) and has at least one side in a changed file. The score compares structure. It ignores names, literals, and locals.

- Open both sides before you act. A pair is a lead, not a fact.
- If the changed side repeats an existing function, call or extend the existing function.
- If both sides changed, extract the shared part.
- If the two sides share a shape but encode different decisions, leave them. Two validators for different inputs are an example. Give the reason in the Right note. A wrong abstraction costs more than a coincidental copy.
