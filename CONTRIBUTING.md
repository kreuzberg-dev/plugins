# Contributing

Contributions are welcome. Follow these guidelines to maintain consistency across the marketplace.

## Local Development

Clone the repo and set up your harness.

```bash
git clone https://github.com/kreuzberg-dev/plugins
cd plugins
```

For Claude Code:

```text
/plugin marketplace add /path/to/plugins
/plugin install kreuzberg@kreuzberg
```

For other harnesses, use the equivalent self-hosted marketplace install command (see README).

## Adding a Skill

Create a new skill in `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`. Start with frontmatter:

```yaml
---
name: "Extract tables"
description: "Extract structured tables from documents"
tags: ["extraction", "tables"]
---
```

Add the skill content below. Keep it concise — the description is used by agents to decide when to invoke your skill. Refer to existing SKILL.md files as templates.

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
- `fix: handle missing mime type in kreuzcrawl`
- `docs: update README install instructions`

Keep commits atomic and focused. One logical change per commit.

## Workflow

1. Create a branch: `git checkout -b feat/skill-name`
2. Add or modify skills in `plugins/*/skills/`
3. Run `bash scripts/validate-manifests.sh`
4. Commit with conventional message
5. Push and open a PR with a brief description

If you're adding a new plugin, coordinate with the maintainers first — open an issue to discuss scope and approach.
