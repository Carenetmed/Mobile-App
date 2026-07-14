# Professional Category Specialty Update Wiring

Task: 52.87

Status: Runtime wired

## Scope

This slice wires a constrained professional profile details edit surface for:

- `category`
- optional `specialty`

The route is reachable from Manage Profile Basic through `Edit category`.

## Runtime Behavior

The new `editProfessionalDetails` route:

1. Reads the existing professional profile through
   `ProfileRepository.professionalMe`.
2. Prefills backend `category` and `specialty`.
3. Requires an existing professional profile before saving.
4. Blocks empty professional profiles instead of creating a profile.
5. Requires a non-empty category.
6. Sends cleared/empty specialty as `null`.
7. Calls `ProfileRepository.updateProfessionalMe` with:
   - existing `displayName`
   - new `category`
   - new or cleared `specialty`
   - existing `bio`
8. Shows success only after repository success.
9. Shows safe loading, validation, empty-profile, and backend-failure states.

## Explicit Non-Behavior

This slice does not send or mutate:

- website
- address/location
- account email, phone, role, or status
- verification documents or status
- availability/business hours
- appointment state
- payment state
- review state
- call/video state
- calendar data
- notes or prescriptions
- staging data or production readiness claims

## Verification

Focused tests prove:

- Manage Profile exposes a category/specialty edit entry without replacing the
  display-name-only `Edit` path.
- The edit screen reads an existing profile and prefills category/specialty.
- Valid save sends new category/specialty while preserving existing
  `displayName` and `bio`.
- Clearing specialty sends `null`.
- Empty category blocks update.
- Empty professional profile blocks partial profile creation.
- Backend save failure shows a safe error and no success state.

Command run:

```powershell
flutter test test\features\home\manage_profile_flow_test.dart -r expanded
```

Result: all 30 tests passed.

## Next

Queue `52.88 - Run Professional Category Specialty Update Regression
Checkpoint`.

Do not broaden profile editing before this regression checkpoint confirms the
new route, preservation behavior, null-clearing behavior, docs/deferred-work
accuracy, and absence of unrelated module data.
