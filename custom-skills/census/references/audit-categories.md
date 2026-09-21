# Audit categories

What to look for, per category. Each Explore subagent gets the relevant section(s) plus the **Finding format** at the bottom. Adapt depth to repo size and shape — a 2k-line library gets a lighter pass than a 500k-line monorepo, and a category with no surface in this repo (SQL injection in a pure client, route-splitting in a CLI) is skipped, not stretched.

A finding is only a finding with evidence you read. "Probably has N+1 somewhere" is not a finding; `orders/api.ts:142 issues one query per item inside a loop` is.

---

## 1. Correctness / bugs

The highest-trust category — real bugs found by reading, not speculation.

- Error handling: swallowed exceptions, empty catch, `catch (e) { log(e) }` on critical paths, missing error states in UI.
- Async hazards: unawaited promises, races on shared state, missing cleanup/cancellation (stale closures in effects, listeners never removed).
- Null/undefined flows: non-null `!` on values that can be null, optional chaining hiding a value that must exist, unchecked indexing.
- Boundary conditions: off-by-one, empty-collection handling, timezone/locale assumptions.
- State machines: impossible states representable in types, enum branches with a silent `default:` no-op.
- Type escape hatches: `any` / `as` / `@ts-ignore` clusters — each is a place the compiler was overruled; the cast often hides the exact nullable the bug rides on.
- Resource leaks: unclosed handles, subscriptions, connections; missing `finally`.

## 2. Security

Defensive framing only: identify the pattern, the production impact, the remediation. No runnable misuse strings, no step-by-step exploit detail.

**Handling rule:** never copy a secret value into a finding — reference type + `file:line` only ("Stripe key at `config.ts:12`"), and the fix always includes **rotation**, not just removal (a committed secret is burned even after deletion).

**By-design is not a finding.** Standard platform conventions (honoring `https_proxy`, reading `~/.netrc`) are intentional; a tradeoff recorded in an ADR is settled. Flag these only when the *implementation* adds risk beyond the convention. A **stale ADR is itself a finding** — if the code drifted from the decision doc, report the drift.

- Credential hygiene: hardcoded keys/tokens, credentials in committed env files or logs.
- Data into interpreters/sinks: SQL/shell from request data, HTML sinks fed by user content (XSS — raw-HTML markdown renderers, `dangerouslySetInnerHTML` without sanitization), dynamic execution, path traversal.
- Access control: server actions without server-side identity checks, auth enforced only client-side, object access by ID without ownership (IDOR), missing CSRF on state-changing routes.
- Input contracts: API boundaries trusting request/response bodies without schema validation, file upload without type/size limits, mass assignment.
- Production config: overly broad CORS with credentials, missing CSP / hardening headers on sensitive surfaces, cookies missing `HttpOnly`/`Secure`/`SameSite`, debug enabled in prod, source maps served publicly.
- Data minimization: PII/financial data in logs or error telemetry, stack traces or internal errors returned to clients.

## 3. Performance

Architectural and algorithmic wins, not micro-opts. For a confirmed hotspot, record the finding and recommend `complexity-optimizer` for the fix — don't re-derive the fix here (census is read-only; it never runs the fixer).

