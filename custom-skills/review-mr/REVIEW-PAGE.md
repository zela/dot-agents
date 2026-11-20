# Review page

The review page is an optional view of `docs/mr-<IID>-review-comments.md`. It shows one card for each paste-ready comment, with a copy button and two ticks: "Posted" and "Skipped". One tick clears the other. The ticks stay in the browser of the viewer. The review file stays the source of truth. The page is a copy of the file. After each edit of the file, rebuild the page.

The page needs a host that publishes artifact pages (the `Artifact` tool in Claude Code). On another host, do not offer it.

## Build

1. Copy [review-page.html](review-page.html) to the temporary directory of the session as `mr-<IID>-review.html`.
2. Set the `<title>` to `MR !<IID> review`.
3. Replace the whole JSON in `<script id="review-data">` with the data from the review file. Use the contract below. Inside JSON strings, write `<\/` for every `</`.
4. Change nothing else in the template.

## Data contract

- `iid`, `title`, `url`: the MR IID, the MR title, and `web_url`.
- `head`: the first 8 characters of `HEAD_SHA`.
- `state`: one short line, for example `Open` or `Merged 12 Nov 2026, 12:56 UTC`.
- `note`: one sentence for the reader. If the MR is merged, say that the comments are follow-up material.
- `threads[]`: one item for each `## Existing threads` entry.
  - `title`: the one-line claim. `url`: the thread link. `anchor`: `file:line`. Omit `anchor` for a general thread.
  - `status`: the **Status** value. `action`: the **Action** value, without the reply.
  - `reply`: the reply text. If the action is not Reply, omit `reply`. Only a thread with a reply gets a copy button and ticks.
- `findings[]` and `spec[]`: one item for each finding block.
  - `n`: the block number (`1`, `S1`). `sev`: `bug`, `risk`, `style` or `clean` for 🐛 ⚠️ 🎨 🧹, and `spec` for a spec finding. `grade`: `Blocker`, `Major` or `Minor`.
  - `title`: the block title. `anchor`: `file:line`, or `<file> (general note)`.
  - `comment`: the **Comment** text verbatim, without the `> ` prefix. The copy button copies this string as Markdown, so keep the backticks.
  - `why`: the grade paragraph, shortened to its evidence. `fix`: the **Fix** text. Both are optional.
- `specNote`: the paragraph under `## Spec` that states the spec source and the parts of the spec that this repo cannot test.
- `bar`: the post bar grade.
- `held[]`: one string for each `## Held back` line, without the `- ` prefix.
- `checked[]`: one string for each "Checked, not an issue" entry.
- `reviewFile`: `docs/mr-<IID>-review-comments.md`.

The page shows backtick spans as code and escapes all other text. Use no other Markdown.

## Publish

- **First publish:** publish the file with the `code` icon and a one-sentence description. Then add `- Review page: <url>` to the header of the review file, below `- Reviewed head:`.
- **Same session:** publish the same file path again. The URL stays the same.
- **Later session or re-review:** take the URL from the `- Review page:` line. Read the artifact. Then publish with that `url`, so that the link that the user has stays valid. The ticks survive, because the page stores them for each MR in the browser of the viewer. A renumbered finding loses its tick.

The page is private. Tell the user that only the people that they share it with can open it.
