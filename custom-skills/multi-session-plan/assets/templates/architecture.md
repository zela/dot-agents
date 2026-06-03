# <Project> — Architecture

## Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| <Frontend> | <e.g. Astro + Preact> | <why / constraints> |
| <Hosting> | <e.g. Cloudflare Pages> | <deploy command> |
| <Data processing> | <e.g. TypeScript ETL via tsx> | <build-time / runtime> |
| <Validation> | <e.g. Zod> | <where applied> |
| <Tests / lint> | <e.g. Vitest, ESLint+Prettier> | <conventions to match> |

## Repo layout (target)

```
<project>/
  <app>/                 # <role>
  <pipeline-or-lib>/     # <role>
  packages/<shared>/     # <shared contract / tokens — imported by multiple tracks>
  data/                  # <fixtures (committed) vs generated (gitignored), if applicable>
  docs/                  # this plan
  <reference dirs>/      # prototype / design — reference only, not built
```

<One line on repo strategy: single repo vs workspace vs monorepo package, and when to revisit.>

## Data flow

```
<source> ──▶ <extract/transform> ──▶ <artifacts> ──▶ <build> ──▶ <deployed output>
```

<Call out the seam where mock and real data are interchangeable, if the plan is mock-first.>

## Shared contract / module boundaries

<If multiple tracks share types/schemas, state where they live and how each track imports the single source — avoid duplicated or drifting definitions. Note any language/runtime seam (e.g. ESM vs TS) and how it's resolved.>

## Environment / secrets

| Var | Purpose | Source |
|-----|---------|--------|
| <NAME> | <what it's for> | <where it comes from; never commit> |

## Deploy

```bash
<build command>
<deploy command>
```

## Reuse references (read-only)

<Files in this repo or a sibling/monorepo to read and adapt — never import at runtime if it's a separate-ownership repo. Be concrete with paths.>

| Need | Reference path | What to take |
|------|----------------|--------------|
| <e.g. data client> | <path> | <pattern to vendor/copy> |
| <conventions> | <path> | <config to mirror> |
