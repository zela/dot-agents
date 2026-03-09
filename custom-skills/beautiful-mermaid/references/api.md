# beautiful-mermaid Full API Reference

## Types

```typescript
type DiagramColors = {
  bg: string
  fg: string
  line?: string
  accent?: string
  muted?: string
  surface?: string
  border?: string
}

type RenderOptions = DiagramColors & {
  font?: string            // Default: 'Inter'
  transparent?: boolean    // Default: false
  padding?: number         // Default: 40 (px)
  nodeSpacing?: number     // Default: 24
  layerSpacing?: number    // Default: 40
  componentSpacing?: number // Default: 24
  thoroughness?: number    // Default: 3 (range: 1-7, crossing minimization)
  interactive?: boolean    // Default: false (XY chart hover tooltips)
}

type AsciiTheme = {
  // Custom color overrides for ASCII output
  [key: string]: string
}

type AsciiRenderOptions = {
  useAscii?: boolean        // Default: false (use Unicode box-drawing)
  paddingX?: number         // Default: 5
  paddingY?: number         // Default: 5
  boxBorderPadding?: number // Default: 1
  colorMode?: 'none' | 'auto' | 'ansi16' | 'ansi256' | 'truecolor' | 'html'
  theme?: Partial<AsciiTheme>
}

type MermaidGraph = {
  // Parsed graph structure returned by parseMermaid()
  // Useful for introspection, not typically needed for rendering
}
```

## All 15 Built-in Theme Keys (for THEMES object)

```typescript
import { THEMES } from 'beautiful-mermaid'

type ThemeKey =
  | 'zinc-light'
  | 'zinc-dark'
  | 'tokyo-night'
  | 'tokyo-night-storm'
  | 'tokyo-night-light'
  | 'catppuccin-mocha'
  | 'catppuccin-latte'
  | 'nord'
  | 'nord-light'
  | 'dracula'
  | 'github-light'
  | 'github-dark'
  | 'solarized-light'
  | 'solarized-dark'
  | 'one-dark'
```

## Color Derivation in Mono Mode

When only `bg` and `fg` are provided, the library auto-derives all diagram
colors using CSS `color-mix()`:

| Visual element | Derivation |
|----------------|------------|
| Text | `--fg` 100% |
| Secondary text | `--fg` 60% into `--bg` |
| Edge labels | `--fg` 40% into `--bg` |
| Faint text | `--fg` 25% into `--bg` |
| Connectors | `--fg` 50% into `--bg` |
| Arrow heads | `--fg` 85% into `--bg` |
| Node fill | `--fg` 3% into `--bg` |
| Group header | `--fg` 5% into `--bg` |
| Inner strokes | `--fg` 12% into `--bg` |
| Node stroke | `--fg` 20% into `--bg` |

## fromShikiTheme

Converts any Shiki (VS Code) theme into `DiagramColors`:

```typescript
import { getSingletonHighlighter, type BundledTheme } from 'shiki'
import { renderMermaidSVG, fromShikiTheme } from 'beautiful-mermaid'

// Works with any of Shiki's 100+ bundled themes
const highlighter = await getSingletonHighlighter({
  themes: ['vitesse-dark', 'rose-pine', 'material-theme-darker', 'monokai']
})

const colors = fromShikiTheme(highlighter.getTheme('rose-pine'))
const svg = renderMermaidSVG(diagram, colors)
```

## parseMermaid

Low-level access to the parsed graph structure:

```typescript
import { parseMermaid } from 'beautiful-mermaid'

const graph = parseMermaid(`
  graph TD
    A --> B --> C
`)
// Returns MermaidGraph for introspection
```

## XY Chart Full Syntax

```
xychart-beta [horizontal]
    title "Chart Title"
    x-axis [A, B, C]                       -- categorical
    x-axis "Label" [A, B, C]               -- with axis title
    x-axis 0 --> 100                       -- numeric range
    y-axis "Revenue ($K)" 0 --> 500        -- with title and range
    bar [val1, val2, val3]
    line [val1, val2, val3]
```

Multiple series are supported — combine `bar` and `line` in one chart.

## linkStyle Syntax (Edge Styling)

```
graph TD
  A --> B
  B --> C
  C --> D
  linkStyle 0 stroke:#ff0000,stroke-width:2px        -- edge by index (0-based)
  linkStyle 0,2 stroke:#00ff00                       -- multiple edges
  linkStyle default stroke:#888888,stroke-width:1px  -- all remaining edges
```

Supported CSS properties: `stroke`, `stroke-width`

## Node Shape Syntax (Flowcharts)

```
A[Rectangle]
B(Rounded)
C{Diamond / Decision}
D[(Database / Cylinder)]
E((Circle))
F>Asymmetric]
G[/Parallelogram/]
H[\Parallelogram alt\]
I[/Trapezoid\]
J[\Trapezoid alt/]
```

## Subgraph Syntax

```
graph TD
  subgraph Frontend
    A[React] --> B[Router]
  end
  subgraph Backend
    C[API] --> D[(DB)]
  end
  B --> C
```
