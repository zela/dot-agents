---
name: cross-engine-check
description: Observe a specific CSS or layout claim in Firefox, WebKit and Chromium instead of inferring it from spec knowledge. Use when a claim rests on how an engine renders or parses something — vendor prefixes, form control internals, focus rings, flex/grid edge cases, `-moz-`/`-webkit-` behaviour — or when a review says "this breaks in Firefox/Safari" and nobody ran it there.
---

Cross-engine claims are usually reasoned, not observed. That is the weakest kind of claim and this skill exists to convert one into the other. You are measuring, not arguing.

## 1. Make the claim testable

Restate it as: **element** + **observable** + **engines** + **the difference that would confirm it**.

> "The focus ring is invisible in Firefox" → element: `.button:focus-visible`; observable: computed `outline-color` / `outline-style`; engines: firefox vs chromium; confirms if Firefox reports `outline-style: none` while Chromium reports a visible ring.

If you cannot name the observable, say so and stop. "Looks broken" is not testable — ask what should be measured.

## 2. Build the smallest repro that still exercises the claim

Prefer, in order:

1. **A standalone HTML file** in the scratch dir with just the markup and CSS in question, copied verbatim from the source. Fastest, and it isolates the claim from app state.
2. **The project's own browser-test runner**, if one exists (`vitest --config vitest.browser.config.ts`, `playwright test`) — use it when the claim depends on component logic, not just CSS.
3. **The running dev server** — only when the claim depends on real data, auth, or routing.

Copy the CSS exactly. Retyping it from memory tests your memory, not the engine. If the rule comes from a CSS Module or a built stylesheet, take the emitted value, since that is what ships.

## 3. Make sure the engines exist before blaming them

```bash
npx playwright install firefox webkit    # idempotent; skips what is present
```

A missing browser fails in a way that reads like a rendering difference. Check first.

## 4. Measure

Drive all engines in one script so they share the page and differ only in engine:

```js
// scratch/check.mjs — run: node scratch/check.mjs
import { chromium, firefox, webkit } from 'playwright';

const url = 'file://' + new URL('./repro.html', import.meta.url).pathname;

for (const [name, type] of [['chromium', chromium], ['firefox', firefox], ['webkit', webkit]]) {
  const browser = await type.launch();
  const page = await browser.newPage();
  await page.goto(url);
  const observed = await page.evaluate(() => {
    const el = document.querySelector('.target');
    const cs = getComputedStyle(el);
    return { outlineStyle: cs.outlineStyle, outlineColor: cs.outlineColor, width: el.getBoundingClientRect().width };
  });
  console.log(name, observed);
  await browser.close();
}
```

Reach for the cheapest observable that settles it:

| Question | Observable |
| --- | --- |
| Did the engine parse the declaration at all? | Set it via `el.style.foo = '...'` and read `el.style.foo` back — an engine that rejects the value returns `''` |
| Is the rule in the cascade? | `getComputedStyle(el).prop` |
| Is the box the wrong size or place? | `el.getBoundingClientRect()` |
| Does it overflow? | `el.scrollWidth > el.clientWidth` |
| Is a UA-internal part different? | `getComputedStyle(el, '::-moz-focus-inner')` and friends |
| Nothing numeric captures it | Screenshot — last resort |

Computed values beat screenshots. They say *what* differs, survive font-rendering noise between engines and machines, and do not need a baseline.

## 5. Report

A table of engine → observed value, the exact command you ran, and a verdict:

- **OBSERVED** — the difference is real, with the numbers.
- **NOT OBSERVED** — all engines agree. Say so plainly; a killed cross-engine claim is a good outcome.
- **DIFFERENT CAUSE** — something does differ, but not for the reason claimed. Give the measurement, not a new theory.

Then: is the difference *visible to a user*? A 0.5px sub-pixel delta and a dropped focus ring are both "a difference"; only one is a bug. State which this is.

Never report an engine you did not launch. If WebKit would not install, the answer for WebKit is "not run", not an inference from Safari's release notes.

## Cleanup

Leave the scratch files. Say where they are so the check can be re-run — deleting them makes the result unreproducible, and deletion is the user's call.
