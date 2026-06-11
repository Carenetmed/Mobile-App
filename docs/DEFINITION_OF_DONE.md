# Definition of Done

**Strict mode:** See `WORKING_AGREEMENT.md`. A task is **not done** at 99%.

## Per design-token / shared-component task (e.g. 1.1, 1.2, 1.3)

- [ ] Matches blueprint reference screen named in `AI_HANDOFF.md` (e.g. `color-palette`, `buttons/`)
- [ ] Code in `lib/core/tokens/` or `lib/shared/widgets/` as specified
- [ ] Documented in `COMPONENTS.md` (props, import path, when to use)
- [ ] Unit or widget tests where values/variants must not drift (e.g. hex tests for colors)
- [ ] No unrelated screen/route changes unless the task explicitly includes them
- [ ] `AI_HANDOFF.md` updated; `CODEBASE_STATUS.md` + `DOC_SYNC.md` if state changed
- [ ] `flutter test` passes; `flutter analyze lib test` has no **errors**

## Per screen (or per screen task)

- [ ] Listed in `docs/ROUTES.md` with file path
- [ ] Registered in `lib/core/constants/navigators/router.dart`
- [ ] Reachable from the correct previous screen per `docs/FLOW_MAP.md`
- [ ] **Every** button, link, and tab in scope works (no `() {}`, no `Placeholder` for in-scope UI)
- [ ] Blueprint `reactions` for this screen implemented **or** marked N/A in handoff with reason
- [ ] Validation / API / auth behavior defined in `DECISIONS.md` **or** implemented (not guessed silently)
- [ ] Loading / error / empty states if screen loads data
- [ ] Uses shared components per `COMPONENTS.md` (or new component documented same session)
- [ ] No `void main()` except `lib/main.dart`; no extra `MaterialApp`
- [ ] Back navigation works
- [ ] Manual test steps recorded in `AI_HANDOFF.md` under the task — **you** ran them or AI listed steps for you to run
- [ ] `flutter test` passes; `flutter analyze lib test` has **no errors** (warnings OK if pre-existing and noted)

## Forbidden for a “done” task

- `Placeholder()` for content that belongs to this task
- `onPressed: () {}` / `onTap: () {}` for real actions
- Comments like `// TODO Phase X` for work inside this task’s scope
- Starting the next task in the same session without your approval

## Per session (AI end-of-session)

- [ ] Only one task ID worked on
- [ ] `AI_HANDOFF.md` updated: status, test steps, files changed
- [ ] `CODEBASE_STATUS.md` updated if stubs were removed or added
- [ ] `DOC_SYNC.md` “Current project state” + NEXT task (easy to forget)
- [ ] `DECISIONS.md` updated if you answered a blocker
- [ ] AI **asked** before starting the next task

## Phase gate

A phase is done only when **every** task in that phase is **DONE** in `AI_HANDOFF.md` (not “mostly done”).

## Phase 0 — DONE (reference)

Spine only; intentional stubs listed in `CODEBASE_STATUS.md` for later phases.
