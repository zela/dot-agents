---
name: run-state
description: >-
  Execute a long-horizon, many-step procedural task (bulk migration, backlog processing, a long mechanical refactor, a runbook) by keeping all durable progress in an external state file instead of the conversation history. Context then stays bounded, any step can be re-read cold, and the session can be /clear'd and resumed without losing the thread. Use when a repetitive multi-step run keeps ballooning context or spans sessions. Not for one-shot changes (just do them) or forward planning (see multi-session-plan).
---

# Run-state

Drive a long procedural loop where the enemy is **context**, not difficulty. Instead of appending every step to the conversation. That history grows quadratically and starts to poison itself around step 30. You keep one **external state file** as the single source of truth. Each step reads the spec + the state + the latest result, does the next unit, writes a small **patch** to the state file, and discards the reasoning. Progress lives in the file, so the context never has to.

The payoff: you can `/clear` between batches (or resume next session) and pick up cold from the file alone, with no accuracy cliff as the run gets long.

## Where this fits

- `multi-session-plan` authors the **roadmap** — what to build, in what order. Forward-looking. It does not execute.
- `census` keeps a read-only **survey ledger** of standing findings.
- **run-state executes**. It is the engine that chews through a long, homogeneous worklist while holding context flat. Often you plan with `multi-session-plan`, then execute one heavy session with run-state.

Use it when the work has all three properties: Many similar steps (dozens to hundreds of call sites, files, records, backlog items). Mechanical enough that scrollback is dead weight. Long enough that context poison or a mid-run `/clear` is a real risk.

Do not use it for a one-shot edit (the ladder says just do it), for genuinely novel per-step reasoning where history *is* the value, or to write a plan (that is `multi-session-plan`).

## The shape

Three things in the model's context at any step — nothing else durable:

1. **The immutable spec**. This is the procedure, written once, never edited mid-run. Usually a short doc: the steps, the invariants, the acceptance check. If it does not exist yet, write it first (or point at the `multi-session-plan` doc that already is it).
2. **The current state file** — mutable, structured, the single source of truth. Use [assets/state-template.md](assets/state-template.md): invariants, cursor, a ledger row per unit, decisions, blockers, done-when.
3. **The latest observation** — the result of the step you just ran (test output, the diff, the file you just read).

## The loop

Per unit of work:

1. **Read** the spec + state file. Not the scrollback. Read the file. If you are resuming cold, this is *all* you get, and that is the point: if the file cannot tell you the next move, the file is underspecified. Fix it.
2. **Act** on `Cursor → Next unit`. One unit. Do not batch five ahead in your head.
3. **Patch the state file**. This is the only durable output. Flip the ledger row (`·` → `✓`/`⊘`/`⚠`), advance the cursor to the next unit, record any decision a later step depends on, if stuck, log a blocker. Keep patches small and the file well-formed. A malformed state file is the one failure that breaks resumption.
4. **Discard the reasoning.** Whatever you thought to get here does not go in the file — only the outcome does. The next step re-derives from state, not from your train of thought.
5. At a natural batch boundary, **stop and offer `/clear`.** That is the moment the pattern pays off: durable state is on disk, so dropping the context costs nothing and the next batch starts lean.

## Rules that keep it honest

- **The file is the truth, the chat is scratch.** Never let a fact live only in the conversation. If a later step needs it, it goes in the state file *now*. The test: can a fresh session with zero history finish the run from this file? If not, the file is lying by omission.
- **One unit, one patch.** Do not do three units and then update once. A crash or `/clear` mid-batch loses the untracked two. Update after each.
- **Invariants are re-asserted, never re-derived.** They sit at the top of the file so every step re-reads them instead of reconstructing them from history (where they rot).
- **Blocked is a status, not a stop.** A unit that cannot proceed becomes `⚠` with what can unblock it, and the cursor moves on. Do not stall the whole run on one wedged item. Surface it and continue.
- **Do not commit unless asked.** The state file and the work sit uncommitted. Committing is the user's call, in this session, explicitly. Same rule the rest of the kit follows.
- **Match the codebase.** Per-step edits follow existing conventions. run-state governs the *loop*, not the code style. Make sure that each unit passes the project's gates (the `Done when` check names them).

## Scale it down

A 12-item run does not need ceremony: the state file can be a single ledger table in a scratch doc, and "the spec" can be one sentence at the top. The discipline that matters at every size is the same. **Outcome to the file after each unit, reasoning discarded, next step re-derived from the file.** Reach for the full template only when the run is long enough that you will actually `/clear` partway through.

## The core, if you remember nothing else

**Keep durable progress in an external state file, not the conversation. Read spec + state, do one unit, patch the file, drop the reasoning, repeat. `/clear` freely at batch boundaries because the file, not the context, is carrying the run.**

---

<sub>Pattern adapted from *SKILL.state: Scalable Long-Horizon Agent Skills* (Badhe, Tiwari, Chung — [arXiv:2608.26263](https://arxiv.org/abs/2608.26263)): explicit mutable state over append-only history, bounded prompt, reasoning discarded per step. The paper implements this in the agent runtime with grammar-constrained state patches; run-state applies the same idea at the skill layer, where the "grammar" is a markdown template and the "runtime" is you plus `/clear`. See [docs/notes/skill-state-and-the-ledger-pattern.md](../../docs/notes/skill-state-and-the-ledger-pattern.md).</sub>
