// Download every claude.ai conversation via a Playwright-driven Chrome.
//
// Usage: node scripts/claude-export/run-playwright.mjs [OUT_DIR]
//
// Opens a visible Google Chrome window with its own persistent profile (OUT_DIR/.chrome-profile).
// Log in to claude.ai in that window once (email + emailed code). Landing on the onboarding
// form is fine; the API works regardless. The script detects the session and then fetches
// each conversation through the page, so the request carries the real browser cookies.
// Re-running skips conversations whose file already has the same updated_at.

import fs from "node:fs/promises";
import path from "node:path";
import os from "node:os";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const { chromium } = require("/Users/amo/.npm/_npx/9833c18b2d85bc59/node_modules/playwright");

const ORG = "0f0e3f07-39e6-482d-9e74-1f558db07b55";
const OUT = path.resolve(process.argv[2] || path.join(os.homedir(), "Downloads", "claude-chats"));
const PROFILE = path.join(OUT, ".chrome-profile");
const DELAY_MS = 1500;
const MAX_RETRIES = 6;
const LOGIN_TIMEOUT_MS = 30 * 60 * 1000;

const base = `/api/organizations/${ORG}/chat_conversations`;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const log = (...a) => console.log(new Date().toISOString().slice(11, 19), ...a);

await fs.mkdir(OUT, { recursive: true });
const context = await chromium.launchPersistentContext(PROFILE, {
  channel: "chrome",
  headless: false,
  viewport: null,
});
const page = context.pages()[0] || (await context.newPage());

// Runs inside the page: returns {status, body} so that Node decides about retries.
async function apiGet(url) {
  return page.evaluate(async (u) => {
    const r = await fetch(u, { credentials: "include" });
    const text = await r.text();
    return { status: r.status, retryAfter: r.headers.get("retry-after"), text };
  }, url);
}

async function getJson(url) {
  for (let attempt = 0; ; attempt++) {
    const r = await apiGet(url);
    if (r.status === 200) return JSON.parse(r.text);
    const retryable = r.status === 429 || r.status >= 500;
    if (!retryable || attempt >= MAX_RETRIES) {
      throw new Error(`HTTP ${r.status} for ${url}: ${r.text.slice(0, 200)}`);
    }
    const ra = Number(r.retryAfter);
    const wait = ra > 0 ? ra * 1000 : Math.min(60000, 5000 * 2 ** attempt);
    log(`HTTP ${r.status}; waiting ${wait / 1000}s (retry ${attempt + 1}/${MAX_RETRIES})`);
    await sleep(wait);
  }
}

// --- wait for login ----------------------------------------------------------------
await page.goto("https://claude.ai/login", { waitUntil: "domcontentloaded" });
log("Chrome is open. Log in to claude.ai in that window. Waiting for a session...");
const deadline = Date.now() + LOGIN_TIMEOUT_MS;
for (;;) {
  let status = 0;
  try {
    status = (await apiGet("/api/organizations")).status;
  } catch {
    // page navigating; try again
  }
  if (status === 200) break;
  if (Date.now() > deadline) {
    log("no session after 30 minutes; giving up");
    await context.close();
    process.exit(2);
  }
  await sleep(3000);
}
log("session detected");

// --- download ----------------------------------------------------------------------
const list = await getJson(base);
await fs.writeFile(path.join(OUT, "_list.json"), JSON.stringify(list, null, 2));
log(`${list.length} conversations listed`);

async function existingUpdatedAt(uuid) {
  try {
    return JSON.parse(await fs.readFile(path.join(OUT, `${uuid}.json`), "utf8")).updated_at;
  } catch {
    return undefined;
  }
}

let n = 0, fetched = 0, skipped = 0;
const failed = {};
for (const c of list) {
  n++;
  if ((await existingUpdatedAt(c.uuid)) === c.updated_at) {
    skipped++;
    continue;
  }
  const url = `${base}/${c.uuid}?tree=True&rendering_mode=messages&render_all_tools=true`;
  try {
    const conv = await getJson(url);
    await fs.writeFile(path.join(OUT, `${c.uuid}.json`), JSON.stringify(conv, null, 2));
    fetched++;
    log(`${n}/${list.length} ok   ${c.name}`);
  } catch (e) {
    failed[c.uuid] = e.message;
    log(`${n}/${list.length} FAIL ${c.uuid} ${c.name}: ${e.message}`);
  }
  await sleep(DELAY_MS);
}

log(`done: ${fetched} fetched, ${skipped} already up to date, ${Object.keys(failed).length} failed`);
if (Object.keys(failed).length) {
  await fs.writeFile(path.join(OUT, "_failed.json"), JSON.stringify(failed, null, 2));
  log("failures written to _failed.json; re-run to retry them");
}
await context.close();
