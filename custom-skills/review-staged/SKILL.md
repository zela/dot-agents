---
name: review-staged
disable-model-invocation: true
description: Review the staged diff, or a branch range the user names, stress-test each finding against the source or a live system, fix only the survivors, then commit granularly. Use when the user asks to review staged changes, review `git diff --staged`, check what is staged before you commit, or mentions "review-staged".
---

1. If every path in the diff is a doc (`.md`, `.mdx`, `.txt`, `.rst`), skip `code-review`. The Prose and Writing subagents that follow are the reviewers. Otherwise, invoke the `code-review` skill. Target the staged paths explicitly (`git diff --staged --name-only`). Never target "the current diff", which can pull in unstaged work. When the user names a branch range instead (for example `main...HEAD`, for a branch whose work is already committed), target that range and skip the staged-path rules. Pass through any requested effort level. If a file is partly staged, discard findings that land on unstaged hunks. They are not what you are about to commit. Where `code-review` is unavailable, list candidates directly.

   Its output is candidates, not conclusions.

   If a plan session doc under `docs/` covers this change, run one Spec subagent. Do the same if the user names an issue or a spec that covers it. Give it the diff and the acceptance criteria. Ask it for missing requirements, for behavior that nobody asked for, and for requirements that look implemented but wrong. Also ask for each changed test that is tautological. A tautological test takes its expected value from the implementation's output, not from the criterion. An existing assertion edited to match new output counts, unless the spec replaced that behavior. A regression test for existing behavior needs no criterion. Each finding quotes its criterion. A verified gap is in scope. Fix it in step 4. If the session doc lists the files that the session can edit, report a gap whose fix needs another file. Do not fix it.

   If the diff adds or changes comments or docs, run one Prose subagent. Give it the diff and the path to `references/prose-checklist.md` in this skill's directory. Ask for each line that matches a checklist category.

   If the diff adds or changes docs, run one Writing subagent. Give it the changed doc lines. Tell it to load the rules for each kind of doc:
   - Agent instructions (`SKILL.md`, `AGENTS.md`, `CLAUDE.md`, a file that a skill points to): the `writing-for-agents` skill and the `simple-english` skill
   - Other text that a reader follows exactly (a README, a guide, a runbook): the `simple-english` skill
   - Other prose (notes, evals, explanations): the `stop-slop` skill
   - Every doc: the Writing rules in `AGENTS.md`.

   Ask for each line that breaks a rule, with the skill and the rule that it breaks.

   The Spec and Prose findings go through steps 2–4 like the code findings. Writing findings skip step 2, which sends each finding to a verifier. A Writing finding does not need one, because it quotes its line and its rule. In step 3, a Prose or Writing finding counts as a defect, not a taste-only rewrite, because it names a rule. In step 4, read the line of each Writing finding again before you fix it. If the line does not break the rule, discard the finding.
2. Verify EACH finding in its own subagent, launched in parallel. Use the `verifier` subagent if this host has one, otherwise a general subagent. Either way give it only the bare claim and where to look. Never give it the reasoning that produced it or the other findings:

   > Independently verify this claim against the actual source: "<claim>", at `<file:line>`. You have no prior context and must assume nothing. Report REPRODUCES or DOES-NOT-REPRODUCE with `file:line` evidence, plus how the site is reached and how large a change the claim implies. On a protected subject (security or auth, data loss, concurrency, injection, secrets exposure, cryptography, memory safety, a public contract), report DOES-NOT-REPRODUCE only with refuting evidence. Refuting evidence is a quoted `file:line`, version-specific documentation, or a test that exercised the exact trigger. If that evidence is missing, report UNRESOLVED and name what is missing. On any other subject, default to DOES-NOT-REPRODUCE if the evidence is ambiguous.

   Discard each DOES-NOT-REPRODUCE. Do not re-argue a discarded finding.
3. Is it worth fixing? True ≠ worth a diff. Decide this yourself — the verifier saw one claim through a keyhole and cannot weigh it against the whole change.

   Never filtered out: input validation at trust boundaries, error handling that prevents data loss, security, accessibility, anything explicitly requested.

   Drop: taste-only rewrites, renames with no behavior change, speculative generality, abstraction with one call site, and any fix whose diff is larger than the risk it removes.

   Instruction prose (`SKILL.md`, a skill's references, `AGENTS.md`, a rule file) is not code. This rule covers a finding against the logic of a rule. A Prose or Writing finding is about the wording, and it stays a defect (step 1). If the rule's stated condition already decides the case, the finding is not a fix. Report it with the condition quoted. If the condition is wrong, fix the condition. If the rule sits in a file that does not do that work, move it to the file that does. Never add the case. On a second round of findings against the same block, restate the block as its goal and done condition. Do not patch it again.

   A finding that undoes a decision recorded in an ADR or in a plan's decisions log goes in the report, unfixed. Fix it only if the decision is infeasible or destructive.

   Unsure, or UNRESOLVED in step 2 → it goes in the report as a note, unfixed, with the evidence it lacks. Never silently.

   Second look, before anything lands in "not worth it": write down the fix's actual size and the failure it prevents. A fix of a few lines in files the change already touches, or a missing test for the change, is worth it. Keep an item in "not worth it" only when its real diff is larger than the risk, or it needs a file the change does not touch.
4. Fix what survives both filters. Minimal diff, no extra abstraction.
5. If every path in the diff is a doc, skip this step. Otherwise, run the typecheck, the tests and the lint. All must pass.
6. Report, in these lists:
   - Fixed (spec gaps included)
   - Refuted (with the verifier's evidence)
   - True but not worth it (with the fix size and the reason)
   - Notes: Unsure and UNRESOLVED findings (with the evidence that each one lacks)
   - Spec gaps not fixed (only when a spec existed; with what blocks each: a file outside the list, or a decision the spec does not make)

   Then propose the commits.

**STOP — hard gate. End the turn here.** Step 6's report is the deliverable. Do not start step 7 in the same turn, do not stage, do not commit, do not ask "shall I commit?" and answer yourself. Wait for a new user message.

7. Resume only on explicit instruction to commit. Approval of the *findings* is not approval to commit. The words "looks good" or "nice", or silence on the report, are not commit instructions. Then: granular conventional commits (feat/fix/refactor/docs/test), one concern per commit.

Be terse throughout.
