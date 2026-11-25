# User-invoked skills and plugin commands

The model cannot start these on its own. They do not appear in the model's skill list, so nothing reminds you of them. Start each one by naming it. The last section lists skills that the model can start but sees only by name.

Source: skills with `disable-model-invocation: true` in `custom-skills/` and the mattpocock upstream skills, and the `commands/` of installed plugins. Snapshot taken 2026-11-24.

## Skills

- Design and planning
  - `domain-modeling`: build and sharpen the domain glossary in `CONTEXT.md`, for a glossary job too large for `grill-me`. `grill-me` already collects the terms that a session settles and offers to write them.
  - `design-an-interface`: generate several radically different shapes for a module or API ("design it twice").
  - `design-a-feature`: generate radically different UI/UX designs for one feature by varying the interaction pattern.
  - `prototype`: build a throwaway prototype to answer a design question about a state model, logic, or UI.
  - `to-questionnaire`: turn a decision you cannot answer alone into a questionnaire for someone else.
  - `system-design-mentor`: system design mentoring, as a teachable moment or a mock interview.
- Review
  - `review-staged`: review the staged diff or a named branch range, verify each finding, fix the survivors, commit granularly.
  - `review-mr`: review a GitLab MR branch against its target and save ready-to-paste MR comments in `docs/`.
  - `third-opinion`: get a second review from another provider's CLI (Codex, Claude, or Copilot).
  - `census`: review a whole repo for standing risk and debt, kept as a reconciled ledger under `docs/census/`.
  - `complexity-optimizer`: find algorithmic hotspots (O(n²), N+1 queries, repeated scans) and report or fix them.
- Long work and sessions
  - `run-state`: run a long, many-step procedural task with progress kept in an external state file, so you can clear and resume.
  - `ship-session`: close out a finished plan session: check the gates, turn the session doc into an as-built reference, commit.
  - `handoff`: compact the conversation into a handoff document for another agent.
- Learning and explanation
  - `wtf`: explain the last message, or a file, link, or passage, in plain language.
  - `teach`: teach you a new skill or concept inside this workspace.
  - `grammar-tutor`: grammar help, style evaluation, and English tutoring.
- Housekeeping
  - `papercuts`: work through `~/.papercuts/log.md`: cluster papercuts into root-cause families, verify them, fix the ones you pick.

## Plugin commands

These come from `claude-plugins-official` and run only in Claude Code. A disabled plugin must be enabled with `/plugin` before its commands work.

- `claude-md-management` (enabled)
  - `/revise-claude-md`: update `CLAUDE.md` with what this session taught.
- `claude-code-setup` (disabled)
  - `claude-automation-recommender` skill: recommend hooks, subagents, skills, plugins, and MCP servers for a codebase.
- `hookify` (disabled)
  - `/hookify`: create hooks that block unwanted behavior, from the conversation or from explicit rules.
  - `/hookify:list`, `/hookify:configure`, `/hookify:help`: list, toggle, and explain the rules.
- `code-review` (disabled)
  - `/code-review`: review a pull request.
- `pr-review-toolkit` (disabled)
  - `/review-pr`: thorough PR review with specialized agents.
- `feature-dev` (disabled)
  - `/feature-dev`: guided feature development that studies the codebase and architecture first.
- `code-modernization` (disabled)
  - `/modernize`: start here. Say what you want done with legacy code and get the plan and the first step.
  - `/modernize-status`: show progress, stale steps, and the next command.
  - The other `/modernize-*` commands cover the phases: preflight, assess, map, extract-rules, review, brief, harden, transform, uplift, reimagine, verify.
- `cloudflare` (disabled)
  - `/build-agent`: build an AI agent on Cloudflare with the Agents SDK.
  - `/build-mcp`: build a remote MCP server on Cloudflare.
- `sourcegraph` (disabled)
  - `/sg-search`: search Sourcegraph with natural language or keywords.
  - `/sg-file`: read and summarize a file from Sourcegraph.

## Name-only listed skills

`skillOverrides` in `~/.claude/settings.json` sets these to `"name-only"`. The model sees only the name, not the description. It can still start them, but it rarely will. Name the skill when you want it.

- Documents and files
  - `anthropic-skills:pdf`: read, extract, merge, split, fill, OCR, or create PDFs.
  - `anthropic-skills:docx`: create, read, or edit Word documents and templates.
  - `anthropic-skills:xlsx`: open, edit, clean, or create spreadsheets (`.xlsx`, `.csv`, `.tsv`), with formulas and charts.
  - `anthropic-skills:pptx`: create, read, or edit PowerPoint decks.
  - `anthropic-skills:theme-factory`: apply one of 10 preset themes, or a generated one, to slides, docs, or HTML pages.
- Research and learning
  - `anthropic-skills:deep-research`: research a topic across many sources and write a narrative report.
  - `anthropic-skills:learn`: learn how or why something works: explain, ELI5, walk-through, quiz, flashcards. It is a different skill from `teach`.
- Desktop and browser
  - `anthropic-skills:computer-use`: control apps on your own computer through screenshots, clicks, and typing.
  - `anthropic-skills:built-in-browser`: use the browser pane inside the Claude desktop app.
- Other
  - `dataviz`: chart and dashboard guidance for Artifacts: chart form, honest encodings, finding-first titles, filter rows. It is bundled inside the Claude Code binary, so it has no `SKILL.md` on disk.
  - `anthropic-skills:google-workspace`: set in `skillOverrides`, but not in the current claude.ai sync, so it is not available now.

The same block sets these to `"off"`: `skill-creator`, `chrome-browser`, `web-artifacts-builder`, `morning`, `docs`, `import-memory` (all `anthropic-skills:`). Change the value to `"name-only"` or remove the entry to use one.

## Refresh this list

- Skills: `grep -rl --include=SKILL.md "disable-model-invocation: *true" ~/.agents/skills`
- Name-only and off skills: the `skillOverrides` block in `~/.claude/settings.json`
- Synced skill descriptions: `~/.claude/skills/synced/*/manifest.json`
- Plugin commands: `find ~/.claude/plugins/cache -path "*/commands/*.md"`
- Plugin state: the `enabledPlugins` block in `~/.claude/settings.json`
