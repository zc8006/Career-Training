---
name: writing-skills
description: Use when creating, editing, reviewing, or validating Codex skills and their bundled references, scripts, or assets.
---

# Writing Codex Skills

## Goal

Create small, discoverable skills that improve Codex on repeatable work without depending on undocumented agent-specific behavior.

## Codex skill layout

Personal skills normally live under `~/.agents/skills/`. Repository-scoped skills live under `.agents/skills/` and can travel with the project.

```text
.agents/skills/
  skill-name/
    SKILL.md
    scripts/       # optional executable helpers
    references/    # optional long-form guidance
    assets/        # optional templates/resources
```

`SKILL.md` must begin with YAML frontmatter containing at least `name` and `description`.

```yaml
---
name: example-skill
description: Use when the user needs ...
---
```

Use lowercase, hyphen-separated names. Make the description specific enough for discovery but do not try to encode the entire workflow in it.

## Authoring workflow

1. **Define the trigger.** Write down the concrete requests, symptoms, file types, or contexts that should cause the skill to be used.
2. **Capture non-obvious procedure.** Put durable judgment, constraints, and ordered workflow in `SKILL.md`; do not restate generic knowledge Codex already has.
3. **Separate heavy material.** Move long API references, examples, schemas, and templates into `references/` or `assets/` and link to them from `SKILL.md`.
4. **Automate deterministic work.** Put repeatable transformations and validators in `scripts/` rather than describing many mechanical steps in prose.
5. **Remove hidden dependencies.** Do not require another skill, subagent, proprietary tool, or model unless it is actually included or clearly optional. Provide a self-contained fallback.
6. **Test discovery and behavior.** Run representative prompts with and without the skill when practical. Check that the skill activates for intended requests, stays out of unrelated work, and changes behavior in the desired way.
7. **Review for portability.** Avoid hard-coded home directories, product-specific author names, unavailable tool names, and assumptions about macOS/Linux/Windows unless the skill explicitly targets them.

## Validation checklist

- `SKILL.md` exists and has valid YAML frontmatter.
- `name` matches the directory name and uses a portable format.
- `description` states when the skill should be used.
- All referenced relative files exist.
- Commands use paths relative to the skill directory when possible.
- No stale `~/.claude`, `CLAUDE.md`, `TodoWrite`, or `superpowers:*` dependencies remain unless they are intentionally discussed as migration examples.
- Scripts have clear prerequisites and useful error messages.
- External writes are never implied merely because a skill was invoked.

## Testing strategy

Prefer lightweight scenario testing:

1. Create 3–5 positive prompts that should trigger the skill.
2. Create 2–3 negative prompts that should not need it.
3. For procedural skills, include one pressure case where skipping a guardrail would be tempting.
4. Inspect the resulting behavior and close specific loopholes instead of adding broad, repetitive warnings.

If subagents are available they may be used to parallelize independent reviews, but the skill must remain usable without them.

## Keep skills concise

A good skill gives Codex information it would not reliably infer from the user request or repository itself. Prefer one strong rule over several near-duplicates, and prefer executable validation over prose whenever possible.