- N+1: query/fetch per item in a loop or per list-row render; missing batching.
- Wrong complexity: nested scans over the same collection, repeated `find`/`filter` in hot loops where a Map lookup belongs.
- Caching gaps: identical expensive work repeated per render/request; missing memoization at clear boundaries; no data-layer caching on stable data.
- Payload: over-fetching, missing pagination on unbounded lists, large JSON to clients.
- Frontend: bundle composition (heavy dep for trivial use), missing code-splitting on rare routes, client-side fetch for data available at render, render waterfalls, unmemoized context providers re-rendering wide subtrees. Defer to the framework's own best-practices guidance.
- Backend: sync work that belongs in a queue, missing indexes implied by query patterns (flag for verification — don't claim without schema evidence), connection-per-request where pooling exists.

## 4. Test coverage

Not a percentage — *which untested code is dangerous*.

- Map the critical paths (money, auth, data mutation, the feature the repo exists for); check which have zero or trivial coverage.
- High-churn + untested modules = top refactor risk; flag as "characterization tests first."
- Test quality: assert-nothing tests, heavy mocking that tests the mocks, snapshots nobody reads, flaky patterns (real timers/network, order dependence).
- Missing layers: unit-only with no integration coverage at API boundaries, or slow E2E for what a unit test would catch.
- Is there a one-command way to know the codebase works? If not, that's finding #1 and a prerequisite for any risky change.

## 5. Tech debt & architecture

- Duplication: the same logic in 3+ places, divergent copies that have drifted.
- Layering violations: UI importing data-layer internals, circular deps, a "utils" junk drawer with high fan-in.
- Dead code: unexported-and-unused modules, fully-rolled-out flags still branching, commented-out blocks, manifest deps no longer imported.
- God modules: files an order of magnitude larger than the median that everything touches; double-digit-parameter functions.
- Inconsistent patterns: three ways of doing data fetching / error handling / styling in one repo — name the winner (usually the most recently converged-on) and plan the consolidation.
- Abstraction mismatches: premature abstraction with one implementation, or a missing one where the same change always touches N files in lockstep.
- Shallow modules: an interface nearly as complex as its implementation — pass-through wrappers, layers that only delegate, pure functions extracted for testability while the real bugs hide in how they are called. Apply the deletion test: if deleting the module makes complexity vanish, it was a pass-through; if complexity reappears across N callers, it earned its keep.
- Missing locality: understanding one concept means bouncing across many small modules. The candidate fix is deepening — one interface, one place to test. Recommend `design-an-interface` for the deepened shape, and use its vocabulary (module, interface, depth, seam, adapter) in the finding.
- Hypothetical seams: a port or interface with a single adapter. One adapter is indirection; two (production + test) justify the seam.
- Weight by churn: `git log` hot spots first. Deepening pays off where change keeps landing, so a shallow module nobody touches is a LOW-severity row.

## 6. Dependencies & migrations

- Major-version lag with real cost (EOL, security-fix cutoff, ecosystem incompatibility) — not every minor bump.
- Deprecated APIs with announced removal; abandoned deps on critical paths.
- Duplicate deps solving the same problem (two date libs, two HTTP clients); lockfile/manifest drift.
- For each migration candidate, estimate blast radius (files touched) — that drives whether to recommend it at all. Run the ecosystem audit (`npm audit`, `pip-audit`) read-only if cheap; report only critical/high on reachable code.

## 7. DX & tooling

- Missing/broken typecheck script, lint, formatter, pre-commit hooks.
- Slow feedback loops; CI without caching.
- Onboarding friction: wrong README setup steps, undocumented required env vars, no `.env.example`.
- Missing `CLAUDE.md`/`AGENTS.md` where agents execute the work.

## 8. Direction — features & where to take this next (present separately)

Forward-looking, not what's broken. **Grounding rule:** every suggestion cites evidence from the repo — a suggestion that could apply to any project in the category ("add dark mode") is noise. Sources: unfinished intent (TODO clusters, flags never rolled out, stubbed modules), stated-but-undelivered (README promises with no code, no-op config), surface asymmetries (export without import, CRUD-minus-one), the adjacent possible (a plugin system one interface away). Impact here is product value; confidence reflects how grounded the evidence is. Strategy belongs to the maintainer — offer grounded options with honest trade-offs, don't rank them against bugs.

---

## Finding format

Every finding, from every category and subagent, comes back in this shape:

One monotonic id per finding (`001`, `002`, … assigned when it lands in the ledger), plus its category tag. There is no per-category counter — the id is global.

```markdown
### [001 · sec] Short imperative title

- **Evidence**: `path/file.ts:123` — one sentence on what's there. (2–5 strongest locations; note "and ~N similar sites" if widespread.)
- **Impact**: what goes wrong / what's paid. Concrete: "every order-list render issues 1+N queries", not "suboptimal".
- **Severity**: HIGH / MED / LOW — blast radius × likelihood of the *problem* (not the fix). One line why. This is the axis rows sort on; keep it independent of Effort, Risk, and Confidence.
- **Effort**: S (hours) / M (a day-ish) / L (multi-day) — for the *fix*, including tests.
- **Risk**: what the fix could break; LOW/MED/HIGH + one line why.
- **Confidence**: HIGH (read it, certain) / MED (strong signal, needs verification) / LOW (smell, needs investigation).
- **Resolves-with** (optional; include whenever severity or confidence hinges on a fact not visible in the code): the single cheapest check that collapses the uncertainty — a command to run (`wrangler secret list`), a doc to read (a plan that may already scope it), or a one-line yes/no for the maintainer. Omit when the finding is already HIGH and self-contained.
- **Fix sketch**: 1–3 sentences. Just enough to judge effort — not a plan.
```

---

<sub>Adapted from the audit playbook in [shadcn/improve](https://github.com/shadcn/improve) (MIT), condensed and retargeted for a host-agnostic ledger. The module-depth items in category 5 are the lens of `improve-codebase-architecture` in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT), pointed at the ledger instead of a temp HTML report.</sub>
