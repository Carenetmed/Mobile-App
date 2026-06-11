# Task template

Use this template for every implementation task before coding.

Only one task may be active. Copy the filled task into `AI_HANDOFF.md` or keep
the same fields there.

## Task spec

```text
ID:
Title:
Status: NEXT | IN PROGRESS | BLOCKED | DONE
Size: S | M | M+

Goal:

Why this task exists:

Out of scope:

Blueprint references:
- Folder/screen:
- Files:
- Reactions to check:

Files allowed to touch:
-

Files expected not to touch:
-

Routes involved:
-

Reusable components/tokens required:
-

UI requirements:
-

Behavior requirements:
-

Validation rules:
-

Loading/error/empty states:
-

Mock/backend boundary:
-

Tests required:
-

Manual test steps:
1.
2.
3.

Docs to update:
-

Done means:
-
```

## Blocking question format

If the task needs a decision, do not code forward. Add the question to
`AI_HANDOFF.md` and `DECISIONS.md`.

```text
Question:
Options:
Recommended:
Blocks:
```

## Acceptance checklist

Before marking a task done:

- [ ] Only this task ID was changed.
- [ ] No new unrelated files or broad refactors.
- [ ] No in-scope `Placeholder()`.
- [ ] No in-scope empty `onPressed` or `onTap`.
- [ ] Mock/local behavior is behind a replaceable boundary when backend is expected later.
- [ ] Navigation matches `FLOW_MAP.md`.
- [ ] Routes match `ROUTES.md`.
- [ ] Shared UI follows `COMPONENTS.md`.
- [ ] Validation/API/auth choices are in `DECISIONS.md` when relevant.
- [ ] Tests/manual checks are recorded.
- [ ] `flutter test` ran or reason not run is written.
- [ ] `flutter analyze lib test` ran or reason not run is written.
- [ ] `AI_HANDOFF.md` points to exactly one next task.

## Prompt to start a new AI session

```text
Project: C:\Users\asd\Music\Mobile-App-master
Blueprint: C:\Users\asd\Music\project-blueprint\project-blueprint\

Read docs/WORKING_AGREEMENT.md first.
Read docs/README.md and docs/AI_HANDOFF.md.
Read docs/ARCHITECTURE_RULES.md and docs/TASK_TEMPLATE.md.
Complete only the task marked NEXT in docs/AI_HANDOFF.md.
Follow docs/FLOW_MAP.md, docs/ROUTES.md, docs/COMPONENTS.md,
docs/DEFINITION_OF_DONE.md, docs/CODEBASE_STATUS.md, and docs/DECISIONS.md.
Do not use old chat history.
Do not start the next task without my approval.
```
