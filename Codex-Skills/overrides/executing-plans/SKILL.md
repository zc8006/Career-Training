---
name: executing-plans
description: Use when a written implementation plan exists and should be executed carefully with verification checkpoints.
---

# Executing Plans

## Overview

Execute an existing implementation plan in a controlled, reviewable way. Work on a non-default branch when version control is available, keep a concise progress checklist, verify each completed task, and surface blockers instead of guessing.

## Process

### 1. Load and review the plan

1. Read the complete plan and the relevant repository instructions such as `AGENTS.md`.
2. Check the current branch and working tree before editing.
3. Identify missing prerequisites, contradictions, risky assumptions, or steps that cannot be verified.
4. If a problem prevents safe execution, explain it before making dependent changes. Otherwise proceed.

### 2. Track execution

Maintain a short checklist in the working context. For each plan task:

1. Mark it in progress.
2. Make only the changes required for that task.
3. Run the verification specified by the plan. If none is specified, choose the smallest meaningful check: targeted tests, lint/typecheck, build, or a focused inspection.
4. Fix failures caused by the change before moving on.
5. Mark the task complete and record any deviation from the plan.

Do not silently reinterpret a materially incorrect plan. Small implementation details may be resolved from repository context; design-changing assumptions should be surfaced.

### 3. Finish the work

After all tasks are complete:

1. Review the full diff for accidental or unrelated edits.
2. Run the strongest practical verification for the affected scope.
3. Summarize files changed, checks run, remaining risks, and any follow-up work.
4. Do not commit, push, open a pull request, merge, deploy, or perform another external write unless the user has authorized that action.

## Blockers

Stop the dependent part of execution when:

- a required dependency or credential is unavailable;
- an instruction is materially ambiguous;
- a verification repeatedly fails and the cause is not understood;
- the plan conflicts with repository rules or would cause destructive behavior.

Continue independent tasks when safe instead of abandoning the entire plan.

## Git safety

- Prefer a feature branch for implementation work.
- Never overwrite unrelated user changes.
- Never use destructive Git operations merely to make the worktree clean.
- Treat commit, push, PR creation, merge, release, and deployment as separate external actions requiring authorization.
