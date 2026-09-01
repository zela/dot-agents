# SKILL.state and the ledger pattern

Notes on *SKILL.state: Scalable Long-Horizon Agent Skills* (Badhe, Tiwari, Chung — Google / Purdue), [arXiv:2608.26263v2](https://arxiv.org/html/2608.26263v2), and what it means for this kit.

## The paper in one paragraph

LLM agents on long procedural tasks accumulate the whole conversation, so tokens grow O(T²), context poisons itself, and accuracy falls as the horizon extends. SKILL.state replaces the append-only history with an **explicit mutable state object**: each step the model sees only the immutable procedure spec + the current structured state + the latest observation, emits a validated *state patch*, and the intermediate reasoning is discarded. Prompt size stays O(1)-bounded, tokens grow O(T). Their evals (self-reported, two narrow benchmarks) claim ~16× fewer tokens at T=100 with 0.94 accuracy, +7.8pts on InterCode CTF at 60% fewer tokens, and — the most interesting result — robustness to context poisoning: 0.97 accuracy under 50 irrelevant events/turn where the append-history baseline collapses to 0.53.

## Why it's not new to us

The core move — externalize state, keep the prompt small, re-derive from the file not the scrollback — is the principle several skills here already run on:

- **`census`** keeps a *reconciled ledger* under `docs/census/` and re-takes the count across sessions (verify done / refresh drifted / retire dead). That's SKILL.state's mutable-state-over-history thesis applied to review findings — the paper is close to a formal writeup of what census does operationally.
- **`multi-session-plan`** / **`ship-session`** — docs updated in place across sessions, not a growing log.
- **CLAUDE.md → Context Hygiene** — `/clear` at task boundaries, `/compact` at phase transitions, one session per ticket. The manual version of a bounded prompt.

So the paper's value to us is mostly **validation**: the direction these skills already point is the one with the theory behind it. The strongest single takeaway is the noise-robustness result — it's the concrete argument for pushing *more* workflow skills toward "write state to a file, re-read the file" instead of trusting conversation memory.

## What we did with it

Added the **`run-state`** skill — the one gap the existing skills didn't cover. census *surveys* (read-only), multi-session-plan *plans* (forward-looking), but nothing *executed* a long homogeneous worklist while holding context flat. run-state is that engine: read spec + state, do one unit, patch an external state file, discard the reasoning, `/clear` freely at batch boundaries. It's SKILL.state at the skill layer — where the paper's grammar-constrained patch decoding becomes a markdown template, and the runtime is the operator plus `/clear`.

## What we deliberately didn't do

The paper's actual mechanism is an **agent-runtime** concern: grammar-constrained decoding, framework-level state validators, patch schemas enforced in the loop. We don't own the Claude Code loop, so we can't adopt the mechanism — only the design pattern at the skill layer. No dependency, no framework. If a future runtime exposes structured-state primitives, revisit; until then the markdown-template-plus-`/clear` approximation is the whole of what's actionable here.
