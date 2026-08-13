---
name: brainstorming
description: Use when a software or product request is still ambiguous enough that design choices should be explored before implementation.
---

# Brainstorming Ideas Into Designs

## Goal

Turn an ambiguous idea into an implementable design without rushing into code. Use this skill when requirements, trade-offs, architecture, UX, or success criteria are genuinely unsettled. Do not force a design ceremony for a tiny, already-specific edit.

## Workflow

1. **Inspect context first.** Read relevant files, repository instructions, docs, and recent changes when available.
2. **Clarify the goal.** Resolve purpose, users, constraints, scope, and success criteria. Ask only the questions that materially change the design.
3. **Offer alternatives.** Present 2–3 viable approaches when there is a real design choice, including trade-offs and a recommended option.
4. **Present the design.** Cover the relevant parts: components, interfaces, data flow, error handling, security, migration, testing, and rollout. Scale detail to the task.
5. **Get approval before a design-changing implementation.** If the user has already clearly approved an approach in the current conversation, do not ask them to approve it again.
6. **Write a spec when useful.** For non-trivial work, save the agreed design to `docs/codex/specs/YYYY-MM-DD-<topic>-design.md` unless the repository uses another convention.
7. **Review the spec.** Check it against the request and repository constraints. If subagents are available, an independent reviewer may be used, but this is optional.
8. **Transition to execution.** Convert the agreed design into a concrete implementation plan, then use `executing-plans` if that skill is available. Otherwise execute the plan directly with equivalent verification checkpoints.

## Design principles

- Prefer small, well-bounded components with clear interfaces.
- Follow existing repository patterns unless there is a task-specific reason to change them.
- Apply YAGNI: do not add infrastructure or abstraction without a concrete requirement.
- Separate facts from assumptions and call out assumptions that affect architecture.
- Do not propose unrelated refactors.

## Visual companion

For visual questions, you may use the bundled local visual companion described in `visual-companion.md` when the environment can open a local browser. Treat it as optional. If it is unavailable, continue with text, Mermaid/Graphviz, or another available diagram mechanism.

## Output

End with a concise approved design or implementation-ready decision record. For substantial work, include acceptance criteria and verification expectations so execution can be checked objectively.
