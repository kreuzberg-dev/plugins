# Changelog

All notable changes to Kreuzberg Plugins are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- MCP server transport for kreuzberg-cloud (target: v0.2.0)
- Additional skills for advanced extraction scenarios
- Support for more agent harnesses

## [0.1.0] - 2026-06-08

### Added

- **kreuzberg** plugin: local document extraction (PDF, Office, images with OCR, HTML, email, archives, academic; 91+ formats)
- **kreuzcrawl** plugin: web crawling and scraping with HTML→Markdown and headless-Chrome fallback
- **kreuzberg-cloud** plugin: managed extraction API (skills-only; MCP server in v0.2.0)
- Multi-harness support: Claude Code, Codex CLI, Cursor, Gemini CLI, Factory Droid, GitHub Copilot CLI, opencode
- Skill-based agent integration with automatic tool loading
- Marketplace registration for official Claude Code and Factory Droid (pending review)
- Self-hosted marketplace for all harnesses
- Contributing guidelines and security policy

[Unreleased]: https://github.com/kreuzberg-dev/plugins/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/kreuzberg-dev/plugins/releases/tag/v0.1.0
