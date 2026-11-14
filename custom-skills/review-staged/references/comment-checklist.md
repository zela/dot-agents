# Comment checklist

Use this checklist for the comment lines and the Markdown prose that the diff adds or changes. These categories add to the Comments rules in `AGENTS.md`. Apply both.

A finding gives `file:line`, the category, the quoted text, and a proposed fix. The fix is a deletion or one line that replaces the text.

## Categories

1. **Session residue.** The text makes sense only with the conversation or the commit history before the squash. Signals: "now", "no longer", "instead of", "as discussed", a removed thing named as if it still exists, "fixes the bug where" without the mechanism.
   - Example: `// The only guard left, since the old detector was removed.`
   - Fix: delete it. If the code needs the reason, state the mechanism. If an issue exists, link it.
2. **Layout listing.** The text lists sibling files or directories and what each holds. The file tree already shows this. The list becomes wrong at the next rename.
   - Fix: state what this file does, or give the one reason for the layout.
3. **Regenerable specifics.** Counts, sizes, versions, lists of covered tests, or values copied from data or configuration. This category applies to living text, which people keep current: code comments, READMEs, guides, `SKILL.md`, `AGENTS.md`. A dated record is a snapshot, and its numbers are the record. ADRs, eval notes, and changelog entries are dated records. The test: will the sentence stay true after the next routine update? If it will not, report it.
   - Example: `The table holds 512 aliases across 9 locales.`
   - Fix: point to the source of truth, for example `Counts are in the generated JSON.`
4. **Stacked negations.** Two or more "never", "no", or "not" clauses that reject alternatives that no reader assumes.
   - Example: `It never retries, never caches, and does no batching.`
   - Fix: write one positive statement. If the choice needs a signal, add "deliberately": `One attempt per call, deliberately.`
5. **Reassurance.** Words that grade the work for a reviewer: robust, safe, trusted, comprehensive, production-ready, carefully.
   - Fix: give the fact behind the word, or delete it.
6. **Spec-speak.** Terms that the change invents and that a reader cannot look up: plan labels, phase names, "the v2 path". A plan doc can use the labels that it defines. The same labels in code or living text are findings.
   - Fix: describe the thing in plain words, or use the term from `CONTEXT.md`.
7. **Restated code.** The text narrates the next line or explains standard language behavior.
   - Fix: delete it. If the comment also states an invariant, propose a shorter comment that keeps only the invariant.
   - Before: `// Read the file. A missing file is fine only if the channel wrote no samples; otherwise raise.`
   - After: `// A missing file is fine only if the channel wrote no samples.`

## Exceptions

Leave this text as it is. Do not report it:

- An invariant, a constraint, or a reason that the code cannot show.
- A term that `CONTEXT.md` defines.
- In a codebase whose instruction file contains `Agent-maintained codebase.`: a comment on a coupling to another file, or a pointer to the ADR behind a decision. A pointer to one file is not a layout listing.

<sub>Categories adapted from [claudy-comment-detector](https://github.com/citelao/dotfiles/blob/main/dotfiles/.chezmoitemplates/skills/claudy-comment-detector/SKILL.md) by citelao.</sub>
