# Mermaid page

The page is the source. Each diagram is Mermaid text inside the HTML, and the browser renders it on load. The template is about 4 KB and has no build step. The shared rules are in [SKILL.md](SKILL.md).

## Steps

1. **Copy** [`assets/mermaid-template.html`](assets/mermaid-template.html) to the location.
2. **Set the frame.** Replace the `<title>`, the `<h1>` and the lede sentence. Keep one `<figure>` per diagram and remove the example figures.
3. **Write each diagram** inside `<pre class="mermaid">`.
   - Write `<` as `&lt;` and `&` as `&amp;`. The browser decodes them before Mermaid reads the text.
   - Leave the theme to the page. It picks `redux-color` or `redux-dark-color` from the reader's color scheme.
   - Name the source files in the `<figcaption>`.
4. **Check the render.** In addition to the shared check: each figure holds an SVG, and no SVG has `aria-roledescription="error"`. A syntax error draws a "Syntax error in text" box with the line number; fix that line and reload.

In Claude Code, the Artifact tool can publish the page as a private link.

## Mermaid 12 notes

The template pins `mermaid@12.2.0`. To upgrade, change the one import URL.

- ELK is the default layout for flowchart, state, class and ER diagrams. To get the older dagre layout for one diagram, start it with a config block:

  ```
  ---
  config:
    layout: dagre
  ---
  flowchart TD
  ```

- The page shrinks a wide diagram to fit, down to 60% of its natural size. Past that, the diagram scrolls inside its figure, so labels stay readable on a phone.
