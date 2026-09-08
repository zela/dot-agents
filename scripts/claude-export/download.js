// Download every claude.ai conversation of one organization, one JSON file per conversation.
//
// Run in the browser console (F12) on any https://claude.ai tab while logged in.
// The page must belong to claude.ai so that the session cookie is sent.
//
// Chromium browsers (Arc, Chrome): a folder picker opens; choose ~/Downloads/claude-chats.
// Each conversation is written as <uuid>.json as soon as it arrives. Re-running skips
// files that are already present with the same updated_at, so a run can be resumed
// after a reload, and later runs only fetch new or changed conversations.
//
// Other browsers (Zen, Firefox, Safari): no folder picker. Everything is collected in
// memory and saved as one bundle file into the default download folder at the end.
// to_markdown.py accepts both layouts.
(async () => {
  const ORG = "0f0e3f07-39e6-482d-9e74-1f558db07b55";
  const DELAY_MS = 1500;   // pause between conversations
  const MAX_RETRIES = 6;   // per conversation, on 429 or 5xx

  const base = `/api/organizations/${ORG}/chat_conversations`;
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const state = (window.claudeExport ||= { done: {}, failed: {} });

  async function getJson(url) {
    for (let attempt = 0; ; attempt++) {
      const r = await fetch(url, { credentials: "include" });
      if (r.ok) return r.json();
      const retryable = r.status === 429 || r.status >= 500;
      if (!retryable || attempt >= MAX_RETRIES) {
        throw new Error(`HTTP ${r.status} ${r.statusText} for ${url}`);
      }
      const retryAfter = Number(r.headers.get("retry-after"));
      const wait = retryAfter > 0 ? retryAfter * 1000 : Math.min(60000, 5000 * 2 ** attempt);
      console.warn(`HTTP ${r.status}; waiting ${wait / 1000}s (retry ${attempt + 1}/${MAX_RETRIES})`);
      await sleep(wait);
    }
  }

  // --- storage: folder (File System Access API) or in-memory bundle -------------
  let dir = null;
  if (window.showDirectoryPicker) {
    try {
      dir = await window.showDirectoryPicker({ mode: "readwrite", id: "claude-export" });
      console.log(`writing into folder "${dir.name}"`);
    } catch (e) {
      console.warn(`folder picker unavailable (${e.message}); falling back to a single bundle download`);
    }
  } else {
    console.warn("no folder picker in this browser; falling back to a single bundle download");
  }

  async function existingUpdatedAt(uuid) {
    if (!dir) return state.done[uuid]?.updated_at;
    try {
      const fh = await dir.getFileHandle(`${uuid}.json`);
      const text = await (await fh.getFile()).text();
      return JSON.parse(text).updated_at;
    } catch {
      return undefined;
    }
  }

  async function store(conv) {
    if (!dir) {
      state.done[conv.uuid] = conv;
      return;
    }
    const fh = await dir.getFileHandle(`${conv.uuid}.json`, { create: true });
    const w = await fh.createWritable();
    await w.write(JSON.stringify(conv, null, 2));
    await w.close();
    state.done[conv.uuid] = { updated_at: conv.updated_at };
  }

  function downloadBundle(name, list) {
    const out = {
      exported_at: new Date().toISOString(),
      organization_uuid: ORG,
      listed: list.length,
      conversations: list.map((c) => state.done[c.uuid]).filter((c) => c && c.chat_messages),
    };
    const blob = new Blob([JSON.stringify(out, null, 2)], { type: "application/json" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = name;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(a.href), 10000);
    return out.conversations.length;
  }

  // --- main loop -------------------------------------------------------------------
  const list = await getJson(base);
  console.log(`${list.length} conversations listed`);
  if (dir) {
    const fh = await dir.getFileHandle("_list.json", { create: true });
    const w = await fh.createWritable();
    await w.write(JSON.stringify(list, null, 2));
    await w.close();
  }

  let n = 0, fetched = 0, skipped = 0;
  for (const c of list) {
    n++;
    if ((await existingUpdatedAt(c.uuid)) === c.updated_at) {
      skipped++;
      continue;
    }
    const url = `${base}/${c.uuid}?tree=True&rendering_mode=messages&render_all_tools=true`;
    try {
      await store(await getJson(url));
      delete state.failed[c.uuid];
      fetched++;
      console.log(`${n}/${list.length} ok   ${c.name}`);
    } catch (e) {
      state.failed[c.uuid] = e.message;
      console.error(`${n}/${list.length} FAIL ${c.uuid} ${c.name}: ${e.message}`);
    }
    await sleep(DELAY_MS);
  }

  const failed = Object.keys(state.failed).length;
  if (dir) {
    console.log(`done: ${fetched} fetched, ${skipped} already up to date, ${failed} failed.`);
  } else {
    const stamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, "-");
    const saved = downloadBundle(`claude-conversations-${stamp}.json`, list);
    console.log(`done: ${saved}/${list.length} saved in bundle, ${failed} failed.`);
  }
  if (failed) {
    console.log("failed:", state.failed, "\nRe-run this script to retry only the failures.");
  }
})();
