# Consultation Account Authority

APP-READY-041 binds a consultation controller to the first authenticated
account and backend role resolved for that controller. Refresh cannot silently
rebind an open consultation to another account. To use another account, close
the consultation and enter through its authorized appointment route.

Permission, projection, waiting-room, admission, join-grant, end and incident
completions recheck the persisted account before delivering results or enabling
media. Media controls check the same authority before and after asynchronous
room operations. A detected sign-out, account change or role change clears the
projection/permissions, cancels polling and releases the room adapter. Revocation
is latched for that controller; returning to the original account does not reuse
its earlier grant. Repeated cleanup shares the same release operation.

Disposed controllers ignore new refresh/actions; late account checks cannot
reactivate them. No navigation argument proves identity, role or consultation
eligibility. Backend ownership, join policy and grant validation remain unchanged.

Five initial regressions reproduce refresh rebinding, delayed permission and
grant completion, delayed waiting state and stale-account microphone controls;
these failed before the initial repair. Adversarial review added ten regressions
for failed completions, a session read racing revocation, delayed disconnect,
sign-out, role changes, permanent revocation and shared pending cleanup.
Final review added eighteen cases for held resume/leave successes and failures,
stale-account microphone enabling, session-storage failure/retry and contained
cleanup errors. Disposal review added three cases for synchronous, delayed and
previously failed release errors. Another regression proves disposal waits for
an in-flight revocation release instead of starting concurrent cleanup. Three further regressions cover synchronous
and asynchronous revocation failure and cleanup reentry. The revocation latch
is installed before invoking adapter code, including code that throws immediately.
All 48 controller tests pass: 40 additions and eight unchanged
existing tests. No prior test was removed, renamed, skipped or weakened.
Failed operations check authority before preserving a same-account error;
pending session reads and disconnect completions cannot bypass latched revocation.
Resume media failures remain user-safe and cannot bypass account checks or
replace an authority failure with an obsolete permission message.
Disposal contains cleanup failures and reports only a fixed redacted diagnostic;
it does not certify resource release or reactivate disposed UI state.
The final complete suite passes with 613 tests: exactly 40 additions over the
573-test integration baseline. Flutter analysis and diff checks are clean.
Signed staging APK and AAB include compiled Flutter payloads for all three
supported ABIs and verify against the expected upload certificate. Android
release lint passes. PR CI remains a separate verification gate; no physical
device acceptance is inferred from these artifacts.

## Remaining Acceptance

This controller boundary is not continuous session-observer proof. Active-room
logout/revocation propagation, actual SDK resource cleanup races, adapter event
coverage, full call-state widgets, contextual Bluetooth permission, real provider
control-plane proof and two-device acceptance remain in the readiness program.
No physical-device or provider acceptance is inferred from fake-room tests.
