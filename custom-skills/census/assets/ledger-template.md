# Census — <repo name>

Standing whole-codebase review. Each row is a vetted finding; reconcile (`census reconcile`) re-takes the count.

- **Last full sweep:** <YYYY-MM-DD> @ `<short-commit>` (add ` +dirty` if swept against an uncommitted working tree)
- **Last reconcile:** <YYYY-MM-DD> @ `<short-commit>`
- **Depth:** quick | standard | deep
- **Not swept:** <what this census did not cover — be honest>

**Status legend:** `·` open · `▶` in progress · `✓` done (verified gone) · `~` stale (code moved, needs re-read) · `⊘` retired (no longer applies) · `⊙` tracked (scoped by an intent/plan doc, unbuilt — not a fresh defect) · `min` minor / latent (real but low-leverage; sits below the cut line)

## Findings

Ordered by leverage (severity ÷ effort, discounted by confidence and fix-risk). The verification-baseline finding and any security finding graded Severity HIGH float up. Rows marked `min` (minor / latent — real but too low-leverage to rank: LOW-confidence smells, provably-tiny-n complexity, defensive-only hardening with no current trigger) sort below the `— minor / latent —` cut line and are not weighed against the rows above. When they outnumber a handful, lift them into the **Minor / latent** section instead, so the ranked table stays scannable.

| # | Status | Finding | Cat | Sev | Effort | Risk | Conf | Found@ |
|---|--------|---------|-----|-----|--------|------|------|--------|
| 001 | · | <title> → `findings/001-<slug>.md` | sec | HIGH | S | LOW | HIGH | `<commit>` |
| 002 | · | <title> → `findings/002-<slug>.md` | perf | MED | M | MED | MED | `<commit>` |
| — minor / latent — | | | | | | | | |
| 014 | min | <title> → `findings/014-<slug>.md` | perf | LOW | S | LOW | LOW | `<commit>` |

## Minor / latent (optional — only when `min` findings outnumber a handful)

Lift the `min` rows here when they clutter the table above. Flat and unranked — each still has its `findings/NNN-*.md` and is still reconciled; they just don't compete for the top. Distinct from the two sections below: **Direction** is forward options (not defects), **Considered and rejected** is things checked and found *not* to be findings. `⊘` retired rows stay in the table with their marker — retired is dead-but-kept, a different axis from minor-but-live.

- `NNN` min <title> → `findings/NNN-<slug>.md` — <one clause>.

## Direction (options, not defects)

Forward-looking suggestions — the maintainer weighs these, they are not ranked against the bugs above.

- **<title>** — <evidence + trade-off in 2–3 sentences>.

## Considered and rejected

Kept so the next sweep doesn't re-audit them.

- **<title>** — <why it's not a finding: by-design, DOES-NOT-REPRODUCE, settled in ADR>.
