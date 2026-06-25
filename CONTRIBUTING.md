# Contributing

Contributions are welcome. Follow these guidelines to maintain consistency across the marketplace.

## Local Development

Clone the repo and set up your harness.

```bash
git clone https://github.com/xberg-io/plugins
cd plugins
```

For Claude Code:

```text
/plugin marketplace add /path/to/plugins
/plugin install kreuzberg@kreuzberg
```

For other harnesses, use the equivalent self-hosted marketplace install command (see README).

## Adding a Skill

Create a new skill in `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`. Use a **gerund-task**
directory name (`extracting-tables`, `crawling-a-site`, `running-the-proxy`).

A **secondary** skill carries only `name` + `description`, and the description **starts with
"Use when …"**:

```yaml
---
name: extracting-tables
description: "Use when extracting tabular data from PDFs, spreadsheets, or images. Covers layout-aware detection, model selection, and output formats."
---
```

The **main** skill (`skills/<plugin-name>/SKILL.md`) additionally carries `license` and a `metadata`
block:

```yaml
---
name: kreuzberg
description: "<capability summary>. Use when …"
license: MIT
metadata:
  author: kreuzberg-dev
  version: "0.1.0"
  repository: https://github.com/xberg-io/<tool>
---
```

Keep the body concise and accurate to the tool's **real** CLI/API surface — never document a flag,
subcommand, or MCP tool that does not exist in the source. Refer to existing SKILL.md files as
templates.

## Plugin Standard

Every plugin conforms to the same shape:

1. **Skills** — one main skill (full capability map, install, a "when to use X vs Y" decision table,
   MCP-vs-CLI guidance) plus gerund-task secondary skills. Frontmatter as above.
2. **MCP launcher** — if the tool ships an MCP server, the plugin auto-installs the binary via
   `scripts/mcp-launch.sh` (resolution order: a working binary on PATH/`$PLUGIN_ROOT/bin` →
   prebuilt download from the tool's **latest** GitHub release, checksum-verified where the release
   publishes checksums and otherwise TLS-only with a stderr warning → `brew install` → `cargo
   install`). All diagnostics go to **stderr** (stdout is the MCP channel). `.claude-plugin/mcp.json`
   points its `command` at `${CLAUDE_PLUGIN_ROOT}/scripts/mcp-launch.sh`. Never key the download off
   the plugin version — the plugin version and the tool version are independent.
3. **Install** — the main skill + README document install via brew / cargo / npx / uvx as the tool
   actually supports them (verify against the tool repo). Tools without an MCP server shell out to
   the CLI; the opencode runner surfaces an install hint on `ENOENT`.
4. **Manifests** — six harness manifests (`.claude-plugin/` (+ `mcp.json` when there's an MCP
   server), `.codex-plugin/`, `.cursor-plugin/`, `.factory-plugin/`, `.github/plugin/`,
   `gemini-extension.json`), plus `README.md`, `GEMINI.md`, `assets/`, and an opencode
   `.opencode/plugins/<name>.js` + `package.json` where the tool has a CLI. `capabilities`:
   `Read` = fetch/parse/extract; add `Write` only when the plugin's tools write/submit/modify.
5. **README order** — Install → Skills (table matching `skills/`) → MCP/CLI → Configuration →
   Examples. Marketplace one-liners describe what the plugin does today; keep status/roadmap notes
   in the README, not the marketplace description.
6. **Registration** — add the plugin to both `.claude-plugin/marketplace.json` and
   `.github/plugin/marketplace.json`, list its version-bearing manifests in `.version-bump.json`,
   and (if it ships an opencode package) add it to root `package.json` workspaces and the publish
   workflow.

## Testing

Validate manifests:

```bash
bash scripts/validate-manifests.sh
```

Install locally and test manually in your agent harness. Ask the agent to perform the task your skill describes and verify output.

## Version Bumps

Update VERSION, run the bump script, and tag:

```bash
echo X.Y.Z > VERSION
scripts/bump-version.sh X.Y.Z
git commit -am "chore: release vX.Y.Z"
git tag vX.Y.Z && git push --tags
```

## Prose Style

Keep skills and docs terse and imperative. Lead with what the agent should do, not marketing:

- Good: "Extract text and tables from PDFs, Office files, and images."
- Avoid: "This skill provides powerful document extraction capabilities."

No emojis. Avoid adjectives like "powerful", "smart", "intelligent". Reference the [kreuzberg-dev communication style](../CLAUDE.md#communication-style) for guidance.

## Conventional Commits

Use `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:` prefixes:

- `feat: add table extraction skill`
- `fix: handle missing mime type in crawlberg`
- `docs: update README install instructions`

Keep commits atomic and focused. One logical change per commit.

## Workflow

1. Create a branch: `git checkout -b feat/skill-name`
2. Add or modify skills in `plugins/*/skills/`
3. Run `bash scripts/validate-manifests.sh`
4. Commit with conventional message
5. Push and open a PR with a brief description

If you're adding a new plugin, coordinate with the maintainers first — open an issue to discuss scope and approach.
