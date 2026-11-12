# Review page

The review page is an optional view of `docs/mr-<IID>-review-comments.md`. It shows one card per paste-ready comment, with a copy button and two ticks: "Posted" and "Skipped". One tick clears the other. The ticks stay in the viewer's browser. The review file stays the source of truth. The page is a copy of the file, so rebuild the page after each edit of the file.

The page needs a host that publishes artifact pages (the `Artifact` tool in Claude Code). On another host, do not offer it.

## Build

1. Copy [review-page.html](review-page.html) to the session's temp dir as `mr-<IID>-review.html`.
2. Set the `<title>` to `MR !<IID> review`.
3. Replace the whole JSON in `<script id="review-data">` with the data from the review file. Use the contract below. Inside JSON strings, write `<\/` for every `</`.
4. Change nothing else in the template.

## Data contract

- `iid`, `title`, `url`: the MR IID, the MR title, and `web_url`.
- `head`: the first 8 characters of `HEAD_SHA`.
- `state`: one short line, for example `Open` or `Merged 12 Nov 2026, 12:56 UTC`.
- `note`: one sentence for the reader. If the MR is merged, say that the comments are follow-up material.
- `threads[]`: one item per `## Existing threads` entry.
  - `title`: the one-line claim. `url`: the thread link. `anchor`: `file:line`, or leave it out for a general thread.
  - `status`: the **Status** value. `action`: the **Action** value, without the reply.
  - `reply`: the reply text, only when the action is Reply. Only a thread with a reply gets a copy button and ticks.
- `findings[]` and `spec[]`: one item per finding block.
  - `n`: the block number (`1`, `S1`). `sev`: `bug`, `risk`, `style` or `clean` for 🐛 ⚠️ 🎨 🧹, and `spec` for a spec finding.
  - `title`: the block title. `anchor`: `file:line`, or `<file> (general note)`.
  - `comment`: the **Comment** text verbatim, without the `> ` prefix. The copy button copies this string as Markdown, so keep the backticks.
  - `why`: the severity paragraph, shortened to its evidence. `fix`: the **Fix** text. Both are optional.
- `specNote`: the paragraph under `## Spec` that states the spec source and what this repo cannot check.
- `checked[]`: one string per "Checked, not an issue" entry.
- `reviewFile`: `docs/mr-<IID>-review-comments.md`.

The page renders backtick spans as code and escapes all other text. Use no other Markdown.

## Publish

- **First publish:** publish the file with the `code` icon and a one-sentence description. Then add `- Review page: <url>` to the header of the review file, below `- Reviewed head:`.
- **Same session:** publish the same file path again. The URL stays the same.
- **Later session or re-review:** take the URL from the `- Review page:` line. Read the artifact, then publish with that `url`, so that the link the user already has stays valid. The ticks survive, because they are stored per MR in the viewer's browser. A renumbered finding loses its tick.

The page is private. Tell the user that only people they share it with can open it.
