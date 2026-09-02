# The flow the skills form

These skills aren't a loose bag of tools — they trace one development lifecycle, and they're wired together by a single idea: **durable state lives in `docs/`, not in the conversation.** Each phase reads the artifacts the previous phase wrote and leaves its own behind, so any session can `/clear` and resume cold. That's [SKILL.state](skill-state-and-the-ledger-pattern.md) generalized past one skill to the whole kit — the document tree is the bounded, reconciled state; the chat is scratch.

## The spine

```mermaid
flowchart LR
  subgraph U[1 · Understand]
    sdm[system-design-mentor]
    grill[grill-me]
    t3[third-opinion]
  end
  subgraph D[2 · Design]
    daf[design-a-feature]
    dai[design-an-interface]
    viz[archify · beautiful-mermaid]
    dr["decision-record → docs/adr/"]
  end
  subgraph P[3 · Plan]
    msp[multi-session-plan]
  end
  subgraph B[4 · Build / Execute]
    rs[run-state]
    co[complexity-optimizer]
    apprun[run*]
  end
  subgraph R[5 · Review]
    cr[code-review*]
    sim[simplify*]
    sec[security-review*]
    rst[review-staged]
    rmr[review-mr]
    cen[census]
    cec[cross-engine-check]
    ver[verifier*]
  end
  subgraph S[6 · Ship]
    ship[ship-session]
  end

  U --> D --> P --> B --> R --> S
  R -. re-open .-> B
  S -. next session .-> P
  cen -. reconcile across sessions .-> cen

  classDef doc fill:#e8f0fe,stroke:#4285f4,color:#111;
  class msp,rs,cen,ship,dr doc;
```

<sub>`*` = platform built-ins the kit composes with, not custom skills. Dotted edges are the loops that make the kit stateful rather than one-shot.</sub>

## Phase by phase

**1 · Understand — is this the right problem, and do I actually get it?**
`system-design-mentor` teaches the trade-off space; `grill-me` interrogates a plan until every branch is resolved; `third-opinion` cross-checks against another model. Output is comprehension — not yet a doc, but the input to one.

**2 · Design — what shapes could this take?**
`design-a-feature` / `design-an-interface` hold the task stable and vary the interaction/module shape, so you choose from real alternatives instead of the first idea. `archify` / `beautiful-mermaid` render the chosen shape. This is where a *decision* gets made — and `decision-record` captures it as an ADR under `docs/adr/`, so the choice (and what would prove it wrong) outlives the chat.

**3 · Plan — sequence it.**
`multi-session-plan` turns the chosen design into linked docs under `docs/`: an index, one doc per session, a deferred-work roadmap. This is the first durable state the build will read back.

**4 · Build / Execute — do the work with context held flat.**
`run-state` executes a long homogeneous run (migration, backlog, mechanical refactor) against an external state file, so context stays bounded and the session can be `/clear`'d mid-run. `complexity-optimizer` fixes perf hotspots inline. Both read the plan doc; run-state writes its own state file. `/run` (native) launches the real app to confirm a change works when *run* — the one step that exercises the built thing, not just the tests.

**5 · Review — is it safe, and what standing debt remains?**
Two altitudes. **Diff-scoped:** `code-review` gates a change on correctness and quality, `/simplify` (native) does the quality-only pass without the gate, `/security-review` (native) adds the security lens the custom kit otherwise lacks, `review-staged` triages what's staged, `review-mr` formats findings as MR comments, `cross-engine-check` verifies a CSS claim across engines, `verifier` re-checks a single claim cold. **Repo-scoped:** `census` surveys the whole standing codebase and keeps a reconciled ledger under `docs/census/` — the one review artifact that persists and gets re-taken across sessions.

**6 · Ship — close the session honestly.**
`ship-session` verifies the acceptance gates, converts the plan doc from forward-plan to as-built reference, trims the index to the truth, and commits. It hands the baton back to Plan for the next session.

## Native built-ins the kit composes with

The custom skills don't replace Claude Code's own dev-flow commands — they wrap and sequence them. Four native skills slot straight into the phases (marked `*` in the spine):

