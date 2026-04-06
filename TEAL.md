# AGENTS.md — Token-Efficient Agent Language (TEAL) v2

Reduce agent reasoning tokens 40-60%. Apply in thinking blocks, tool descriptions, internal narration.
User-facing output stays natural unless user opts in.

---

## 1. Telegraphic Grammar

Drop everything w/o meaning.

| Drop                    | Before → After                                 |
| ----------------------- | ---------------------------------------------- |
| Articles                | ~~the~~ fn returns ~~an~~ err                  |
| Copulas (is/are/was)    | file ~~is~~ missing                            |
| Filler starts           | ~~Let me~~ check → check                       |
| Hedging                 | ~~I think~~ cfg ~~probably~~ wrong → cfg wrong |
| Progressive             | ~~I'm checking~~ → check                       |
| Pleasantries            | ~~Sure! Happy to~~ → (do it)                   |
| Transitions             | ~~Moving on to~~ → (move on)                   |
| Pronouns (obvious subj) | ~~it~~ returns null                            |

Prefer imperative mood. Use noun chains: "user auth token refresh logic" not "the logic for refreshing the user's authentication token".

**Output directives:**

- Don't explain standard language features or boilerplate.
- Output diffs, not full files (when modifying existing code).
- On task completion: state result, stop. No recap, no summary.

**Chain of Draft (CoD):** each reasoning step ≤ 5 words. Forces compression.

```
❌ "I need to check whether the database connection pool is exhausted"
✓  "chk db pool exhausted?"
```

---

## 2. Abbreviations

### Core

| Abbr  | Meaning        | Abbr | Meaning       |
| ----- | -------------- | ---- | ------------- |
| fn    | function       | var  | variable      |
| impl  | implementation | cfg  | configuration |
| dep   | dependency     | pkg  | package       |
| err   | error          | req  | request       |
| res   | response       | ret  | return        |
| val   | value          | arg  | argument      |
| param | parameter      | init | initialize    |
| def   | definition     | ref  | reference     |
| cb    | callback       | idx  | index         |
| len   | length         | cnt  | count         |
| attr  | attribute      | prop | property      |
| msg   | message        | fmt  | format        |

### Infra

| Abbr  | Meaning        | Abbr  | Meaning             |
| ----- | -------------- | ----- | ------------------- |
| db    | database       | authN | authentication      |
| authZ | authorization  | auth  | authN+authZ general |
| env   | environment    | repo  | repository          |
| dir   | directory      | fs    | filesystem          |
| cli   | command line   | api   | API endpoint        |
| ci    | CI/CD pipeline | k8s   | Kubernetes          |
| ctn   | container      | srv   | server              |
| clt   | client         | ep    | endpoint            |
| ws    | websocket      | lb    | load balancer       |
| gw    | gateway        | q     | queue               |
| wrk   | worker process |       |                     |

### Verbs

| Abbr | Meaning       | Abbr | Meaning          |
| ---- | ------------- | ---- | ---------------- |
| chk  | check/inspect | upd  | update           |
| rm   | remove        | mv   | move             |
| cp   | copy          | mk   | create           |
| mod  | modify        | get  | retrieve         |
| set  | assign        | run  | execute          |
| dbg  | debug         | tst  | test             |
| bld  | build         | dpl  | deploy           |
| vld  | validate      | ser  | serialize        |
| grep | search code   | diff | compare          |
| inst | install       | cfg! | configure (verb) |

> **Collision fixes from v1:** `dep` = dependency only (use `depr` for deprecated). `val` = value only (use `vld` for validate). `cfg` = noun; `cfg!` = verb.

### Status

| Abbr  | Meaning     | Abbr   | Meaning      |
| ----- | ----------- | ------ | ------------ |
| ok    | success     | fail   | failure      |
| wip   | in progress | todo   | to do        |
| fixme | needs fix   | hack   | workaround   |
| depr  | deprecated  | exp    | experimental |
| brk   | breaking    | compat | compatible   |

### Git & File Ops

| Abbr  | Meaning      | Abbr  | Meaning         |
| ----- | ------------ | ----- | --------------- |
| co    | checkout     | cm    | commit          |
| pr    | pull request | mg    | merge           |
| rb    | rebase       | hd    | HEAD            |
| br    | branch       | r/w/x | read/write/exec |
| chmod | permissions  | ln    | symlink         |
| tmp   | temporary    | bak   | backup          |
| gz    | compressed   |       |                 |

---

## 3. Symbols

| Symbol  | Meaning           | Example                         |
| ------- | ----------------- | ------------------------------- |
| →       | then / leads to   | chk logs → found err → fix cfg  |
| ←       | caused by         | crash ← null ptr ← missing init |
| ∴       | therefore         | no tsts ∴ add tst first         |
| ≈       | similar to        | new impl ≈ old but async        |
| ✓ / ✗   | pass / fail       | auth ✓, tls ✗                   |
| ?       | uncertain         | mem leak? chk heap              |
| !       | critical          | ! rm -rf on prod                |
| & / \|  | and / or          | lint & tst \| skip if ci        |
| = / !=  | equals / mismatch | status = 503, expected != got   |
| > / >>  | prefer / strongly | stream >> buffer for lg files   |
| ~       | roughly           | ~500ms latency                  |
| :=      | set to            | timeout := 30s                  |
| ++ / -- | improve / degrade | perf++ after cache              |

---

## 4. Reasoning Patterns

### Chain Notation

```
auth fail → chk cfg api keys → chk srv logs for err
```

