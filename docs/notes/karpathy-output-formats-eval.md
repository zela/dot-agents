# Evaluating Karpathy's output-format ladder

Source: a post by Andrej Karpathy, evaluated 2026-11-08. Its thesis: as agents do more of the work, more of our time goes to understanding their output. Cheap code makes large, throwaway artifacts worth building for one question. He proposes a ladder of output formats, each better than the last:

1. Text in ASD-STE100 (Simplified Technical English), softened to "80% of the way".
2. A diagram instead of prose.
3. An interactive HTML page.
4. A bespoke explainer video (3Blue1Brown style, narrated with ElevenLabs).

## Verdict: tiers 1–3 are already in the kit; skip tier 4; test one new use of tier 3

The kit already has the capabilities. What it lacks is a trigger: nothing reaches for a richer format when the job is oversight of agent work.

## Tier by tier

- **Tier 1: STE text. Covered.**
  - `simple-english` implements ASD-STE100. Its default Plain mode is close to Karpathy's "80%". Strict mode adds the full dictionary on request.
  - Its description scopes it to technical documents and excludes chat-style rewriting. So it does not fire on "explain X to me". Ask for "plain STE" explicitly when you want it in a reply. No change needed.
- **Tier 2: diagrams. Covered.**
  - `archify`, `beautiful-mermaid` (passive), Figma `generate_diagram`, Excalidraw (connector present, not authenticated).
  - Constraint: diagrams in Markdown code blocks must stay narrow. HTML diagrams escape that limit.
  - See [Diagram tooling](#diagram-tooling) for a slimmer default than archify.
- **Tier 3: HTML pages. Capability covered, trigger missing.**
  - The Artifact tool, the `prototype` LOGIC branch and archify all produce HTML.
  - Review and verify skills (`review-staged`, `code-review`, `doc-check`, `ship-session`) report in text only.
  - See [HTML page candidates](#html-page-candidates).
- **Tier 4: explainer video. Skip.**
  - No tooling: `manim` and `ffmpeg` are not installed (executed: `command -v`).
  - ElevenLabs costs money and rendering takes minutes. Under `AGENTS.md` each video is a heavy operation that needs per-run permission.
  - For oversight, video is the worst format. It is linear. You cannot search it, diff it, cite `file:line` in it, or check it against the code. It suits learning a concept, which `teach` already covers.

## The risk the post omits

A richer format raises persuasiveness, not correctness. A polished page of inferred claims reads like executed fact, which defeats Evidence Discipline in `AGENTS.md`. An explainer is itself agent output that needs oversight.

Any page built for oversight therefore follows these rules:

- Build it from evidence: the diff, test output, command receipts, `file:line`.
- Keep the executed / inferred / assumed label on each claim.
- Generate it in a subagent. Pages are large: the two `skill-flow` renders are 614 KB and 805 KB (executed: `ls`). They must not sit in the main context.
- Make it work at phone width.
- Put a throwaway page in the scratchpad or an Artifact. Put a page that describes the system under `docs/`, as `docs/notes/diagrams/` already does.
- Expect portability limits. The Artifact tool and its comments exist only in Claude Code. In Codex or Gemini, the same page is a local HTML file opened in a browser.

## Diagram tooling

Archify is heavy (executed: `du`, `ls`, read `SKILL.md`):

- The skill is 8.4 MB, with a 16 KB `SKILL.md`.
- Every output embeds a 757 KB `template.html`.
- An edit means: change the typed JSON, run `validate`, repair geometry diagnostics, run `deliver`.
- It runs an update checker against a remote manifest on each use.

It earns that weight for showcase maps that need validated layout, views and export, such as the `skill-flow` diagrams. It is too much for a quick diagram you want to tweak.

Slimmer options:

- **Mermaid in a single HTML file. Adopted as the Mermaid branch of the `diagram` skill.**
  - The page holds the Mermaid source in `<pre class="mermaid">` blocks and loads `mermaid@12.2.0` from jsDelivr. The template is 3.7 KB (executed: `wc -c`).
  - To adjust a diagram, edit a line of text and reload.
  - Mermaid 12.0.0 (September 2026) bundles ELK and makes it the default layout, and adds the `redux-color` and `redux-dark-color` themes (executed: read the GitHub release notes). The separate `@mermaid-js/layout-elk` plugin is no longer needed. This closes much of the layout gap to archify and D2.
  - Tested in Playwright (executed): both example diagrams render in light and dark at 390 px and 1280 px. A theme change re-renders. A syntax error draws an error box with the line number and leaves the other figures intact. A `layout: dagre` config block parses.
  - Mermaid code blocks also render natively in GitHub and GitLab Markdown (from memory, not checked here). The same source then works in a page and in a doc.
  - `beautiful-mermaid` (passive) renders the same source to static themed SVG or ASCII, when a page must have no JavaScript.
- **D2. Not needed now; install when a diagram earns it.** Facts from d2lang.com (read by a subagent):
  - Strengths: dagre, ELK and TALA layout engines; adaptive dark theme in one SVG through a flag; SVG, PNG without a browser, PDF, PPTX and GIF export; a watch mode that live-reloads a browser preview; layers, scenarios and steps, exported as one animated SVG; sequence, UML class and SQL-table shapes; Markdown and LaTeX text; offline CLI.
  - Costs: a binary on every workstation, which `upstream-tools.txt` would have to pin. The docs do not mention native rendering on GitHub or GitLab, so the workflow is to commit the rendered SVG next to the `.d2` source. TALA's licensing is not stated on the pages read. A browser build exists (D2.js, WebAssembly); its package and status were not confirmed.
  - Verdict: Mermaid 12 with ELK covers the quick, editable case without an install. Reach for D2 when a diagram needs animated steps across boards, an SVG without JavaScript that adapts to dark mode, or a layout Mermaid renders badly.
- **D2, follow-up. Adopted as the D2 branch of the `diagram` skill** after the user installed `d2` v0.9.0. Tested locally (executed):
  - `dagre`, `elk` and `tala` are all bundled. TALA rendered with no visible watermark. Its licence terms are still unconfirmed.
  - With `--dark-theme`, one SVG switches theme with the reader's color scheme, also inside an `<img>` tag. Output files were 13–17 KB with fonts embedded.
  - A left-to-right diagram shrinks to unreadable labels at 390 px. `direction: down` reads well. TALA picked a vertical layout on its own.
  - ASCII output with ELK stays about 20 columns wide for a vertical diagram, so it fits Markdown code blocks on a narrow screen.
  - `steps` with `--animate-interval` produces one animated SVG.
- **Archify archived.** The `diagram` skill covers the quick case (Mermaid) and the committed and showcase case (D2). Its line in `upstream-sources.txt` is commented out, with a note on how to restore it to re-render `docs/notes/diagrams/`.
- **Hand-written inline SVG.** No dependencies. The harness `artifact-diagramming` skill covers it. Adjusting means editing coordinates, so it suits small fixed pictures.
- **Excalidraw.** Adjust by dragging rather than by text. Needs the connector authenticated.

## HTML page candidates

Ranked by fit with the kit:

- **1. Branch walkthrough for oversight. Experiment first.**
  - After a large branch or a `parallel-sessions` wave, a page groups the diff by intent. It shows each change with `file:line`, the test and lint receipts, and the open risks, each claim labelled.
  - It answers Karpathy's actual problem: understanding what the agent did.
  - It would sit as an optional step after `review-staged` or in `ship-session`.
- **2. Review findings with per-finding comments. Experiment second.**
  - A review publishes its findings as an Artifact. You comment on each one: fix, skip, or why. The session reads the comments through `ArtifactComments` and applies them.
  - It replaces copy-pasting between findings and chat. `review-mr` already produces per-comment output, so the shape fits.
  - Claude Code only.
- **3. Interactive concept explainer. Use ad hoc.**
  - A simulation for learning, for example a consistent-hashing ring or a token bucket for `system-design-mentor` or `teach`. This is Karpathy's main use.
  - The page explains a concept, not agent output, so the evidence risk is lower. No skill change is needed: ask for it.
- **4. State-machine playground. Already exists** as the `prototype` LOGIC branch.
- **5. Wave dashboard. Only for large waves.**
  - One page shows the session docs, worktree status and acceptance checks for a `parallel-sessions` wave.
  - The session docs stay the source of truth. Generate the page on demand and discard it. It is worth it only at three or more sessions.
- **6. Design-option comparison. Low.** `design-a-feature` gives options on paper and `prototype` UI makes them runnable. A static comparison page adds little over Markdown.
- **7. Ledger viewers for `census` or papercuts. Skip.** The Markdown ledger is the source of truth. A viewer duplicates it and goes stale.
- **8. Eval charts. Ad hoc.** Only when `craft-evals` or `model_evaluation` produce numbers across iterations.
- **9. Persistent dashboards with a database. Skip.** The kit has no live data to show.

## Outcome

- Added the `diagram` skill with two branches: a Mermaid single-file page for a quick diagram, and a D2 render for a diagram committed next to a doc, ASCII, exports and animation. It started as two skills, `mermaid-page` and `d2-diagram`. They were merged because the split is by what the user needs, not by tool, and two tool-named descriptions had to route to each other. Archived `archify`.
- Saved HTML page candidates 1, 2, 3 and 5 to [`docs/ideas.md`](../ideas.md), each with its next step.
- Next step: run candidate 1 on the next large branch, then candidate 2 on the next review. If either beats the text output twice, fold it into `ship-session` or the review skills.
