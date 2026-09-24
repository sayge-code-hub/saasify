# Feature: Auth (mocked)

## Status

`done` (UI mocked)

## Summary

Email/password login gate for Saasify admin. Session is in-memory only (no backend). Any non-empty credentials succeed after a short delay.

## Out of scope

- Real API, SSO, MFA, password reset, registration

## User flows

1. Unauthenticated user visiting any app route is redirected to `/login`.
2. User enters email + password → Continue → sees brief loading → lands on Overview.
3. User can sign out from the shell header menu → returns to login.

## Acceptance criteria

- [ ] Login page is branded, responsive, and uses theme tokens
- [ ] Empty fields show validation errors
- [ ] Successful login routes into the authenticated shell
- [ ] Protected routes redirect to login when signed out
- [ ] AuthCubit covered by bloc tests
- [ ] Login page smoke-tested

## State

- `AuthCubit`: `unauthenticated` | `authenticating` | `authenticated(user)` | `failure(message)`
