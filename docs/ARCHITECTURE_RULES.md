# Architecture rules

This file is the guardrail for implementation. Read it before writing code.

The goal is simple: developers should be able to continue without guessing
structure, inventing duplicate components, or marking unfinished work as
complete.

## Authority

If docs conflict, follow this order:

1. `ROUTES.md` and `router.dart` for navigation.
2. `FLOW_MAP.md` for screen order and button outcomes.
3. `COMPONENTS.md` for reusable widgets and tokens.
4. `DECISIONS.md` for accepted product and technical boundaries.
5. `DEFERRED_WORK.md` for intentionally unavailable backend capabilities.
6. This file for code structure.

## Current stack

- Flutter app.
- Named route navigation through `RouteName` and `generateRoute`.
- `flutter_screenutil` is already used for responsive sizing.
- `flutter_bloc`, `get_it`, `dio`, and `flutter_secure_storage` exist, but not
  every feature uses them yet.
- Montserrat is the app font family.

Do not add a new package unless the implementation requires it and the reason
is documented in the pull request or a technical decision.

## Folder ownership

Use the existing layout:

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    di/
    model/
    routing/
    services/
    theme/
    tokens/
  shared/
    widgets/
  features/
    FeatureName/
      data/
      domain/
      presentation/
        pages/
        widgets/
```

Rules:

- `lib/main.dart` is the only app entry point.
- `lib/app.dart` owns `MaterialApp`.
- `core/` is for app-wide infrastructure, tokens, routing, theme, services, and
  simple shared models.
- `shared/widgets/` is for reusable UI used by more than one feature.
- `features/<name>/presentation/pages/` is for screens.
- `features/<name>/presentation/widgets/` is for widgets private to that feature.
- Do not create new top-level folders unless the task explains why.

## Navigation

All navigation must use `RouteName` constants.

Required route steps:

1. Add or confirm the constant in `lib/core/constants/navigators/routeName.dart`.
2. Register the screen in `lib/core/constants/navigators/router.dart`.
3. Add the route to `docs/ROUTES.md`.
4. Update `docs/FLOW_MAP.md` if button flow changes.

Forbidden:

- Raw route strings inside screens.
- A second `MaterialApp`.
- A second `void main()`.
- Navigating to a screen that is not registered.

## Reusable UI

Before creating UI, check `COMPONENTS.md`.

Use shared widgets for:

- Buttons.
- Text fields.
- Bottom navigation.
- Cards used in multiple features.
- Repeated list rows.
- App bars or headers used across multiple flows.

Create a new shared widget only when:

- At least two screens need it now, or
- It is a foundation component from the blueprint, or
- The task explicitly says to create it.

When adding a shared widget:

1. Place it in `lib/shared/widgets/`.
2. Use `CarenetColors` from `lib/core/tokens/`.
3. Document import path, props, variants, and usage in `COMPONENTS.md`.
4. Add focused widget tests if behavior or variants can regress.

## Design tokens

New shared UI must use `CarenetColors` from `lib/core/tokens/`.

Legacy `AppColors` can remain in old screens until a task explicitly refactors
that screen. Do not do broad color rewrites during unrelated tasks.

If a new color, spacing, or typography token is needed:

1. Confirm it from the blueprint when possible.
2. Add it to `core/tokens/`.
3. Document it in `COMPONENTS.md`.
4. Add a small test for values that must not drift.

## State and data

Keep state simple until real data needs more structure.

Use local widget state for:

- Current tab index.
- Text field visibility toggles.
- Local form input before submission.
- Simple UI-only selection.

Use Bloc/Cubit or another explicit feature state layer when:

- A screen fetches or mutates remote data.
- Loading, success, empty, and error states matter.
- Multiple widgets need the same feature state.
- The task includes real auth, messaging, health readings, appointments, or feed
  behavior.

Use this direction for future data features:

```text
feature/
  domain/entities/      plain app objects
  data/models/          API/local serialization
  data/repositories/    data access implementation
  presentation/         UI and state
```

Do not invent backend fields. If a task needs fields not visible in the
blueprint or not written in `DECISIONS.md`, stop and ask.

## Forms and validation

Every form task must specify validation.

If validation is not decided, record one of these in `DECISIONS.md` before
coding:

- "No validation yet; navigation only."
- "Client-side validation only."
- "Backend validation required."

No form screen can be marked done with silent fake validation.

## Loading, error, and empty states

For static blueprint screens, these may be N/A.

For screens that fetch or submit data, define:

- Loading state.
- Success state.
- Error state.
- Empty state, if a list can be empty.
- Retry behavior, if useful.

Do not show permanent sample data as if it is real backend data unless the task
explicitly says mock data is allowed.

Backend-ready rule:

- Prefer a clean screen -> state/controller -> service/repository boundary when a feature uses data.
- Temporary mock/local data is allowed, but keep it behind a boundary that can be replaced later.
- Do not bury fake business logic directly in widgets if the feature is expected to connect to backend later.
- The goal is that later backend integration mostly swaps the data source, not the screen structure.

## Testing standard

Minimum expected checks:

- Shared components: widget tests for variants, disabled state, and important
  callbacks.
- Tokens: value tests for exact colors.
- Routing changes: route generation or navigation tests when practical.
- Screen changes: record manual verification steps in the pull request and add
  widget tests for important interactions when feasible.

Commands:

```bash
flutter test
flutter analyze lib test
```

If a command cannot be run, state why in the pull request.

## Scope control

Every implementation task must have a clear goal, scope, acceptance criteria,
and verification plan.

Do not:

- Start a second task in the same session.
- Refactor unrelated files.
- Replace existing patterns just because another pattern is nicer.
- Change UI and flow at the same time unless the task says so.
- Mark work done when downstream screens outside the task still need decisions.

Allowed:

- Leave pre-existing stubs alone when they are outside the current task.
- Add small helper code if it directly supports the task.
- Update docs to make the next session safer.

## Documentation rule

When implementation changes affect project behavior, update:

- `COMPONENTS.md` if reusable UI changed
- `ROUTES.md` and `FLOW_MAP.md` if navigation changed
- `DECISIONS.md` if a product or technical boundary changed
- `DEFERRED_WORK.md` if backend-dependent behavior changed
