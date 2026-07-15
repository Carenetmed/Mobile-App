# Professional Category Specialty Update Regression

Task: 52.88

Status: Passed

## Outcome

The professional category/specialty update path is regression-checked for the
current frontend milestone boundary.

## Evidence

Commands run:

- `flutter test test/features/home/manage_profile_flow_test.dart -r expanded`
- `rg -n "updateProfessionalMe|lastDisplayName|lastCategory|lastSpecialty|lastBio|Professional details saved|Category is required|Professional profile has not been created yet|raw category update failure|Edit category|editProfessionalDetails" lib/features/Home/presentation/pages/edit_professional_details_shell.dart lib/features/Home/presentation/pages/manage_profile_shell.dart test/features/home/manage_profile_flow_test.dart`
- `rg -n "Website|Address|verificationStatus|Payment|Review|Call|Calendar sync|Prescription|staging|production|created profile|profile created|availability|appointment|account" lib/features/Home/presentation/pages/edit_professional_details_shell.dart test/features/home/manage_profile_flow_test.dart`

Results:

- 30 focused Manage Profile tests passed.
- Targeted update search confirms the category/specialty lane calls
  `updateProfessionalMe`, has route coverage for `editProfessionalDetails`,
  records preservation assertions for `displayName` and `bio`, records
  category/specialty payload assertions, proves cleared specialty is `null`,
  blocks empty profile saves, and hides raw backend failure text.
- Broader-scope search found expected separation copy in
  `edit_professional_details_shell.dart` and existing unrelated test coverage
  in `manage_profile_flow_test.dart`, not new category/specialty runtime
  behavior for website, address, verification, availability, appointment,
  account, payment, review, call, calendar, prescription, staging, production,
  or profile creation.

## Proven Behaviors

The focused test suite covers:

- Manage Profile exposes `Edit category` separately from the display-name
  `Edit` action.
- The edit route reads the existing backend professional profile.
- Category and specialty fields are prefilled.
- Empty category blocks save and does not call the repository update.
- Valid category/specialty save calls `ProfileRepository.updateProfessionalMe`.
- Existing `displayName` and `bio` are preserved.
- Clearing the optional specialty sends `null`.
- Empty professional profile blocks save and does not create a partial profile.
- Backend save failure shows a safe error without false success or raw backend
  text.

## Still Deferred

- professional profile creation
- category taxonomy/dropdown rules
- specialty autocomplete or verified specialty taxonomy
- website persistence
- address/location persistence
- account email, phone, role, or status changes
- verification status or document changes
- availability/business-hours changes
- appointment state changes
- public professional detail endpoint
- payments, reviews, calls, calendar sync, notes, prescriptions
- staging data and production readiness claims

## Next Slice

`52.89` should decide the next backend-completed Flutter surface after the
category/specialty regression. Do not start a broader profile or product module
without that decision.
