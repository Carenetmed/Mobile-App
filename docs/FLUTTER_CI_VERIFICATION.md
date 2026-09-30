# Flutter Integration Verification

Pull requests targeting `feature/frontend-milestone` test GitHub's synthetic
merge commit, not only the isolated PR head. Checkout uses the triggering
`github.sha` with two levels of history. A required identity step verifies
the checked-out commit and both parents against the event's base and head
SHAs before analyzer, tests, APK build, and release lint run.

Integration-branch pushes and manual dispatch check the exact triggering SHA.
Read-only permissions, cancellation of superseded runs, dependency-lock
integrity, and required-command failure behavior are unchanged.

A green historical run does not prove compatibility with a later base.
Before merging, compare the current base/head against the reviewed event;
refresh or rerun against the new integration result when necessary. Merged
integration pushes are verified independently. Signing/provider/distribution
and physical acceptance retain their own gates; PR CI does not grant them.
