# APP-P1-021 Active-Route UX And Accessibility

## Goal

Close visual consistency and accessibility gaps across the active Phase 1
patient and professional experience without changing backend authority, adding
product scope, or reviving deferred community/content surfaces.

The active navigation remains:

- Patient: Home, Find Care, Appointments, Messages.
- Professional: Home, Schedule, Appointments, Messages.
- Header: Notifications and Account/Profile.

## Work Status

APP-P1-021 is in progress. Its first foundation slice aligns the shared
`CarenetColors` healthcare-green scale and active Material color schemes,
improves the shared `CarenetButton` semantic tap target and enlarged-text
behavior, corrects Schedule wording, and reconciles the live route inventory.

This foundation does not certify every screen. Active screens still need
route-by-route checks for contrast, semantics, focus order, keyboard operation,
tap targets, narrow layouts, and largest supported text. The route inventory is
79 constants and 78 router cases; `login` remains reserved and unwired.

## Shared Foundations

- Primary, success, error, and information text/surface pairs are checked at
  WCAG normal-text contrast of at least 4.5:1.
- `CarenetButton` has one labelled button semantic with a real tap action, a
  minimum 48 logical-pixel hit target, and content-driven height under enlarged
  text.
- New shared components use `CarenetColors`; legacy screen-specific
  `AppColors` usage is migrated only when that screen is audited.
- User-facing Schedule copy describes recurring availability plainly and does
  not expose implementation details.

## Per-Route Audit Record

For each active route, record narrow and large-text layout, contrast, semantics,
focus order, keyboard behavior where relevant, minimum tap target, loading/error
states, and one end-to-end task path. Do not mark a route passed without a test,
inspection artifact, or explicit device limitation.

Routes to audit include the auth/onboarding gateway and forms, Home, Find Care,
professional detail and booking, Appointments and detail, professional Schedule,
Messages, Notifications, Account/Profile, professional verification/finance,
and the appointment-linked consultation.

Deferred source screens are not part of the active-route acceptance sweep unless
they remain reachable through a visible or direct route. Keep their sources
recoverable and record any disconnection separately.

## Boundaries

- Do not add posts, short-form video, creator publishing, or community navigation
  through this accessibility task. A changed product direction requires a
  separately approved scope, moderation/safety policy, storage and delivery
  design, and cost gate.
- Do not claim full accessibility conformance from shared-token tests.
- Physical-device TalkBack, keyboard, and platform acceptance remain a later
  release gate after automated and cloud checks.
- Payments remain gated behind the production-readiness plan's final explicit
  user confirmation; this work does not activate or deploy payment credentials.

## Next Work

Continue APP-P1-021 with a route-by-route active-screen audit and focused
regressions. Track issues by route and severity; repair only findings that fit
the approved accessibility/UX boundary, otherwise record them for an explicitly
scoped slice.
