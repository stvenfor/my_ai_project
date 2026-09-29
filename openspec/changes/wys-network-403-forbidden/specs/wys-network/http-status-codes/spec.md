## Purpose

Defines `wys_network` shared HTTP/business status codes and how the response interceptor treats authorization denial (403) versus authentication failure (401).

## ADDED Requirements

### Requirement: Status catalog includes HTTP 403 Forbidden
The shared network status-code catalog MUST expose a named constant whose value is exactly `403` for authorization denial, alongside existing entries for success (`200`), token expiry (`401`), and rate limiting (`429`).

#### Scenario: Catalog exposes forbidden as 403
- **WHEN** a client reads the shared status-code catalog for authorization denial
- **THEN** the catalog MUST provide a named entry equal to `403`

### Requirement: Response interceptor handles HTTP 403 without logout
When the response interceptor observes HTTP status `403`, or a business body `code` equal to `403`, the system MUST treat the outcome as authorization denial. The system MUST invoke a forbidden-specific network event callback when one is registered. The system MUST NOT invoke the token-expired / force-logout callback used for HTTP `401`.

#### Scenario: HTTP 403 on response path
- **WHEN** an HTTP response has status `403`
- **THEN** the response interceptor MUST notify the forbidden callback (if registered)
- **AND** MUST NOT notify the token-expired callback
- **AND** the session MUST remain eligible to stay logged in from the network layer's perspective

#### Scenario: HTTP 403 on error path
- **WHEN** a transport/error path exposes HTTP status `403`
- **THEN** the response interceptor MUST notify the forbidden callback (if registered)
- **AND** MUST NOT notify the token-expired callback

#### Scenario: Business body code 403
- **WHEN** an HTTP success-status response carries a business body `code` of `403`
- **THEN** the response interceptor MUST treat it as forbidden (same callback rules as HTTP 403)
- **AND** MUST NOT treat it as token expiry

#### Scenario: HTTP 401 remains distinct
- **WHEN** an HTTP response has status `401` (or business `code` `401`)
- **THEN** the response interceptor MUST continue to use the existing token-expired handling path
- **AND** that path MUST remain distinct from forbidden handling

### Requirement: Callers can detect forbidden failures
The shared network error type MUST expose a boolean indicator that is true when either the HTTP status or the business `code` equals `403`, and false for token-expiry-only failures.

#### Scenario: Forbidden flag on 403 error
- **WHEN** a network error carries HTTP status `403` or business `code` `403`
- **THEN** the error's forbidden indicator MUST be true
- **AND** the token-expired indicator MUST be false
