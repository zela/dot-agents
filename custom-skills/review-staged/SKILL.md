---
name: review-staged
disable-model-invocation: true
description: Review the staged diff, or a branch range the user names, stress-test each finding against the source or a live system, fix only the survivors, then commit granularly. Use when the user asks to review staged changes, review `git diff --staged`, check what is staged before you commit, or mentions "review-staged".
---

1. Invoke the `code-review` skill. Target the staged paths explicitly (`git diff --staged --name-only`). Never target "the current diff", which can pull in unstaged work. When the user names a branch range instead (for example `main...HEAD`, for a branch whose work is already committed), target that range and skip the staged-path rules. Pass through any requested effort level. If a file is partly staged, discard findings that land on unstaged hunks. They are not what you are about to commit. Where `code-review` is unavailable, list candidates directly.

   Its output is candidates, not conclusions.

   If a plan session doc under `docs/`, or an issue or spec the user names, covers this change, run one Spec subagent as well. Give it the diff and the acceptance criteria, and ask for requirements that are missing, behaviour that was not asked for, and requirements that look implemented but wrong, each quoting the criterion. Its gaps go through steps 2–4 like the code findings: a verified gap is in scope and gets fixed. If the session doc lists the files the session may edit, a gap whose fix needs another file is reported, not fixed.
2. Verify EACH finding in its own subagent, launched in parallel. Use the `verifier` subagent if this host has one, otherwise a general subagent. Either way give it only the bare claim and where to look. Never give it the reasoning that produced it or the other findings:

   > Independently verify this claim against the actual source: "<claim>", at `<file:line>`. You have no prior context and must assume nothing. Report REPRODUCES or DOES-NOT-REPRODUCE with `file:line` evidence, plus how the site is reached and how large a change the claim implies. Default to DOES-NOT-REPRODUCE if the evidence is ambiguous.

   Discard anything that does not reproduce. Do not re-argue a discarded finding.
3. Is it worth fixing? True ≠ worth a diff. Decide this yourself — the verifier saw one claim through a keyhole and cannot weigh it against the whole change.

   Never filtered out: input validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything explicitly requested.

   Drop: taste-only rewrites, renames with no behavior change, speculative generality, abstraction with one call site, and any fix whose diff is larger than the risk it removes.

   Unsure → it goes in the report as a note, unfixed. Never silently.

   Second look, before anything lands in "not worth it": write down the fix's actual size and the failure it prevents. A fix of a few lines in files the change already touches, or a missing test for the change, is worth it. Keep an item in "not worth it" only when its real diff is larger than the risk, or it needs a file the change does not touch.
4. Fix what survives both filters. Minimal diff, no extra abstraction.
5. Run typecheck, tests, lint. All must pass.
6. Report, in these lists:
   - Fixed (spec gaps included)
   - Refuted (with the verifier's evidence)
   - True but not worth it (with the fix size and the reason)
   - Spec gaps not fixed (only when a spec existed; with what blocks each: a file outside the list, or a decision the spec does not make)

   Then propose the commits.

**STOP — hard gate. End the turn here.** Step 6's report is the deliverable. Do not start step 7 in the same turn, do not stage, do not commit, do not ask "shall I commit?" and answer yourself. Wait for a new user message.

7. Resume only on explicit instruction to commit. Approval of the *findings* is not approval to commit. The words "looks good" or "nice", or silence on the report, are not commit instructions. Then: granular conventional commits (feat/fix/refactor/docs/test), one concern per commit.

Be terse throughout.
