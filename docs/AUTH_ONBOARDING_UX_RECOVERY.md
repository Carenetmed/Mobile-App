# Auth onboarding UX recovery

Slice: APP-ID-015
Date: 2026-07-19

## Decision

Recover the role-first auth/onboarding entry UX from the older APP-66 through
APP-73 work without merging those branches wholesale.

## Reason

The current frontend milestone contains the newer backend-owned catalog,
readiness, profile setup, Google, and verification guidance work from APP-ID-004
through APP-ID-014, but the visible first-launch screen had regressed to the old
three-page carousel that routed users directly toward phone signup.

The older APP-66 through APP-73 branches had the better gateway and role-first
signup UX, but they predate the APP-ID backend/readiness work. A wholesale merge
would risk deleting or rolling back newer contract integration.

## Runtime boundary

- First launch now shows Browse verified care, Create account, and Sign in.
- Create account routes to `signUpRole`, not phone signup.
- Role selection asks Patient or Medical professional first.
- Gateway role selection then asks for signup method.
- Email/phone entry screens keep their existing behavior: validate entry first,
  then choose role, then continue to `finishSignUp`.
- Google signup remains real-provider only: when configured, it obtains a Google
  ID token, sends the explicit selected role to the backend, then asks backend
  readiness for the next setup route.
- No dummy fallback, local account creation, fake approval, or local readiness
  state was added.

## Preserved contracts

- Backend onboarding catalog/readiness contracts remain the source of truth.
- Patient/professional setup screens remain catalog-driven.
- Professional verification evidence guidance remains backend-readiness driven.
- Phone OTP signup remains unavailable until a real OTP contract exists.
- Facebook and Apple signup remain deferred.

## Verification

- `flutter test test/features/onboarding/onboarding_gateway_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/onboarding/onboarding_readiness_route_resolver_test.dart -r expanded`
- `flutter analyze lib/core/constants/navigators/router.dart lib/features/Onboarding/presentation/pages/onboarding.dart lib/features/Authentication/presentation/pages/sign_up_arguments.dart lib/features/Authentication/presentation/pages/sign_up_email.dart lib/features/Authentication/presentation/pages/sign_up_phone.dart lib/features/Authentication/presentation/pages/sign_up_role_selection.dart test/features/onboarding/onboarding_gateway_test.dart test/features/authentication/sign_up_flow_test.dart`
- `git diff --check`

## Next

APP-ID-017 should be selected after project-lead review of PR #147. Do not add
new onboarding product behavior until the recovered phone-smoke PR is merged or
explicitly superseded.

## Device checkpoint

APP-ID-016 completed the recovered onboarding phone smoke checkpoint:

- The staging debug APK rebuilt with the public staging gateway and the corrected
  Google Web OAuth client ID from `C:\Users\asd\Desktop\New Text Document (5).txt`.
- The APK installed on Android device `6tkvkvindaqogurk` and launched under
  `com.carenet.app`.
- UI dump confirmed the recovered first-launch gateway is visible.
- User-device smoke confirmed Google account selection and backend login reached
  the app.
- Backend staging initially returned `404` for `GET /catalogs/onboarding`; the
  backend staging service was redeployed to Cloud Run revision
  `carenet-backend-staging-00017-hvv` with image tag
  `app-id-003-catalog-readiness`.
- `GET /catalogs/onboarding` through the public staging gateway now returns the
  Nigeria onboarding catalog, unblocking controlled country/state/profession
  selectors without local dummy fallback.
- `GET /health/ready` initially returned `503` because one committed Prisma
  migration was pending in staging. After applying committed migration
  `20260719090000_identity_catalog_alignment` with `prisma migrate deploy`,
  public staging readiness returned `200` with database, migrations, email,
  Google auth, and verification storage all `ok`.

APP-ID-016 also keeps one small UX hardening fix: changing role or going back
from role selection clears stale Google/backend error text so the next selected
role starts cleanly.
