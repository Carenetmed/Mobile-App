# Auth Gateway And Role-First Entry

**Slice:** APP-66  
**Date:** 2026-07-18  
**Status:** Runtime slice complete. Stacked after APP-64 and APP-65.  
**Contract:** `AUTH_ONBOARDING_EXPERIENCE_CONTRACT.md`

## Outcome

The first app entry now starts with a CareNet healthcare gateway instead of the
old generic onboarding carousel that sent `Get started` directly to phone
signup.

The new gateway offers:

- `Browse verified care` -> public discovery route
- `Create account` -> role-first signup route
- `Already have an account? Sign in` -> email sign-in

The signup role route now behaves as a role-first entry:

```text
Create account
-> choose Patient or Medical professional
-> choose Google, email, or see phone unavailable
```

The selected role remains visible on the method screen with a `Change` action.
Google and email both keep the selected role. Phone signup is shown as
unavailable instead of being treated as a real OTP-backed signup method.

## UI Direction Applied

This slice starts the new visual direction requested for auth/onboarding:

- calm healthcare gateway
- trust/verification language
- cleaner role cards
- selected-role context before method choice
- restrained clinical green/blue support tones
- no carousel-first community/social positioning
- no fake phone-first account creation

This is the first pass, not the final full onboarding redesign. Patient setup,
professional application, readiness resolver, and status hubs still have their
own slices.

## Runtime Scope

Changed:

- `OnboardingView` is now a welcome gateway.
- `SignUpRoleSelectionPage` is now role-first with a method step.
- signup email no longer offers phone as an enabled signup method.
- legacy signup phone can still route into the role-first method step after its
  local validation, but it is no longer the app's default entry.
- shared `AuthWidget` now handles long option labels without horizontal
  overflow.
- focused auth/onboarding tests cover the new gateway and role/method behavior.

## Out Of Scope

- no backend readiness resolver
- no splash/session restore reroute change
- no email signup field cleanup
- no patient setup redesign
- no professional multi-step application redesign
- no server-side professional drafts
- no licence lifecycle implementation
- no phone OTP
- no Facebook/Apple
- no MFA/PIN/security redesign
- no production OAuth/release-signing claim

## Verification

- `dart format` on changed Dart files
- `flutter test test\features\authentication\sign_up_flow_test.dart test\features\onboarding\onboarding_gateway_test.dart`
- `flutter test test\features\authentication\sign_in_flow_test.dart`
- `flutter analyze lib\features\Onboarding\presentation\pages\onboarding.dart lib\features\Authentication\presentation\pages\sign_up_role_selection.dart lib\features\Authentication\presentation\pages\sign_up_email.dart lib\features\Authentication\presentation\pages\sign_up_phone.dart lib\shared\widgets\auth_widget.dart test\features\authentication\sign_up_flow_test.dart test\features\onboarding\onboarding_gateway_test.dart`

All passed.

## Next Slice

APP-67: Auth form cleanup and method convergence.

Recommended scope:

- remove authoritative profile fields from email signup
- keep email/password signup focused on account credentials
- make Google/email destinations visibly consistent after role selection
- keep backend patient/professional profile data in setup screens
- keep phone OTP, readiness resolver, and professional application redesign out
  of scope
