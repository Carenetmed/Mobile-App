# Auth session account backend contract

**Task:** 51.2
**Status:** Contract accepted; infrastructure boundary implemented in task 52.1.
**Scope:** Define the Flutter-side contract before wiring auth, session, or account screens to the backend.

This contract is the source of truth for replacing the current local/client-only authentication and account behavior. It does not enable any locked controls by itself.

---

## Source of truth

| Source | Role |
|--------|------|
| `C:\Users\asd\Music\carenet-backend-lab\docs\48-auth-session-frontend-bridge-package.md` | Backend route and response contract prepared for Flutter handoff |
| `docs\DEFERRED_WORK.md` | Current local seams and what still needs backend replacement |
| `docs\DECISIONS.md` D054 | Product/technical decision for this contract |
| `lib\core\services\api_service.dart` | Legacy helper to replace, not reuse as-is |

---

## Contract decision

Use the CareNet REST backend as the auth/session/account authority.

The Flutter app must not treat local validation as authentication. Local validation may stay as a usability layer, but successful sign-in, sign-up, refresh, account reads, account updates, password reset, email verification, and provider linking must come from backend responses.

The next implementation slice should add the infrastructure boundary first: environment base URL config, a safe API client, auth/account models, session storage, repositories, and tests. Screen wiring should come after that boundary exists.

---

## Environment and base URL rules

| Environment | Base URL rule |
|-------------|---------------|
| Local dev without backend | Leave backend-backed actions disabled or route through local-only behavior already documented in `DEFERRED_WORK.md` |
| Local dev with staging proxy | Use a configurable local proxy URL such as `http://127.0.0.1:8080` on desktop or `http://10.0.2.2:8080` on Android emulator |
| Staging device build | Use an explicit staging API base URL supplied at build/runtime config time |
| Production | Use the production API base URL only after production backend, domain, email, compliance, and release gates are complete |

Rules:

1. Do not hard-code private Cloud Run URLs, API keys, or secrets in Dart code.
2. Do not keep `baseUrl = ""` as the final integration mechanism.
3. Do not silently fall back from a configured backend to local success behavior.
4. If required backend config is missing, fail closed with an honest disabled/error state.

---

## API style

| Rule | Decision |
|------|----------|
| Transport | HTTPS JSON REST through the CareNet backend |
| Client | A dedicated safe auth/account API client, not the existing legacy helper as-is |
| Auth header | `Authorization: Bearer <accessToken>` only |
| Cookie auth | Do not send `Cookie: auth=<token>` from Flutter |
| Request IDs | Accept and preserve backend request/error metadata when provided |
| Logging | Never log passwords, reset codes, verification codes, access tokens, refresh tokens, cookies, or full auth response bodies |

The existing `ApiService` should be replaced or heavily refactored before backend auth use because it was built before this contract and is not the final safe boundary.

---

## Auth routes to consume

The Flutter app should consume the backend route names from the bridge package rather than inventing app-local endpoints.

| Capability | Flutter expectation |
|------------|---------------------|
| Sign up | Send validated email/password/profile fields to backend; navigate only after server success |
| Sign in | Exchange credentials for a backend session; local validation alone is not success |
| Sign out | Clear local session after backend sign-out if endpoint exists; otherwise clear local session and record server sign-out as deferred |
| Refresh session | Use refresh token to obtain a new access token; if refresh fails, clear session and require sign-in |
| Current account | Load user/account profile from backend after session restore |
| Password recovery | Request reset through backend; responses must avoid account enumeration |
| Password reset | Submit token/code/new password through backend; never store reset token after use |
| Email verification | Use backend verification request/confirm flows; staging email is internal proof only |
| Google sign-in/linking | Use backend-supported provider token handoff only after frontend provider setup is explicit |

Phone OTP, MFA/PIN activation, Google unlink, destructive account APIs, public profile persistence, and production email/domain behavior remain deferred unless a later task marks them `NEXT`.

---

## Session model

The app should model a backend session as:

