---
name: diagram
description: 'Make a diagram from text: a quick Mermaid page the user edits and reloads, or a D2 render committed next to a doc (an SVG that follows light and dark mode, ASCII for Markdown, PNG, PDF, PPTX, animated steps). Use to visualize architecture, a flow, a call sequence, a state machine, a data model, or how code or a system works.'
---

# Diagram

The text is the source, and the picture is rebuilt from it. To change a diagram, edit the text.

## Pick the branch

- **Mermaid page** → [MERMAID.md](MERMAID.md). A quick diagram the user looks at now and adjusts by editing text and reloading. One small HTML file, no install.
- **D2 render** → [D2.md](D2.md). A diagram committed next to a doc, ASCII for a Markdown code block, a PNG, PDF or PPTX export, an animation across steps, or an architecture map that needs the best layout. Needs the `d2` CLI. If `d2 version` fails, tell the user and take the Mermaid branch.

If the user does not say and is away, take the Mermaid branch for a throwaway diagram and the D2 branch for one that goes under `docs/`. State the assumption.

## Rules for both branches

1. **Location.** A throwaway diagram for one question goes in the scratchpad. A diagram that describes the system goes under `docs/`, next to the document that links to it.
2. **Top to bottom.** The user reads on a phone, and a left-to-right diagram shrinks until its labels are unreadable. Use `flowchart TD` in Mermaid and `direction: down` in D2.
3. **About 15 nodes per diagram.** Split a larger picture into several diagrams.
4. **Colors come from the theme.** Each branch picks a light and a dark theme from the reader's color scheme. An explicit fill or stroke color stays the same in both modes and can break the dark one.
5. **Ground it.** If the diagram shows real code, read that code first. Name the source files next to the diagram. Mark an edge or a node you inferred but did not see in the code.
6. **Check the render.** Open the result in a browser tool if the host has one. Look at it in light and dark mode and at phone width. The diagram is done when every node and label is readable in both modes; each branch adds its own check. If the host has no browser tool, give the user the file path and say that the render is unchecked.