- **`/run`** (Build) — launches and drives the real app to confirm a change works when run, not just when tests pass. The custom kit is doc- and test-centric; this is the one step that exercises the built thing.
- **`/code-review`** (Review) — the correctness-plus-quality gate on a diff. `review-staged` and `review-mr` are the host-specific, stateful wrappers around this job; `/code-review` is the bare gate.
- **`/simplify`** (Review) — the quality-only pass: reuse, simplification, efficiency, altitude. It does not hunt for bugs — it's the cleanup half of `/code-review` on its own, for polish without the gate.
- **`/security-review`** (Review) — a security lens on the pending diff. Nothing in the custom kit is security-specialized, so this sits next to `code-review` (correctness) and `census` (standing debt) to fill a real gap.

And one native skill is *cross-cutting* rather than a phase — it enforces the kit's whole thesis:

- **`/goal <condition>`** installs a session-scoped Stop hook that refuses to end the session until the condition holds, then auto-clears. Where the document backbone makes state *durable*, `/goal` makes an exit gate *binding*: any phase's acceptance criterion — "tests green", "reviewed", "verified" — can be pinned so the session can't quietly stop short of it. It's the runtime counterpart to the `docs/` ledger — the ledger records what's done, `/goal` refuses to stop until it is. Worked example: `/goal /verify` pins the session open until the work is verified, with the `verifier` agent (cold re-check of a single claim) the tool that makes the gate hold.

## The meta-loop: tuning the harness the flow runs in

The spine develops the *product*. A second, smaller loop develops the *setup the product is built with* — and it obeys the same thesis: the project's Claude config (`CLAUDE.md` at the repo root, plus its hooks, skills, and agents) is durable state, so learnings persist there instead of evaporating with the session.

```mermaid
flowchart LR
  car[claude-automation-recommender] --> cfg[("CLAUDE.md + hooks / skills / agents")]
  cmi[claude-md-improver] --> cfg
  cfg --> spine(["the 6-phase spine"])
  spine -. at session close .-> rcm[revise-claude-md]
  rcm -. writes learnings .-> cfg
  classDef doc fill:#e8f0fe,stroke:#4285f4,color:#111;
  class cfg doc;
```

These are plugin skills (not custom skills, not platform built-ins), so they carry no `*`:

- **`/claude-code-setup:claude-automation-recommender`** — reads a codebase and recommends which hooks, subagents, skills, plugins, and MCP servers it should have. The setup move: run it when first pointing Claude Code at a project, or when the setup feels thin.
- **`/claude-md-management:claude-md-improver`** — audits every `CLAUDE.md` against a quality bar and applies targeted fixes. Config *maintenance*, for when the memory has drifted from how the project actually works.
- **`/claude-md-management:revise-claude-md`** — at session close, writes what this session taught back into `CLAUDE.md`. It's the loop-closer, and the config-side twin of `ship-session`: one converts the session into as-built product docs, the other converts it into a sharper harness for the next run.

Read as a loop: the config shapes how every phase of the spine behaves; the spine surfaces where the config is wrong or thin; `revise-claude-md` folds that back in. `CLAUDE.md` is the root-level counterpart to `docs/` — same durable-and-reconciled discipline, pointed at the harness instead of the product.

## The document backbone

The reason the kit survives a `/clear` is that every phase that matters writes to `docs/`:

| Skill | Reads | Writes |
|---|---|---|
| `multi-session-plan` | design decision | `docs/<plan>/` index + session docs + roadmap |
| `run-state` | plan doc | run-state file (ledger of units) |
| `census` | whole repo + `docs/adr/` | `docs/census/` reconciled ledger |
| `ship-session` | plan doc | as-built plan doc + commit |
| `decision-record` | design fork | `docs/adr/` ADR |

Read top to bottom, that's a single stateful pipeline: decide → plan → execute → survey → close, each step reconciled against a file rather than reconstructed from history. The loops — census reconciling itself, review re-opening a build unit, ship handing back to plan — are what make it a *system* instead of a checklist.

## Decision capture — the gap, now closed

Every phase persisted its state except **Design**: a decision made at a design fork lived only in the chat — exactly the append-only-history failure mode the whole kit is built to avoid. `census` even *reads* `docs/adr/`, assuming ADRs exist, but nothing wrote them. `decision-record` closes it: at a fork, `design-a-*` generates the options, `grill-me` pressure-tests them, and `decision-record` writes which one won and why to `docs/adr/` — where census then reads it as by-design. The idea was harvested from `show-me-blueprint` without adopting the skill; see [the blueprint evaluation](show-me-blueprint-eval.md).
