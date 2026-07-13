# Frontend Backend Integration Checkpoint

**Date:** 2026-07-14
**Task:** 52.13, updated by 52.15
**Status:** Checkpoint plus reset/verification contract pointer before more runtime wiring.

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
| Password reset request | Email request calls `AuthRepository.requestPasswordReset`; final reset is blocked without secure token handling |
| Current account read | Account can read `AccountRepository.currentAccount` for safe display-only identity fields |
| Email verification request | Current email review can call `AccountRepository.requestEmailVerification`; final verification is blocked without secure token/code handling |
| Regression proof | Focused auth/session/account regression pass covers the scoped wiring above |

Source docs:

- `AUTH_SESSION_ACCOUNT_CONTRACT.md`
- `PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md`
- `DEFERRED_WORK.md`
- `DECISIONS.md` D054-D069
- `CODEBASE_STATUS.md`

---

## Verified Frontend Proof

Task `52.9` passed the focused regression set:

```bash
flutter test test/features/authentication/auth_infrastructure_test.dart test/features/authentication/sign_in_flow_test.dart test/features/authentication/sign_up_flow_test.dart test/features/authentication/finish_sign_up_test.dart test/features/authentication/password_recovery_flow_test.dart test/features/authentication/session_restore_guard_test.dart test/features/home/account_flow_test.dart
```

Focused analyze also passed on auth data, auth screens, splash guard,
Account/Edit Email, and related tests.

---

## Do Not Wire Yet

These are intentionally not ready for more frontend runtime wiring until their
contracts are explicit.

| Blocked item | Why blocked |
|--------------|-------------|
| Password reset confirmation | Contract is now defined in `PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md`; runtime wiring still needs a reset-confirm route that receives a transient token safely |
| Email verification confirmation | Contract is now defined in `PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md`; runtime wiring still needs a verification-confirm route that receives a transient token safely |
| Phone sign-in/sign-up | Needs OTP/SMS provider, delivery behavior, code confirmation API, rate limits, phone uniqueness, and session-update behavior |
| Social auth | Needs provider setup, token handoff contract, account linking rules, and failure states |
| MFA/PIN activation | Needs backend MFA model, secure PIN storage rules, recovery behavior, audit/security notifications, and session/device checks |
| Profile/account persistence | Needs profile/account update APIs, server validation, conflict handling, audit behavior, and ownership rules |
| Destructive account actions | Needs delete/deactivate backend APIs, re-auth rules, cooling-off/recovery behavior, and audit/security notifications |
| Another contract group | Needs a fresh contract decision from `DEFERRED_WORK.md` before replacing local stores |

---

## Backend/Contract Questions To Resolve Before Runtime Wiring

1. Password reset confirmation:
   - Backend route and fields are confirmed: `POST /auth/password-reset/confirm` with `token` and `newPassword`.
   - The next frontend slice must choose/reset-confirm route ownership.
   - Production app-link setup is still separate.

2. Email verification confirmation:
   - Backend route and fields are confirmed: `POST /auth/email-verification/confirm` with `token`.
   - The next frontend slice must choose verification-confirm route ownership.
   - After success, refresh current-account state if the app still has a session.

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

Do not start runtime wiring from the original checkpoint alone. Runtime wiring
must now use the task `52.15` contract.

Selected next path after task `52.15`:

```text
52.16 - Implement reset and email verification token-confirm route wiring from the confirmed backend contract, or stop if platform deep-link setup is required first
```

Task `52.15` recorded the contract in
`PASSWORD_RESET_EMAIL_VERIFICATION_CONTRACT.md`. The next slice may wire the
token-confirm Flutter routes, but must not claim production app-link setup,
phone OTP, social auth, MFA/PIN, or profile persistence.

