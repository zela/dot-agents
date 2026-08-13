---
name: review-staged
description: Review the staged diff, stress-test each finding against the source or a live system, fix only the survivors, then commit granularly. Use when the user asks to review staged changes, review `git diff --staged`, check what's staged before committing, or mentions "review-staged".
---

1. Invoke the `code-review` skill, targeting the staged paths explicitly (`git diff --staged --name-only`) — never "the current diff", which can pull in unstaged work. Pass through any requested effort level. If a file is partly staged, discard findings that land on unstaged hunks; they are not what you are about to commit. Where `code-review` is unavailable, list candidates directly.

   Its output is candidates, not conclusions.
2. Verify EACH finding in its own subagent, launched in parallel — the `verifier` subagent if this host has one, otherwise a general subagent. Either way give it only the bare claim and where to look — never the reasoning that produced it, never the other findings:

   > Independently verify this claim against the actual source: "<claim>", at `<file:line>`. You have no prior context and should assume nothing. Report REPRODUCES or DOES-NOT-REPRODUCE with `file:line` evidence, plus how the site is reached and how large a change the claim implies. Default to DOES-NOT-REPRODUCE if the evidence is ambiguous.

   Discard anything that does not reproduce. Do not re-argue a discarded finding.
3. Is it worth fixing? True ≠ worth a diff. Decide this yourself — the verifier saw one claim through a keyhole and cannot weigh it against the whole change.

   Never filtered out: input validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything explicitly requested.

   Drop: taste-only rewrites, renames with no behavior change, speculative generality, abstraction with one call site, and any fix whose diff is larger than the risk it removes.

   Unsure → it goes in the report as a note, unfixed. Never silently.
4. Fix what survives both filters. Minimal diff, no extra abstraction.
5. Run typecheck, tests, lint. All must pass.
6. Report, in three lists: fixed; refuted (with the verifier's evidence); true but not worth it (with the reason). Then the commits proposed.

**STOP — hard gate. End the turn here.** Step 6's report is the deliverable. Do not start step 7 in the same turn, do not stage, do not commit, do not ask "shall I commit?" and answer yourself. Wait for a new user message.

7. Resume only on explicit instruction to commit. Approval of the *findings* is not approval to commit — "looks good", "nice", or silence on the report are not commit instructions. Then: granular conventional commits (feat/fix/refactor/docs/test), one concern per commit.

Be terse throughout.
