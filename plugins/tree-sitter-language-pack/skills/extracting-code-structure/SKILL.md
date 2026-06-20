---
name: extracting-code-structure
description: >-
  Use when the user wants structured code metadata from a source file —
  functions, classes, imports, exports, symbols, docstrings, comments, or
  syntax diagnostics. Covers `ts-pack process` feature flags, the JSON
  result shape, and the default feature set.
---

# Extracting code structure

`ts-pack process <file>` runs the code-intelligence pipeline over a source
file and prints JSON. Use it when the user wants *structured metadata* —
"list the functions", "what does this file import", "find the exported
symbols", "pull the docstrings" — rather than a raw syntax tree.

## Quick recipe

```bash
# Default features: structure + imports + exports
ts-pack process src/app.ts

# Pick features explicitly (only what you ask for is computed)
ts-pack process src/app.ts --structure --imports --symbols --docstrings

# Everything
ts-pack process src/app.ts --all
```

When no feature flags are given, `process` defaults to
`--structure --imports --exports`. Passing any single feature flag turns
off that default set, so list every feature you want.

## Feature flags

| Flag | Extracts |
| ---- | -------- |
| `--structure` | Functions, classes, methods, modules (spans, parent, visibility). |
| `--imports` | Import statements and their sources. |
| `--exports` | Exported symbols and their kinds. |
| `--comments` | Inline and block comments. |
| `--docstrings` | Docstrings attached to definitions. |
| `--symbols` | All identifiers (for search/indexing). |
| `--diagnostics` | Syntax errors and error nodes with positions. |
| `--all` | Enable every feature above. |
| `--chunk-size <bytes>` | Syntax-aware chunks — see `chunking-for-llms`. |
| `--language <name>` (`-l`) | Override language (auto-detected from extension otherwise). |

## Result shape

`process` always prints JSON. Top-level keys:

```json
{
  "language": "python",
  "metrics": { "total_lines": 0, "code_lines": 0, "comment_lines": 0, "blank_lines": 0, "total_bytes": 0, "error_count": 0 },
  "structure": [],
  "imports": [],
  "exports": [],
  "comments": [],
  "docstrings": [],
  "symbols": [],
  "diagnostics": [],
  "chunks": []
}
```

`metrics` is populated whenever any processing runs. `chunks` appears only
when `--chunk-size` is set.

### Structure items

Each `structure` entry has `kind` ("function", "class", "method",
"module", ...), `name`, `start_line`/`end_line` (1-indexed),
`start_byte`/`end_byte`, `parent` (enclosing class/module or null),
`docstring` (when `--docstrings`), and `visibility`.

## Examples

```bash
# Function and class names with line numbers
ts-pack process src/service.py --structure \
  | jq '.structure[] | {kind, name, line: .start_line}'

# Import sources only
ts-pack process src/app.ts --imports \
  | jq '.imports[].source'

# Syntax error count (also available via metrics.error_count)
ts-pack process broken.go --diagnostics \
  | jq '.diagnostics | length'

# Build a symbol index across a tree of files
for f in $(git ls-files '*.rs'); do
  ts-pack process "$f" --symbols | jq -c --arg f "$f" '{file: $f, symbols: .symbols}'
done
```

## SDK equivalent

```python
from tree_sitter_language_pack import process, ProcessConfig

config = ProcessConfig("python").all()        # or set fields via the constructor
result = process(source_code, config)
for item in result["structure"]:
    print(item["kind"], item["name"], item["start_line"])
```

The SDK additionally supports custom tree-sitter query patterns via the
`extractions` config field — not exposed on the CLI.

## When to reach for parse instead

If the user wants the raw syntax tree rather than extracted metadata, use
`ts-pack parse` — see the `parsing-source` skill.