| Field | Rule |
|-------|------|
| `accessToken` | Short-lived bearer token used for API calls |
| `refreshToken` | Long-lived secret stored in secure storage |
| `tokenType` | Expected `Bearer` |
| `expiresAt` or `expiresIn` | Used to refresh before protected calls when possible |
| `user.id` | Backend user identifier; never user-editable |
| `user.email` | Server-returned account email |
| `user.role` | Server-returned role such as patient/professional/admin |
| `user.status` | Server-returned account status |
| `user.emailVerified` | Server-returned email verification state |

Local cached user/account data is only a convenience snapshot. Backend remains authoritative after refresh or app restart.

---

## Storage rules

Use `flutter_secure_storage` for session secrets.

| Item | Storage rule |
|------|--------------|
| Refresh token | Store in secure storage only |
| Access token | Prefer memory plus refresh-on-start; if persisted for app resume, use secure storage and clear on sign-out |
| User snapshot | May be cached as non-authoritative local state |
| Passwords/codes | Never persist |
| Provider tokens | Never persist unless a later provider-specific decision explicitly allows it |

Sign-out, refresh failure, account deletion/deactivation, or invalid-session responses must clear local tokens before routing the user back to auth.

---

## Repository replacement plan

Create a boundary that lets existing screens move from local behavior to backend behavior without rewriting whole pages.

| Layer | Responsibility |
|-------|----------------|
| `AuthApiClient` | Low-level auth/account HTTP calls, safe headers, safe errors |
| `SessionStore` | Secure token persistence, session restore, clear-on-failure |
| `AuthRepository` | Sign-up, sign-in, sign-out, refresh, verification, password reset |
| `AccountRepository` | Current account read/update and account-security entry points |
| Presentation state | Form validation, loading/error states, navigation after repository success |

The first implementation slice should create the boundary and tests before wiring every screen.

---

## Validation and error behavior

| Case | Required behavior |
|------|-------------------|
| Invalid local form | Show local validation before network call |
| Backend validation error | Show field/global error without leaking internals |
| Wrong credentials | Show generic sign-in failure |
| Password reset request | Show generic sent/next-step state whether or not email exists |
| Email verification request | Show generic next-step state; do not imply production email is ready |
| Expired access token | Attempt refresh once, then retry the original request |
| Expired/invalid refresh token | Clear session and require sign-in |
| Network failure | Show retryable error; do not mark auth success |
| Missing backend config | Fail closed; do not fake success |

---

## Explicitly deferred

Do not implement these under task 51.2 or the immediate infrastructure slice unless a later `AI_HANDOFF.md` row marks them `NEXT`:

- Phone OTP/SMS delivery and code confirmation
- MFA/PIN enablement, secure PIN storage, and recovery rules
- Google/Facebook/Apple production provider setup
- Google unlink and provider account management
- Destructive account APIs beyond documented local drafts
- Public profile persistence and creator/provider profile APIs
- Payments, subscriptions, ads, refunds, or invoices
- Push notifications and production email delivery guarantees
- Deep links for reset/verification unless the next task explicitly scopes them
- Compliance/legal launch claims

---

## Next implementation boundary

Task `52.1` implemented:

- `CareNetApiConfig` for environment API base URL config.
- `AuthApiClient` for auth/account route calls with bearer-only headers.
- `SessionStore`, `SecureSessionStore`, and `InMemorySessionStore`.
- Auth user/session/failure models.
- `AuthRepository` and `AccountRepository`.
- DI registration without screen wiring.
- Focused tests for missing config, bearer-only headers, session storage, refresh token rotation, and unauthorized session clearing.

Recommended next task:

`52.2 - Wire the first auth screen to the repository boundary, starting with email sign-in only: preserve local validation, require backend config for backend success, show safe loading/error states, and keep phone/social/security flows deferred.`

Definition of done for that next task should include:

1. Email sign-in keeps existing client-side validation.
2. Valid email sign-in calls `AuthRepository.login`.
3. Missing backend config shows an honest error and does not navigate.
4. Backend success stores session through the repository boundary and then navigates.
5. Backend failure shows a safe generic error and does not log credentials/tokens.
6. Phone sign-in, sign-up, social auth, password reset, and account-security screens remain unchanged unless explicitly scoped.
