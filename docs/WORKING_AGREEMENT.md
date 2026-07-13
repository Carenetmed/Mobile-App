# Working Agreement

This project should be continued as one finished slice at a time. Do not optimize
for speed at the cost of unclear scope, fake behavior, or work that needs to be
rediscovered later.

You do not need old chat history. You do need this file, `README.md`,
`AI_HANDOFF.md`, `ARCHITECTURE_RULES.md`, `TASK_TEMPLATE.md`,
`DEFINITION_OF_DONE.md`, `DECISIONS.md`, and `DEFERRED_WORK.md`.

---

## Session Rule

Only the task marked `NEXT` in `AI_HANDOFF.md` may be started.

Do not start the following task in the same session unless the user explicitly
approves it after the current task is complete.

At the end of a slice:

1. Mark the completed task `DONE`.
2. Set exactly one following task to `NEXT`.
3. Update the relevant status/docs.
4. Stop and ask before continuing.

---

## Priority Order

1. Functionality and flow are correct.
2. Interactions and button outcomes are complete.
3. Structure follows the repo conventions and existing boundaries.
4. UI fidelity is improved within scope, but visual polish does not override
   honest behavior.

Small visual mismatches are acceptable when the flow is correct and documented.
Fake success paths, hidden placeholder logic, and untracked backend gaps are not.

---

## Scope Rules

Do:

- Keep each slice small enough to verify.
- Prefer existing repo patterns over new abstractions.
- Use named routes and documented route constants.
- Keep backend-dependent behavior behind replaceable repository/state boundaries.
- Record deferred work when a real backend/product contract is missing.

Do not:

- Add a placeholder and call the slice done.
- Add empty button handlers for in-scope actions.
- Invent backend fields, payments, notifications, auth, or provider behavior.
- Refactor unrelated files during a feature slice.
- Enable a disabled/deferred control just because a screen exists.

---

## When To Stop And Ask

Stop and ask if the current task needs a decision that is not already recorded in
`DECISIONS.md`, especially:

- Auth/provider behavior.
- API base URL, environment, keys, or secret handling.
- Payment, subscription, or ad provider behavior.
- Push notification or messaging transport.
- Legal/compliance copy or medical-safety behavior.
- Role ownership rules.
- Data fields not already in the blueprint, docs, or backend contract.
- Whether a blueprint frame is a separate route or just a state.

After the user answers, record the decision in `DECISIONS.md`.

---

## Backend-Ready Rule

Frontend work may use local or mock state only when it is honest and replaceable.

That means:

- The UI should not pretend backend persistence happened.
- The code should leave a clear replacement point for a repository/API later.
- Deferred backend work should be recorded in `DEFERRED_WORK.md`.
- A later backend integration should mostly replace the data source, not rewrite
  the whole screen.

---

## End Of Slice Checklist

Before saying a slice is done:

- Confirm the task scope is complete.
- Confirm no unrelated task was started.
- Run the relevant tests/analyze checks, or record why not.
- Update `AI_HANDOFF.md`.
- Update `DOC_SYNC.md`.
- Update `CODEBASE_STATUS.md` if behavior/status changed.
- Update `DECISIONS.md` if a decision was made.
- Update `DEFERRED_WORK.md` if a backend/local seam changed.
- Update `ROUTES.md` and `FLOW_MAP.md` if navigation changed.
- Leave exactly one task-table `NEXT` row in `AI_HANDOFF.md`.

