---
name: diagnosing-bugs
description: Diagnosis loop for hard bugs and performance regressions. Use when the user says "diagnose" or "debug this", or reports something broken, throwing, failing, or slow.
---

# Diagnosing Bugs

A discipline for hard bugs. Skip a phase only when you give a reason.

Before you explore the code, read `CONTEXT.md` if it exists. It gives the names of the modules. Read the ADRs in `docs/adr/` for the area you touch.

## Redact

This skill makes you show commands, outputs, and captured artifacts. Redact every secret first. Write `<REDACTED>` in its place. Build loops against environment variables, so that the credential stays in the environment and not in what you show. A captured artifact carries auth headers. Quote only the lines that carry the signal.

If the redacted output is not enough to diagnose the bug, say so and ask the user.

## Phase 1: Build a feedback loop

This phase is the skill. Everything after it is mechanical. If you have a tight pass/fail signal that goes red on this bug, you will find the cause. Bisection, hypothesis tests, and instrumentation all consume that signal. Without it, no amount of code reading saves you.

Spend most of your effort here. Be aggressive. Be creative. Do not give up.

### Ways to build one, in this order

1. A failing test at the seam that reaches the bug: unit, integration, or end-to-end.
2. A curl or HTTP script against a running dev server.
3. A CLI call with a fixture input. Diff stdout against a known-good snapshot.
4. A headless browser script (Playwright or Puppeteer) that drives the UI and asserts on DOM, console, or network.
5. A replayed trace. Save a real request, payload, or event log to disk. Replay it through the code path in isolation.
6. A throwaway harness. Start a minimal subset of the system (one service, mocked dependencies) and call the bug code path once.
7. A property or fuzz loop. If the bug is "sometimes wrong output", run 1000 random inputs and look for the failure.
8. A bisection harness. If the bug appeared between two known states, automate "boot at state X, check, repeat" so that `git bisect run` can drive it.
9. A differential loop. Run the same input through the old and the new version, or two configurations, and diff the outputs.
10. A human-in-the-loop script. Last resort. If a human must click, drive them with [scripts/hitl-loop.template.sh](scripts/hitl-loop.template.sh) so that the loop stays structured. The captured output comes back to you.

Build the right loop, and the bug is 90% fixed.

### Tighten the loop

Treat the loop as a product. When you have a loop, tighten it:

- Make it faster. Cache the setup, skip unrelated init, narrow the test scope.
- Make the signal sharper. Assert on the exact symptom, not on "did not crash".
- Make it deterministic. Pin time, seed the RNG, isolate the filesystem, freeze the network.

A 30-second flaky loop is barely better than no loop. A 2-second deterministic loop is tight.

### Non-deterministic bugs

The goal is a higher reproduction rate, not a clean repro. Loop the trigger 100 times, run in parallel, add stress, narrow timing windows, inject sleeps. A 50% flake is debuggable. A 1% flake is not. Raise the rate until it is debuggable.

### When you cannot build a loop

Stop and say so. List what you tried. Ask the user for one of these: access to an environment that reproduces the bug, a redacted captured artifact (HAR file, log dump, core dump, screen recording with timestamps), or permission to add temporary production instrumentation. Do not hypothesise without a loop.

### Done when: a tight loop that goes red

Phase 1 is done when you can name one command (a script path, a test invocation, a curl) that you ran at least once. Show the invocation and its redacted output. The command must be:

- [ ] Red-capable: it drives the real bug code path and asserts the user's exact symptom. It goes red on this bug and green when the bug is fixed. "Runs without error" is not enough.
- [ ] Deterministic: the same verdict on every run. For a flaky bug, a pinned high reproduction rate.
- [ ] Fast: seconds, not minutes.
- [ ] Agent-runnable: you can run it unattended. A human is in the loop only through the HITL script.

If you catch yourself reading code to build a theory before this command exists, stop. That jump is the failure this skill prevents. No red-capable command, no Phase 2.

## Phase 2: Reproduce and minimise

Run the loop. Watch it go red.

Make sure that:

- [ ] The loop produces the failure the user described, not a nearby failure. Wrong bug, wrong fix.
- [ ] The failure reproduces across several runs, or at a rate high enough to debug against.
- [ ] You captured the exact symptom (error message, wrong output, timing) so that Phase 5 can prove the fix.

### Minimise

Shrink the repro to the smallest scenario that still goes red. Cut inputs, callers, configuration, data, and steps one at a time. Run the loop after each cut. Keep only what the failure needs.

A minimal repro shrinks the hypothesis space in Phase 3 and becomes the regression test in Phase 5.

Done when every remaining element is load-bearing: removing any one makes the loop go green. Do not continue until you reproduced and minimised.

## Phase 3: Hypothesise

Write 3 to 5 ranked hypotheses before you test any of them. A single hypothesis anchors on the first plausible idea.

Each hypothesis must be falsifiable. State its prediction: "If X is the cause, then changing Y makes the bug disappear, or changing Z makes it worse." If you cannot state the prediction, the hypothesis is a vibe. Discard it or sharpen it.

Show the ranked list to the user before you test. They often re-rank it at once ("we deployed a change to #3 yesterday") or have ruled some out. Do not block on it. If the user is away, continue with your ranking.

## Phase 4: Instrument

Each probe maps to one prediction from Phase 3. Change one variable at a time.

Tool preference:

1. A debugger or REPL, if the environment supports it. One breakpoint beats ten logs.
2. Targeted logs at the boundaries that separate the hypotheses.
3. Never "log everything and grep".

Tag every debug log with a unique prefix, for example `[DEBUG-a4f2]`. Cleanup becomes one grep. Untagged logs survive. Tagged logs die.

Performance branch: for a regression, logs are usually the wrong tool. Establish a baseline measurement first (a timing harness, `performance.now()`, a profiler, a query plan). Then bisect. Measure first, fix second.

## Phase 5: Fix and regression test

Write the regression test before the fix, but only at a correct seam.

A correct seam is one where the test exercises the real bug pattern as it occurs at the call site. If the only seam is too shallow (a single-caller test when the bug needs several callers, a unit test that cannot replicate the chain), a test there gives false confidence.

If no correct seam exists, that is itself a finding. Record it. The architecture prevents the bug from being locked down. Report it to the user, and name `design-an-interface` (for the seam) or `census` (for the ledger) as the flow that owns it.

If a correct seam exists:

1. Turn the minimised repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Run the Phase 1 loop against the original, un-minimised scenario.

## Phase 6: Cleanup

Required before you declare done:

- [ ] The original repro no longer reproduces. Run the Phase 1 loop again.
- [ ] The regression test passes, or the absence of a seam is recorded.
- [ ] All `[DEBUG-...]` instrumentation is removed. Grep the prefix.
- [ ] Every throwaway file you created (harness, script, fixture) is listed for the user with a proposal: delete it, or move it to a marked debug location. Do not delete without an explicit yes.
- [ ] The confirmed hypothesis is written down for the commit message, so that the next debugger learns. Do not commit unless the user asks.

---

<sub>Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) `diagnosing-bugs` (MIT), rewritten in plain English. Changed: throwaway files are listed for the user instead of deleted, and the hypothesis is handed over for the commit instead of committed. See [the evaluation](../../docs/notes/mattpocock-skills-eval.md).</sub>
