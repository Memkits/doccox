# RFC 001: Extended Code Fence Syntax

**Status**: Draft  
**Date**: 2026-06-07

## Summary

Doccox extends the standard Markdown fenced code block syntax to support
interactive and rich rendering beyond plain syntax-highlighted code.

## Motivation

Standard ` ``` ` fenced code blocks are purely presentational. However, in
literate programming contexts (docco-style), it is useful to be able to:

- Execute code snippets in the browser
- Render data as interactive charts
- Demonstrate language features with simulated output

## Syntax

The extended syntax uses a dot-notation after the language identifier:

```
```<language>[.<renderer>]
<content>
```
```

Where `<renderer>` is optional. If omitted, the block is rendered as a
standard code block.

## Supported Combinations

### `js.run` — Runnable JavaScript

```
```js.run
console.log("Hello from browser!");
const sum = [1, 2, 3, 4, 5].reduce((a, b) => a + b, 0);
console.log("Sum:", sum);
```
```

**Behavior**: Displays the code with a "▶ Run" button. Clicking the button
evaluates the code using `Function()` in the browser. `console.log` output is
captured and displayed below the code.

### `json.echarts` — ECharts Chart

```
```json.echarts
{
  "xAxis": { "data": ["Mon", "Tue", "Wed", "Thu", "Fri"] },
  "yAxis": {},
  "series": [{ "type": "bar", "data": [120, 200, 150, 80, 70] }]
}
```
```

**Behavior**: The JSON is parsed as an ECharts `option` object and rendered as
an interactive chart using ECharts 5 (`echarts.renderToSVGString`). The user
can toggle between Chart view and Source view.

### `moonbit.demo` — MoonBit Demo (Simulated)

```
```moonbit.demo
fn main {
  println("Hello from MoonBit!")
}
```
```

**Behavior**: Displays the code with a "▶ Run" button. Clicking shows a
pre-defined fixed output to simulate MoonBit execution (since MoonBit cannot
run in browser directly). This is a demo/placeholder for future WASM support.

## Future Extensions

The dot-notation is designed to be extensible. Potential future renderers:

- `sql.table` — render query results as a table
- `json.tree` — render JSON as an expandable tree
- `csv.table` — render CSV as a styled table
- `js.wasm` — run JavaScript that loads a WASM module
- `mermaid` — render Mermaid diagrams

## Implementation Notes

- The language before the dot is used for syntax highlighting
- The renderer after the dot determines the display mode
- Unknown renderer suffixes fall back to plain code display
- Each block can toggle between "rendered" and "source" views
- ECharts charts use SVG rendering (`echarts.renderToSVGString`) for
  compatibility with Respo's virtual DOM model

## Docco Parsing

In **Docco mode**, the input source is parsed as follows:

1. Preferred format is **top-level Markdown** (`#`, `##`, paragraphs, fences)
2. Markdown is split by section headings (`## ...`) into doc sections
3. Fenced blocks are extracted from docs:
   - ` ```lang.action ` => extended renderer block
   - ` ```lang ` => plain code block
4. Left column renders prose markdown; right column renders extracted code blocks
5. Legacy `//` comment-style docco input is still supported for compatibility

Example input:

```markdown
# My Module

This function adds two numbers.

## Try it

```js.run
function add(a, b) {
  return a + b;
}

console.log(add(3, 4)); // => 7
```
```

This produces two columns: documentation on the left, code on the right.
