# Census — <repo name>

Standing whole-codebase review. Each row is a vetted finding; reconcile (`census reconcile`) re-takes the count.

- **Last full sweep:** <YYYY-MM-DD> @ `<short-commit>` (add ` +dirty` if swept against an uncommitted working tree)
- **Last reconcile:** <YYYY-MM-DD> @ `<short-commit>`
- **Depth:** quick | standard | deep
- **Not swept:** <what this census did not cover — be honest>

**Status legend:** `·` open · `▶` in progress · `✓` done (verified gone) · `~` stale (code moved, needs re-read) · `⊘` retired (no longer applies)

## Findings

Ordered by leverage (severity ÷ effort, discounted by confidence and fix-risk). The verification-baseline finding and any security finding graded Severity HIGH float up.

| # | Status | Finding | Cat | Sev | Effort | Risk | Conf | Found@ |
|---|--------|---------|-----|-----|--------|------|------|--------|
| 001 | · | <title> → `findings/001-<slug>.md` | sec | HIGH | S | LOW | HIGH | `<commit>` |
| 002 | · | <title> → `findings/002-<slug>.md` | perf | MED | M | MED | MED | `<commit>` |

## Direction (options, not defects)

Forward-looking suggestions — the maintainer weighs these, they are not ranked against the bugs above.

- **<title>** — <evidence + trade-off in 2–3 sentences>.

## Considered and rejected

Kept so the next sweep doesn't re-audit them.

- **<title>** — <why it's not a finding: by-design, DOES-NOT-REPRODUCE, settled in ADR>.
