# <Project> — Canonical Data Model

> Single source of truth for the shape of data the app/sessions exchange. Mock fixtures and real outputs both conform to it — that's what makes a mock → real swap cheap.
>
> Include this doc only when sessions share a data contract. Delete it for pure-UI or scripting plans.

## Reconciliation decisions

<When a prototype's data shape and a spec's interfaces differ, resolve each conflict once here. These override the source docs where they disagree. Examples: value scale, normalization method, where derived vs stored, numbers vs formatted strings.>

1. **<topic>:** <decision + rationale>.
2. **<topic>:** <decision + rationale>.

## Types / schemas

```typescript
// Define once; derive types from runtime schemas (e.g. z.infer) so types and
// validation never drift. Keep this block authoritative.

interface <Entity> {
  // …
}
```

## Artifact / file layout

| File | Contents |
|------|----------|
| `<name>.json` | <shape> |
| `<dir>/` | <intermediate, not consumed by the app> |

Fixtures mirror these filenames so the loader switches source by directory only.

## Validation

<Where schemas live, when parse is called (write-time in the pipeline, load-time in the app), and the test that asserts committed fixtures parse.>

## Source → canonical mapping (for porting)

<If porting from a prototype, a field-by-field table reduces guesswork.>

| Source field | Canonical | Note |
|--------------|-----------|------|
| <old> | <new> | <transform> |
