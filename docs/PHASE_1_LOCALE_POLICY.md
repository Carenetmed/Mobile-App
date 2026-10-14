# Phase 1 Locale Policy

## APP-READY-064 - Verified Source (2026-10-15)

Base: PR #229 integration `5955616039ce4bec8b9077d1c54f75e4649e5d82`,
811 tests. This slice changes presentation only, not business authority.

## Policy

- Phase 1 app language is English and app locale identity is `en_NG`.
- Dates are day-first. Prefer `d MMM y` for readable dates and `dd/MM/yyyy`
  for compact date entry. Contextual short/relative labels may omit the year.
- Visible appointment/message/availability times use a consistent twelve-hour
  clock with `am/pm`. Midnight at a recurring-window end of 1440 minutes is shown
  as `12:00 am (next day)`, not as a different stored minute value.
- App clock presentation is explicit, not silently inherited from the device's
  language or 24-hour preference. Text scaling, animation accessibility settings,
  screen dimensions and other media preferences remain intact.
- Nigerian naira display keeps the existing `NGN` code, comma grouping and two
  decimal places, using integer minor units. No exchange or arithmetic changes.
- Money input keeps the existing ASCII decimal-point contract. Locale changes
  do not make commas or translated digits valid API amounts.

## Bundled Data Boundary

The pinned `intl` 0.20.2 date data does not include `en_NG`. Do not pretend it
does or hand-roll a calendar/translation table. Use bundled `en_GB` English
day-first date data as an explicit presentation fallback. Number formatting
keeps the existing `en_NG` locale request. The application remains identified as
English/Nigeria; no other language is advertised or selected automatically.

Flutter's SDK `flutter_localizations` is the only added dependency. Its standard
English day-first Material/Cupertino translations supply controls and validation
messages; the Material clock format is explicitly twelve-hour. No hosted
package version changes. Bundled date data initializes before the app runs,
without network access; the same initialization runs in tests. The application
does not mutate the ambient `Intl.defaultLocale`.

## Authority Preserved

Formatting consumes the date/time value chosen by the existing caller. Existing
patient-device `.toLocal()` conversion and professional IANA timezone conversion
remain unchanged. Locale identity never substitutes `Africa/Lagos` for the
device's timezone or a professional's configured timezone. UTC request/response
instants, duration, lead time, horizon, recurring weekdays 0..6 and availability
minute boundaries remain backend owned. No requestable-time generation is added.

Currency codes, amounts, statuses, ownership and lifecycle transitions remain
backend owned. No payment provider activation, notification delivery, auth
provider change or clinical language/diagnostic mapping is part of this slice.

## Scope And Verification

Root locale setup, active display labels, existing professional-time and money
formatters, SDK dependency declaration, focused regressions and canonical docs.
Deferred content/reading/local-schedule source is not redesigned or promoted.
Existing API parsing, repositories, schemas, native application configuration,
assets and navigation contracts must not change.

### Test Inventory Against The 811-Test Base

Eight added tests in `test/core/presentation/carenet_locale_test.dart` cover
reusable initialization without ambient-locale mutation; exact NGN display;
unchanged amount input; English IANA labels; DST conversion; day-first Material
controls; accessibility media preservation; and actual app locale selection.
Two additions in `test/features/home/professional_schedule_test.dart` cover
Sunday/midnight display without mutation and twelve-hour editor labels with
unchanged submitted minutes under a 24-hour device preference. Expected net +10.

Existing tests retain their names and assertions. Only expected display strings
change: two booking formatter assertions and eleven detail-flow labels use
lowercase `am`; Home's `Jul 24` becomes `24 Jul`; profile document date becomes
`15 Jul 2026`; availability becomes `9:00 am - 5:00 pm`. No removed, renamed,
merged, skipped or disabled tests. Full-suite discovery must independently
confirm 821 tests; the count alone does not prove preservation.

### Later Device Checks

Use an English and a non-English device with 12/24-hour preferences. Inspect
date/time pickers, account receipt, document dates, Home, appointments, finance,
messages and notifications. Confirm day-first English labels and professional
versus local timezone distinction. Repeat at largest text and with TalkBack.
These manual checks are not claimed passed by unit/widget or simulator CI.

Local full suite passed all 821 tests (811 retained + 10 added) in 4 minutes
26 seconds. Analyzer reports no issues. Backup privacy (25 negative probes),
iOS flavor static consistency, new-file formatting and diff checks pass.
The initial full run found three old display expectations; only those exact
labels were updated, then the whole suite reran green. Earlier targeted booking
output also identified uppercase AM expectations, corrected without assertion
removal. Independent read-only review found no blocking source defect.

Both unchanged exact-head CI lanes (Ubuntu analyzer/test/APK/release lint and
signing/environment probes; staging/production iOS simulator) remain merge gates.
CI must also validate the resulting integration commit. Local native builds
remain constrained by the recorded C: disk headroom gate; no local native pass
is claimed or CI weakened. iOS signing/hardware and deployed/device acceptance
remain separate full-program gates. Payments stay last after final confirmation.

Next source task after merge: APP-READY-065, reconcile the five historical backend
Prisma index-name differences using the locked client before any promotion.
No backend work or cloud activation is part of APP-READY-064.
