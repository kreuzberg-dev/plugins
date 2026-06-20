---
name: using-the-mcp-server
description: >-
  Use when parsing source, extracting code structure, or detecting a language
  through the tree-sitter-language-pack MCP server's tools, rather than shelling
  out to the ts-pack CLI. Covers the tool surface, the auto-installing launcher,
  and when MCP beats the CLI or SDK.
---

# Using the MCP Server

The `tree-sitter-language-pack` MCP server exposes `ts-pack`'s parsing and
code-intelligence capabilities as MCP tools, so an MCP-compatible client (Claude
Code, Claude Desktop) can parse source, extract structure, and detect languages
directly, with no CLI invocation or glue code.

## How it runs in this plugin

The plugin auto-registers the server. Its command is the bundled launcher
`scripts/mcp-launch.sh`, which execs `ts-pack mcp`. On first run the launcher
resolves a `ts-pack` binary: it reuses one already on `PATH` or cached in the
plugin's `bin/`, then tries `npx`/`uvx`, then Homebrew, then downloads a prebuilt
from the tool's latest GitHub release. Override the channel with
`TS_PACK_LAUNCHER=auto|npx|uvx|brew|download`.

The `mcp` subcommand ships in a recent release of the tool. If an older
`ts-pack` is already on `PATH`, it may not expose `mcp` yet — upgrade the binary
(`brew upgrade`, re-download, or rebuild) to pick it up.

To run it manually:

```bash
ts-pack mcp        # for Claude Code / Claude Desktop (stdio)
```

## The tools

- **parse** — parse a source file into a syntax tree (s-expression or JSON),
  auto-detecting the language from the path or taking an explicit one.
- **process** — run the code-intelligence pipeline: structure, imports, exports,
  symbols, docstrings, comments, diagnostics, and syntax-aware chunks.
- **detect** — identify a file's language by path, extension, or content.

The exact tool names and argument schemas come from the running server; ask the
client to list tools to see the live surface.

## When to prefer MCP over the CLI or SDK

- **Prefer MCP** inside an agent session: the agent calls parsing directly as a
  tool, with no shell-out and no process management.
- **Prefer the CLI** for one-shot parsing/extraction and shell/CI pipelines.
- **Prefer the SDK** when embedding parsing in application code or running custom
  tree-sitter queries.
