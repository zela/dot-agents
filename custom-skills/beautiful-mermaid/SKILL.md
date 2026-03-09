---
name: beautiful-mermaid
description: >
  Create, style, and render beautiful Mermaid diagrams using the beautiful-mermaid
  TypeScript library — a zero-dependency renderer with 15 built-in themes (Tokyo Night,
  Catppuccin, Nord, Dracula, GitHub, Solarized, and more) that outputs SVG or ASCII.
  Use this skill whenever the user wants to render Mermaid diagrams in code (not just
  write diagram syntax), integrate Mermaid into a React or Node app, apply custom
  themes or colors to diagrams, create XY charts with interactive tooltips, or needs
  help with beautiful-mermaid library installation, API usage, or configuration.
  Also trigger when the user wants flowcharts, sequence diagrams, ER diagrams, state
  diagrams, or class diagrams rendered programmatically with styling.
---

# beautiful-mermaid Skill

A concise guide for creating and rendering beautiful Mermaid diagrams using the
[beautiful-mermaid](https://github.com/lukilabs/beautiful-mermaid) library.

Full API reference is in `references/api.md` — read it when you need specific types,
all config options, or Shiki integration details.

---

## Installation

```bash
npm install beautiful-mermaid
# or
pnpm add beautiful-mermaid
bun add beautiful-mermaid
```

---

## Core API

```typescript
import { renderMermaidSVG, renderMermaidSVGAsync, renderMermaidASCII } from 'beautiful-mermaid'

// Synchronous SVG (ideal for React useMemo)
const svg: string = renderMermaidSVG(diagramText, options?)

// Async SVG (server contexts)
const svg: string = await renderMermaidSVGAsync(diagramText, options?)

// Terminal / ASCII output
const ascii: string = renderMermaidASCII(diagramText, asciiOptions?)
```

---

## Supported Diagram Types

Generate correct Mermaid syntax for any of these — the library handles rendering:

| Type | Keyword |
|------|---------|
| Flowchart | `graph TD` / `graph LR` / `graph BT` / `graph RL` |
| State diagram | `stateDiagram-v2` |
| Sequence diagram | `sequenceDiagram` |
| Class diagram | `classDiagram` |
| ER diagram | `erDiagram` |
| XY chart (bar/line) | `xychart-beta` |

### Flowchart directions
`TD` = top-down, `LR` = left-right, `BT` = bottom-up, `RL` = right-left

---

## Themes

Use a built-in theme by importing `THEMES` and passing it as options:

```typescript
import { renderMermaidSVG, THEMES } from 'beautiful-mermaid'

const svg = renderMermaidSVG(diagram, THEMES['tokyo-night'])
```

### All 15 built-in themes

| Theme key | Variant |
|-----------|---------|
| `zinc-light` | Light |
| `zinc-dark` | Dark |
| `tokyo-night` | Dark |
| `tokyo-night-storm` | Dark |
| `tokyo-night-light` | Light |
| `catppuccin-mocha` | Dark |
| `catppuccin-latte` | Light |
| `nord` | Dark |
| `nord-light` | Light |
| `dracula` | Dark |
| `github-light` | Light |
| `github-dark` | Dark |
| `solarized-light` | Light |
| `solarized-dark` | Dark |
| `one-dark` | Dark |

### Custom colors (two-color minimum)

Only `bg` and `fg` are required — all other colors are auto-derived:

```typescript
renderMermaidSVG(diagram, {
  bg: '#1e1e2e',
  fg: '#cdd6f4',
  // Optional enrichments:
  accent: '#89b4fa',
  muted: '#6c7086',
  surface: '#313244',
  border: '#45475a',
  line: '#89b4fa',
})
```

### Live theme switching (CSS variables)

```typescript
const svgElement = document.querySelector('svg')
svgElement.style.setProperty('--bg', '#282a36')
svgElement.style.setProperty('--fg', '#f8f8f2')
// Updates immediately — no re-render needed
```

Pass CSS variable strings to keep this working:
```typescript
renderMermaidSVG(diagram, { bg: 'var(--background)', fg: 'var(--foreground)' })
```

---

## React Integration

Use synchronous `renderMermaidSVG` inside `useMemo` — no flash, no async overhead:

```typescript
import { renderMermaidSVG, THEMES } from 'beautiful-mermaid'

function MermaidDiagram({ code, theme = 'tokyo-night' }: {
  code: string
  theme?: keyof typeof THEMES
}) {
  const { svg, error } = React.useMemo(() => {
    try {
      return {
        svg: renderMermaidSVG(code, THEMES[theme]),
        error: null,
      }
    } catch (err) {
      return { svg: null, error: err instanceof Error ? err : new Error(String(err)) }
    }
  }, [code, theme])

  if (error) return <pre style={{ color: 'red' }}>{error.message}</pre>
  return <div dangerouslySetInnerHTML={{ __html: svg! }} />
}
```

For CSS variable-based theming (theme switches without re-rendering):
```typescript
renderMermaidSVG(code, {
  bg: 'var(--background)',
  fg: 'var(--foreground)',
  transparent: true,
})
```

---

## Render Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `bg` | `string` | `#FFFFFF` | Background color or CSS variable |
| `fg` | `string` | `#27272A` | Foreground/text color |
| `font` | `string` | `Inter` | Font family |
| `padding` | `number` | `40` | Canvas padding (px) |
| `nodeSpacing` | `number` | `24` | Horizontal sibling spacing |
| `layerSpacing` | `number` | `40` | Vertical layer spacing |
| `componentSpacing` | `number` | `24` | Disconnected component spacing |
| `transparent` | `boolean` | `false` | Transparent background |
| `interactive` | `boolean` | `false` | XY chart hover tooltips |
| `thoroughness` | `number` | `3` | Crossing minimization (1–7) |

---

## Diagram Syntax Examples

### Flowchart
```
graph LR
  A[Client] --> B[API Gateway]
  B --> C[(Database)]
  B --> D[Cache]
  C -->|slow path| E[Response]
  D -->|fast path| E
```

### Edge styling
```
graph TD
  A --> B --> C --> D
  linkStyle 0 stroke:#ff6b6b,stroke-width:2px
  linkStyle default stroke:#888888
```

### State diagram
```
stateDiagram-v2
  [*] --> Draft
  Draft --> Review: submit
  Review --> Approved: approve
  Review --> Draft: reject
  Approved --> [*]
```

### Sequence diagram
```
sequenceDiagram
  User->>Frontend: click submit
  Frontend->>API: POST /orders
  API->>DB: INSERT order
  DB-->>API: ok
  API-->>Frontend: 201 Created
  Frontend-->>User: show confirmation
```

### ER diagram
```
erDiagram
  USER ||--o{ ORDER : places
  ORDER ||--|{ ORDER_ITEM : contains
  PRODUCT ||--o{ ORDER_ITEM : "included in"
  USER {
    int id
    string email
    string name
  }
```

### XY chart (bar)
```
xychart-beta
    title "Monthly Revenue"
    x-axis [Jan, Feb, Mar, Apr, May, Jun]
    y-axis "Revenue ($K)" 0 --> 500
    bar [180, 250, 310, 280, 350, 420]
```

### XY chart (combined bar + line trend)
```
xychart-beta
    title "Sales with Trend"
    x-axis [Q1, Q2, Q3, Q4]
    y-axis "Amount" 0 --> 1000
    bar [300, 450, 380, 620]
    line [300, 375, 377, 500]
```

### XY chart (horizontal)
```
xychart-beta horizontal
    title "Top Languages"
    x-axis [Python, JS, Java, Go, Rust]
    bar [30, 25, 20, 12, 8]
```

Enable interactive tooltips on XY charts:
```typescript
renderMermaidSVG(diagram, { ...THEMES['catppuccin-mocha'], interactive: true })
```

---

## ASCII / Terminal Rendering

```typescript
import { renderMermaidASCII } from 'beautiful-mermaid'

// Unicode box-drawing (default)
const unicode = renderMermaidASCII(`graph LR; A --> B --> C`)

// Pure ASCII (no Unicode)
const ascii = renderMermaidASCII(`graph LR; A --> B --> C`, { useAscii: true })

// With ANSI colors for terminal
const colored = renderMermaidASCII(diagram, { colorMode: 'truecolor' })
```

ASCII options: `useAscii`, `paddingX`, `paddingY`, `boxBorderPadding`,
`colorMode` (`'none'` | `'auto'` | `'ansi16'` | `'ansi256'` | `'truecolor'` | `'html'`)

---

## Shiki Theme Integration

Use any VS Code theme from the Shiki library:

```typescript
import { getSingletonHighlighter } from 'shiki'
import { renderMermaidSVG, fromShikiTheme } from 'beautiful-mermaid'

const highlighter = await getSingletonHighlighter({ themes: ['vitesse-dark'] })
const colors = fromShikiTheme(highlighter.getTheme('vitesse-dark'))
const svg = renderMermaidSVG(diagram, colors)
```

---

## Common Patterns

**Dark/light mode toggle:**
```typescript
const theme = isDark ? THEMES['tokyo-night'] : THEMES['github-light']
renderMermaidSVG(diagram, theme)
```

**Node.js / CLI output:**
```typescript
import { renderMermaidSVG } from 'beautiful-mermaid'
import { writeFileSync } from 'fs'

const svg = renderMermaidSVG(diagram, THEMES['catppuccin-mocha'])
writeFileSync('diagram.svg', svg)
```

**Async server (Next.js RSC, etc.):**
```typescript
import { renderMermaidSVGAsync } from 'beautiful-mermaid'

const svg = await renderMermaidSVGAsync(diagram, THEMES['nord'])
```

See `references/api.md` for complete type definitions and the full AsciiTheme interface.
