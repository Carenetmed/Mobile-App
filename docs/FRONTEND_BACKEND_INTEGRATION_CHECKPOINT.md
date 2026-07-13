# Frontend Backend Integration Checkpoint

**Date:** 2026-07-14
**Task:** 52.13, updated by 52.15 and 52.16
**Status:** Checkpoint plus reset/verification token-confirm wiring status.

This checkpoint summarizes the frontend auth/session/account integration work
that is complete, what is intentionally not wired, and what backend/deep-link
contracts are needed before the next runtime slice.

---

## Current Frontend Integration Status

The app has a backend-ready auth/session/account boundary and several scoped
screens are already wired to it.

| Area | Status |
|------|--------|
| Auth infrastructure boundary | Complete: API config, safe client, session stores, auth/session/user models, repositories, and DI registration exist |
| Email sign-in | Wired to `AuthRepository.login` after local validation; navigates only after repository success |
| Email sign-up completion | Wired to `AuthRepository.register` after local validation; uses validated email passed from email entry |
| Session restore | Splash calls `AuthRepository.restore`; usable sessions go to dashboard, missing/invalid/failed restore goes to onboarding |
| Logout | Account calls `AuthRepository.logout`; success clears navigation back to onboarding |
| Password reset request/confirm | Email request calls `AuthRepository.requestPasswordReset`; `resetPasswordConfirm` calls `AuthRepository.confirmPasswordReset` only when opened with a transient token |
| Current account read | Account can read `AccountRepository.currentAccount` for safe display-only identity fields |
| Email verification request/confirm | Current email review can call `AccountRepository.requestEmailVerification`; `emailVerificationConfirm` calls `AccountRepository.confirmEmailVerification` only when opened with a transient token and then attempts account refresh |
| Regression proof | Focused auth/session/account regression pass covers the scoped wiring above |

Source docs:

- `AUTH_SESSION_ACCOUNT_CONTRACT.md`
- `PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md`
- `DEFERRED_WORK.md`
- `DECISIONS.md` D054-D070
- `CODEBASE_STATUS.md`

---

## Verified Frontend Proof

Task `52.9` passed the focused regression set:

```bash
flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/authentication/session_restore_guard_test.dart test/features/home/account_flow_test.dart
```

Focused analyze also passed on auth data, auth screens, splash guard,
Account/Edit Email, and related tests.

Task `52.16` additionally passed:

```bash
flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/home/account_flow_test.dart
flutter analyze lib/core/constants/navigators/routeName.dart lib/core/constants/navigators/router.dart lib/features/Authentication/data/services/auth_api_client.dart lib/features/Authentication/data/repositories/auth_repository.dart lib/features/Authentication/presentation/pages/reset_password_confirm_page.dart lib/features/Authentication/presentation/pages/email_verification_confirm_page.dart test/features/authentication/auth_infrastructure_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/home/account_flow_test.dart
```

---

## Do Not Wire Yet

These are intentionally not ready for more frontend runtime wiring until their
contracts are explicit.

| Blocked item | Why blocked |
|--------------|-------------|
| Production reset/verification app links | Token-confirm routes exist, but Android App Links/iOS Universal Links, domain association, and staging link smoke are not completed |
| Phone sign-in/sign-up | Needs OTP/SMS provider, delivery behavior, code confirmation API, rate limits, phone uniqueness, and session-update behavior |
| Social auth | Needs provider setup, token handoff contract, account linking rules, and failure states |
| MFA/PIN activation | Needs backend MFA model, secure PIN storage rules, recovery behavior, audit/security notifications, and session/device checks |
| Profile/account persistence | Needs profile/account update APIs, server validation, conflict handling, audit behavior, and ownership rules |
| Destructive account actions | Needs delete/deactivate backend APIs, re-auth rules, cooling-off/recovery behavior, and audit/security notifications |
| Another contract group | Needs a fresh contract decision from `DEFERRED_WORK.md` before replacing local stores |

---

## Backend/Contract Questions To Resolve Before More Runtime Wiring

1. Password reset confirmation:
   - Backend route and fields are confirmed: `POST /auth/password-reset/confirm` with `token` and `newPassword`.
   - `resetPasswordConfirm` owns the token-confirm route.
   - Production app-link setup is still separate.

2. Email verification confirmation:
   - Backend route and fields are confirmed: `POST /auth/email-verification/confirm` with `token`.
   - `emailVerificationConfirm` owns the token-confirm route.
   - After success, the app attempts current-account refresh if it still has a session.

3. Phone OTP:
   - Which provider is used?
   - What rate-limit/cooldown UI is required?
   - Does adding/changing phone require password re-auth?

4. MFA/PIN:
   - Is PIN a local app lock, backend MFA factor, or both?
   - Is biometric support in scope?
   - What recovery flow exists if the user loses the factor?

5. Next contract group:
   - If not continuing auth/account, choose exactly one group from
     `DEFERRED_WORK.md` and define its backend/frontend replacement contract
     before wiring screens.

---

## Recommended Next Step

Do not start the next runtime area from the original checkpoint alone. Use the
task `52.15` contract and task `52.16` wiring status.

Selected next path after task `52.16`:

```text
52.17 - Decide the next backend-integration lane after reset/verification token-confirm wiring
```

The next slice should decide between production app-link setup, phone OTP/MFA
contracting, an auth/account regression checkpoint, another backend contract
group, or pausing frontend integration. It must not silently broaden runtime
scope.

