# modelcontextprotocol/registry

- Upstream: https://github.com/modelcontextprotocol/registry
- Status: **deferred — not zero-touch**
- Reason: Submission requires the `mcp-publisher` CLI, interactive GitHub OAuth, and a published package (npm/PyPI/NuGet/OCI/MCPB) carrying an `mcpName` field. Our kreuzberg + kreuzcrawl binaries ship via Homebrew + GitHub Releases + crates.io; the registry expects per-package verification mechanisms documented in `docs/modelcontextprotocol-io/package-types.mdx`.

## Path to submission (Iteration 3 or later)

1. Add an `mcpName` field to the relevant `Cargo.toml` (e.g. `kreuzberg-cli` and `kreuzcrawl-cli`). Format: `io.github.kreuzberg-dev/kreuzberg` and `.../kreuzcrawl`.
2. Confirm crates.io publishes carry the field through to the registry (or pivot to npm/PyPI wrappers).
3. Install `mcp-publisher` and authenticate via GitHub OAuth from a human terminal.
4. Run `mcp-publisher publish` for each server.

## Until then
- `punkpeye/awesome-mcp-servers` (PR #7633) covers MCP-server discovery.
- `jmanhype/awesome-claude-code` (PR #54) lists both as MCP servers.

Cloud plugin (kreuzberg-cloud) deferred until v0.2.0 ships the MCP wiring.
