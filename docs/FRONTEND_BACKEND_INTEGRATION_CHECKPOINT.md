# Frontend Backend Integration Checkpoint

**Date:** 2026-07-14
**Task:** 52.13
**Status:** Checkpoint for frontend/backend alignment before more runtime wiring.

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
- `DEFERRED_WORK.md`
- `DECISIONS.md` D054-D066
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
| Password reset confirmation | Needs secure reset token/deep-link/code-entry contract, token parsing/storage rules, expired-token behavior, and route ownership |
| Email verification confirmation | Needs secure verification token/deep-link/code-entry contract, expired-token behavior, and route ownership |
| Phone sign-in/sign-up | Needs OTP/SMS provider, delivery behavior, code confirmation API, rate limits, phone uniqueness, and session-update behavior |
| Social auth | Needs provider setup, token handoff contract, account linking rules, and failure states |
| MFA/PIN activation | Needs backend MFA model, secure PIN storage rules, recovery behavior, audit/security notifications, and session/device checks |
| Profile/account persistence | Needs profile/account update APIs, server validation, conflict handling, audit behavior, and ownership rules |
| Destructive account actions | Needs delete/deactivate backend APIs, re-auth rules, cooling-off/recovery behavior, and audit/security notifications |
| Another contract group | Needs a fresh contract decision from `DEFERRED_WORK.md` before replacing local stores |

---

## Backend/Contract Questions To Resolve Before Runtime Wiring

1. Password reset confirmation:
   - Will the app receive a universal/app link, a custom scheme link, or a manual code?
   - What exact route/screen owns the token entry or link landing?
   - What fields does the confirm endpoint require?
   - What are expired/invalid/already-used token responses?

2. Email verification confirmation:
   - Will verification use a deep link, app link, or code-entry screen?
   - Does confirmation happen automatically on link open or after user action?
   - How should the app refresh current-account/email-verified state afterward?

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

Do not start runtime wiring from this checkpoint.

Recommended next slice:

```text
52.14 - Decide the next frontend/backend runtime target after checkpoint
```

Options:

1. Define password reset/email verification deep-link contract.
2. Define phone OTP/MFA contract.
3. Pick another backend contract group from `DEFERRED_WORK.md`.
4. Pause frontend integration and wait for backend contract completion.

The safest next runtime path is password reset/email verification only after the
deep-link/code contract is explicit.

