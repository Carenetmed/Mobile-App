# Definition Of Done

A task is done only when the scoped behavior, proof, and documentation are all
complete. "Mostly done" is not done.

---

## For Every Slice

- [ ] The task marked `NEXT` in `AI_HANDOFF.md` is the only task completed.
- [ ] Scope and out-of-scope boundaries are respected.
- [ ] No unrelated runtime behavior changed.
- [ ] No in-scope placeholders, fake success paths, or empty handlers remain.
- [ ] Relevant tests/analyze checks pass, or the reason they are not applicable
      is recorded.
- [ ] Manual verification steps are written in `AI_HANDOFF.md`.
- [ ] Docs changed by the slice are updated together.
- [ ] `AI_HANDOFF.md` has exactly one task-table `NEXT` row.

---

## For Screen Or Flow Tasks

- [ ] Route constants and router registration are correct when navigation
      changes.
- [ ] `ROUTES.md` and `FLOW_MAP.md` are updated when navigation changes.
- [ ] Every in-scope button, link, tab, and form action has a real outcome.
- [ ] Validation is implemented or explicitly documented as not in scope.
- [ ] Loading/error/empty states exist when the screen fetches or mutates data.
- [ ] Backend-dependent behavior is honest and replaceable.
- [ ] Deferred backend/product gaps are recorded in `DEFERRED_WORK.md`.
- [ ] Tests cover important interactions when practical.

---

## For Backend-Integration Frontend Tasks

- [ ] The screen calls a repository/API boundary instead of hardcoding backend
      logic directly in widgets.
- [ ] The app does not trust client-supplied ownership, role, identity, or status
      fields when backend identity should decide them.
- [ ] Missing config fails safely.
- [ ] Errors shown to the user are safe and do not leak internals.
- [ ] Success is shown only after repository/API success.
- [ ] Unsupported flows remain disabled or explicitly blocked.

---

## For Docs Or Decision Slices

- [ ] The decision is clear enough for a new session to continue without old
      chat history.
- [ ] No runtime behavior changed.
- [ ] The next task is explicit.
- [ ] Any deferred work or risk discovered is recorded in the proper doc.
- [ ] `git diff --check` passes for changed docs.

---

## Verification Commands

Use the smallest reliable checks for the slice.

Common commands:

```bash
flutter test
flutter analyze lib test
```

For narrow slices, focused tests/analyze are acceptable when recorded in
`AI_HANDOFF.md`.

