# Codex Skills Conversion

This directory converts the supplied `skills.zip` into a Codex-compatible bundle.

## Included skills

`brainstorming`, `canvas-design`, `docx`, `excalidraw-diagram-generator`, `executing-plans`, `frontend-design`, `frontend-slides`, `mcp-builder`, `pdf`, `pptx`, `skill-creator`, `writing-skills`, and `xlsx`.

## Main compatibility changes

- `~/.claude/skills` → `~/.agents/skills`
- `CLAUDE.md` → `AGENTS.md`
- Claude-specific wording/default authors → Codex
- removed hard dependencies on `TodoWrite` and unavailable `superpowers:*` skills
- rewrote `brainstorming`, `executing-plans`, and `writing-skills` as self-contained Codex workflows
- rewrote the MCP evaluation harness to use the OpenAI Responses API instead of the Anthropic SDK
- removed bundled font binaries from `canvas-design`; use system/user-provided fonts instead

## Build

```bash
python Codex-Skills/build_codex_skills.py skills.zip -o codex-skills.zip
```

The builder validates all 13 `SKILL.md` files, compiles Python sources, checks JavaScript syntax when Node.js is available, and rejects stale active Claude/Superpowers dependencies.

## Install

User-level installation:

```bash
python Codex-Skills/install.py codex-skills.zip
```

Project-level installation:

```bash
python Codex-Skills/install.py codex-skills.zip --project
```

The default destinations are `~/.agents/skills/` and `./.agents/skills/` respectively. Use `--force` to replace existing skills.

## Notes

The optional `mcp-builder` evaluation harness uses the OpenAI Python SDK and `OPENAI_API_KEY`. Its default model is `gpt-5`; use `--model` to select another model available to your API account.
