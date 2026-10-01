# Session Account Isolation

Protected requests capture the authenticated account identity at dispatch.
Their bearer token must match the current persisted session. Responses from
an account that is no longer current are rejected rather than delivered to
the new account's screen. Request metadata contains the account ID, not the
refresh token or a full session object.

Refresh operations share work only for the same account and refresh token.
A different account waits for prior refresh work to finish and then validates
its own session independently. One authenticated request retry is permitted.
Protected-resource 403 responses are permission failures, not session expiry;
they do not initiate refresh or erase the session. Missing configuration and
network failures likewise do not prove that a session has been revoked.

Background rejection clears only the exact matching session. Explicit logout
and confirmed account deletion instead use an atomic account-scoped clear,
so rotation of that account's tokens during the operation cannot leave it
signed in. A different account remains untouched. Secure storage serializes
the read and deletion as one operation. No backend authority is inferred from
navigation state.

Notification registration sharing is account-scoped. Local binding changes
are serialized with account cleanup; delayed logout or deletion for one
account cannot erase a different account's binding or pending notification.
Late unread responses are ignored after account change or disposal.

Focused regression inventory is in `account_session_isolation_test.dart`,
`session_request_context_test.dart`, and
`notification_account_isolation_test.dart`. Existing authentication, booking,
notification routing, and account tests remain enabled. These tests do not
replace provider/device acceptance or prove deployment readiness.
