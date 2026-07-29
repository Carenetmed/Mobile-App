# Phase 1 Financial Experience

PAY-P1-008 connects the mobile app to the backend-owned paid-consultation
authority. Flutter presents authoritative financial state and launches hosted
checkout, but it never calculates a charge, handles card data, confirms a
payment, creates an earning, or decides payout eligibility.

## Consultation price

Public and owner professional responses expose:

- `bookable`;
- `consultationPrice.currency`;
- `consultationPrice.amountMinor`.

Only `NGN` integer minor units are accepted. The current commission snapshot is
15 percent (1500 basis points). The professional editor previews commission and
net with integer arithmetic, while immutable platform-fee and professional-net
amounts are read from the appointment payment projection after the backend
snapshots them. Specialist Details displays the exact backend gross price and
allows a booking request only when the professional is explicitly bookable with
a valid NGN price. Missing or malformed price data fails closed.

Professionals manage their price through:

- `GET /professionals/me/consultation-price`;
- `PUT /professionals/me/consultation-price`.

The mobile editor converts a validated naira input to integer kobo and displays
the resulting patient amount, CareNet commission, and professional net before
submission. The backend remains authoritative and snapshots future appointments.

## Appointment payment

Appointment projections include immutable pricing and role-safe payment state.
Appointment Detail uses:

- `GET /appointments/:appointmentId/payment`;
- `POST /appointments/:appointmentId/payment/initialize`;
- `POST /appointments/:appointmentId/payment/refresh`.

Patient checkout is available only when the backend projection permits it. One
secure UUID-style `Idempotency-Key` is persisted for the account and appointment
and reused across repeated taps, timeouts, and safe retries. A new key is not
silently generated after an uncertain result. The intent contains no tokens,
passwords, card data, or medical information and is cleared on terminal state or
successful logout.

The returned checkout URL must use HTTPS and the exact
`checkout.paystack.com` host. Flutter opens it in the system browser through
`url_launcher`. Browser return is only a hint: app resume calls the backend
refresh endpoint, and only backend verification changes payment authority.
`url_launcher_android` is pinned to `6.3.25`, the latest verified release
compatible with the repository's existing Android Gradle Plugin 8.7 baseline.
Newer releases require AndroidX artifacts that need Android Gradle Plugin 8.9.1;
the pin avoids an unrelated native-toolchain upgrade in this financial slice.

The UI distinguishes awaiting payment, processing, succeeded, expired, refund
pending, refunded, disputed, reversed, review required, and unknown states. It
does not describe `REQUESTED` as accepted or payment initialization as payment
success. Professionals can see the role-safe amount and net projection but
cannot launch patient checkout.

## Professional finance

The professional Account surface exposes `Payments & payouts`, which uses:

- `GET /professionals/me/finance`;
- `GET /professionals/me/finance/banks`;
- `POST /professionals/me/finance/payout-profile/resolve`;
- `POST /professionals/me/finance/payout-profile/confirm`;
- `GET /professionals/me/finance/payout-profile`;
- `DELETE /professionals/me/finance/payout-profile`.

The finance view shows backend-derived held, eligible, available, processing,
paid, and negative balances, plus payout pause/review state, recent ledger
entries, and payout history. A paid completed consultation creates a held earning
in backend authority; the default hold is 72 hours. The app does not claim that a
held amount is withdrawable.

Bank setup uses the backend Nigerian bank catalogue, requires a 10-digit account
number, resolves the name through the backend, shows only masked account details
for confirmation, and clears the raw entry after resolution. Transfer-recipient
codes are never rendered. Bank replacement cooling and review state come from
the backend; Flutter does not provide instant withdrawal or bypass payout pauses.

## Failure and privacy rules

- `401` follows existing session recovery without claiming financial success.
- `403` is presented as a role/permission failure, not as a request to sign in.
- `404` treats the financial resource as unavailable.
- `409` reloads authoritative state and preserves the same retry identity when
  appropriate.
- Network ambiguity never becomes a local success or a definite no-charge claim.
- Raw provider errors, internal references, recipient codes, full bank numbers,
  checkout keys, and credentials are not displayed or logged.

## Backend financial authority

Backend main at `c2327e7232b2512ff1553ffb251e98cf96aa2026` contains the
collection, refund/reversal, ledger, earning hold, payout profile, and automated
payout authority delivered by PAY-P1-008A. It owns:

- immutable appointment price snapshots;
- Paystack transaction initialization and verification;
- signed webhook inbox and reconciliation;
- late-success and refund-review handling;
- full administrative refund state;
- append-only professional ledger and negative balances;
- configurable 72-hour earning hold;
- payout reservation, manual fallback, transfer submission, and reconciliation;
- configurable weekly batching, global execution pause, and bank-change cooling.

Automatic live transfer execution remains disabled by default. Missing Paystack
test credentials block live-provider collection/transfer proof, not deterministic
provider tests, CI, or safe merge. No live payment or payout should be claimed
without separate staging evidence.

## Deferred

The following remain outside PAY-P1-008:

- stored cards, wallets, subscriptions, coupons, instalments, cash, insurance,
  tax invoices, partial refunds, and patient-initiated refunds;
- instant professional withdrawal, immediate split settlement, multi-currency,
  or another live provider;
- notification-provider delivery and live-provider certification where
  non-production credentials are unavailable;
- broad appointment, messaging, or navigation redesign.

No later capability starts automatically after this milestone. External Fibery
sync also remains unavailable when `FIBERY_TOKEN` is not configured; committed
repository proof must not be presented as a successful external sync.
