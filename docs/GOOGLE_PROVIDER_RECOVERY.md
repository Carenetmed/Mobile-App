# Google Provider Recovery

`GoogleSignInIdTokenProvider` requires the configured web OAuth client ID and
returns the SDK ID token unchanged for backend validation. No client-side
account role or session authority is introduced.

Concurrent sign-in calls share one SDK operation. Successful initialization is
reused; rejected initialization is released so another explicit attempt can
retry without restarting the application. Initialization waits are bounded to
30 seconds and return a safe recoverable error. A timed-out SDK initialization
remains in flight: retry waits for that same operation rather than starting a
second initializer. A late rejection releases it for the next attempt.

Interactive account selection remains controlled by the Google SDK. No local
timer dismisses its UI or starts another authentication while it is active.
Cancellation, unsupported platforms, missing/blank tokens, configuration
failures, and unexpected SDK errors map to user-safe domain failures. Provider
details and ID tokens are not logged.

The 19 provider tests use explicit SDK fakes and virtual-time timeout checks.
They do not prove OAuth certificate/client setup, signed Android identity,
backend account linking, or device/provider acceptance. Those remain required
release gates; custom backend authentication remains authoritative.
