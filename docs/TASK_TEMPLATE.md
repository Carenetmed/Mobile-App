# Task Template

Use this shape for implementation or decision slices. Keep the filled task in
`AI_HANDOFF.md` or make sure `AI_HANDOFF.md` clearly points to the same scope.

Only one task may be active at a time.

---

## Task Spec

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

---

## Blocking Question Format

If the task needs a decision, do not code forward. Ask clearly and record the
answer in `DECISIONS.md`.

```text
Question:
Options:
Recommended:
Blocks:
```

---

## Slice Acceptance Checklist

Before marking a task done:

- [ ] Only this task ID was changed.
- [ ] No unrelated refactor or broad cleanup was added.
- [ ] No in-scope `Placeholder()`.
- [ ] No in-scope empty `onPressed` or `onTap`.
- [ ] Mock/local behavior is honest and replaceable when backend is expected.
- [ ] Navigation matches `FLOW_MAP.md`.
- [ ] Routes match `ROUTES.md`.
- [ ] Shared UI follows `COMPONENTS.md`.
- [ ] Validation/API/auth choices are recorded in `DECISIONS.md` when relevant.
- [ ] Deferred backend/product gaps are recorded in `DEFERRED_WORK.md`.
- [ ] Tests/manual checks are recorded.
- [ ] Relevant `flutter test` ran, or the reason it was not needed is written.
- [ ] Relevant `flutter analyze` ran, or the reason it was not needed is written.
- [ ] `AI_HANDOFF.md` points to exactly one next task.

---

## New Session Prompt

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
Do not start the next task without user approval.
```