### Causal Chains (reverse arrow)

```
500 err ← handler throws ← db conn timeout ← pool exhausted
```

### Decision Trees

```
file exists?
  ✓ → chk perms → readable?
    ✓ → parse & ret
    ✗ → chmod 644 → retry
  ✗ → mk file w/ defaults
```

### Status Blocks

```
[✓] deps inst
[✓] cfg vld
[✗] tst — 3 fail
[ ] fix tsts
[ ] dpl staging
```

### Diff Notation

```
- old: sync fetch, blocks main
+ new: async fetch, non-blocking
```

---

## 5. Thinking Block Templates

Biggest token sink = thinking blocks. Use structured templates:

### Bug Investigation

```
symptom: [what's observed]
repro: [steps if known]
hypothesis: [most likely cause]
chk: [what to verify] → [result]
fix: [action]
```

**Example:**

```
symptom: 500 on /api/users
repro: any GET w/ limit>100
hypothesis: OOM ← unbounded query
chk: handler code → no pagination, loads all → ✓ confirmed
fix: add LIMIT/OFFSET, default 50
```

### Architecture Decision

```
need: [requirement]
opts: A=[option] | B=[option] | C=[option]
A: pro=[...] con=[...]
B: pro=[...] con=[...]
pick: [choice] ∴ [reason]
```

### Code Review

```
[file:line] [severity] — [issue]
```

```
src/auth.ts:42 !err — null chk missing before .map()
src/db.ts:15 warn — hardcoded timeout, mv to cfg
src/api.ts:88 nit — unused import
```

### Planning

```
goal: [what]
steps: 1=[action] → 2=[action] → 3=[action]
risk: [what could go wrong]
fallback: [plan B]
```

---

## 6. Toki Pona Principle

One word per concept. Collapse synonyms:

| Use        | Replaces                                          |
| ---------- | ------------------------------------------------- |
| chk        | investigate, examine, analyze, inspect, review    |
| fix        | repair, resolve, patch, correct, remediate        |
| mk         | create, generate, produce, construct, instantiate |
| brk        | broken, failing, crashed, errored, down           |
| fast       | performant, optimized, efficient, quick           |
| slow       | bottleneck, degraded, lagging                     |
| big / sm   | large,substantial / small,minor,trivial           |
| odd        | weird, strange, unexpected, anomalous             |
| bad / good | incorrect,invalid / correct,valid,proper          |

---

## 7. Context Management

### Label Once, Ref After

```
First:  "auth middleware (amw) strips jwt, validates, attaches user"
After:  "amw fails here"
```

### Numbered Files

```
[1]=src/auth.ts [2]=cfg/db.yml [3]=test/auth.test.ts
"[1]:42 missing null chk → [3] fails"
```

### Session Shorthand

```
FE=frontend BE=backend GW=gateway Q=queue
"FE req → GW routes → BE process → Q async"
```

---

## 8. Tool Call Compression

```
❌ "I need to read the configuration file to understand the current
    database settings and check if connection parameters are correct."

✓  "read db cfg — chk conn params"
```

```
❌ "Let me search for similar issues in the codebase to see if this
    pattern has been handled elsewhere."

✓  "grep similar pattern in repo"
```

---

## 9. Agent-to-Agent Protocol

For multi-agent handoffs, task summaries, and status updates use structured format:

```
[status] [~mod | ->transition | -delete] [validation]
```

**Examples:**

```
delta auth.ts ~JWT->OIDC. tsc clean.
  = modified auth.ts, switched JWT to OIDC, TypeScript compiles

err db_pool!conn. retry+backoff.
  = db pool connection failed, retrying with backoff

done api/users ep. tst ✓ lint ✓. handoff→FE team.
  = endpoint complete, tests and lint pass, handing to frontend

wip mg feat/payments→main. conflicts @[2]:42. need review.
  = merging payments branch, conflict in file [2] line 42
```

Keep handoff msgs to one line when possible. Include validation (tsc/tst/lint status) so receiving agent doesn't re-check.

---

## 10. TEAL Response Mode

When user opts in (e.g., "use TEAL" or "respond compressed"), apply TEAL to output too:

```
User: "use TEAL. why is my deploy failing?"

Agent: chk ci logs → bld fails @ step 3 → dep resolution err
  pkg-lock.json & package.json out of sync
  fix: rm node_modules & pkg-lock → inst → cm & push
```

Toggle off: "normal mode" or "verbose please"

---

## 11. When NOT to Compress

- User-facing output (unless opted in)
- Error msgs shown to user — clarity > brevity
- Documentation output — this is deliverable
- Ambiguous situations — nuance matters
- Security ops — spell out what gets rm'd/modified
- Teaching/explaining — user needs to learn, not just see result

---

## Quick Ref

```
Grammar:  drop articles, copulas, filler. imperative.
CoD:      each reasoning step ≤ 5 words.
Output:   diffs not full files. result, stop.
Chain:    chk X → found Y → fix Z
Cause:    err ← bad cfg ← missing env
Branch:   cond? ✓ → A | ✗ → B
Status:   [✓] done [✗] fail [ ] todo
Symbols:  → then  ← because  ∴ therefore  ? unsure  ! critical
Labels:   name once (xyz), ref xyz after
Thinking: symptom → hypothesis → chk → fix
A2A:      [status] [~mod/->transition] [validation]
Auth:     authN=authentication authZ=authorization auth=both
Collisions: dep/depr val/vld cfg/cfg!
```
