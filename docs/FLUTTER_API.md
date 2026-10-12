# OwlSonic API for the Flutter client

Client-facing summary. The machine-readable contract is [`openapi.json`](openapi.json) (OpenAPI 3.1,
committed; production serves no `/docs`). The rules behind it: `API_CONVENTIONS.md` and the
feature specs in the backend repository (not copied here). Everything here is the implemented behavior, not a plan. Auth contract baseline: backend PR #8 (email verification and password recovery), merged as `f8bac09` (PR head `267ef89`).

- **Base URL:** `https://api.owlsonic.stream` — product endpoints live under `/v1`; `/health/live` and `/health/ready` are unversioned.
- **Compatibility:** inside `/v1` changes are additive. Ignore unknown response fields and unknown error codes.
- **Time and IDs:** RFC 3339 UTC timestamps, snake_case JSON, UUID strings. **You generate** Track, playlist, playlist-item and play-event IDs as UUIDv7; the server never replaces them.

## Authentication

`POST /v1/auth/login` takes `{"email", "password", "device": {"installation_id", "platform", "device_name"?, "app_version"?}}`
(`platform` 1–32 characters of `[A-Za-z0-9._-]`) and returns
`{"access_token", "refresh_token", "token_type": "bearer", "access_expires_in", "refresh_expires_at"}`.

- Send `Authorization: Bearer <access_token>` on every other `/v1` call (never in a query string).
- On `401` refresh once with `POST /v1/auth/refresh` `{"refresh_token"}`, store **both** new tokens, retry; if refresh fails, log in again.
- Refresh tokens are **rotated on every refresh** and single-use: every `200` carries a new `refresh_token` (the only valid one, store it) and a new `access_token`; the presented token is consumed. A consumed token is `401 INVALID_REFRESH_TOKEN`: within the grace window (default 10 s) the session survives and the successor stays valid, later reuse revokes the session. If the response of a successful refresh was lost, log in again.
- `POST /v1/auth/logout` ends the session; `GET /v1/devices` / `DELETE /v1/devices/{id}` list and revoke devices; `GET /v1/me` returns the account.
- `DELETE /v1/me` with `{"password"}` starts irreversible account deletion (`202`); afterwards every call is `401`: clear cloud credentials and continue local-only.

### Passwords

8–128 characters, nothing else is required (no digits, capitals or symbols). Existing accounts keep their current password. A violation is
`422 INVALID_REQUEST` with, in `details`, an entry you can show verbatim:
`{"loc": ["body","password"], "type": "password_too_short", "message": "Password must be at least 8 characters."}`
(`password_too_long`: "Password must be at most 128 characters."). Password reset reports the same on `loc ["body","new_password"]`.
Branch on `type`, validate the length on the device too.

### Auth contract reference (email verification and password recovery)

Schemas are in [`openapi.json`](openapi.json): `RegisterRequest`, `PendingVerificationResponse`, `VerifyEmailRequest`,
`EmailRequest`, `CodeRequestAccepted`, `ResetPasswordRequest`, `LoginRequest`, `CredentialsResponse`, `DeviceDescriptor`.
Each operation lists its codes in `x-error-codes` (status, `error.code`, `retryable`, meaning).

| Endpoint | Request body | Success | Errors (`error.code`) |
| --- | --- | --- | --- |
| `POST /v1/auth/register` | `{email, password, device}` | `201 PendingVerificationResponse` (no tokens) | `409 EMAIL_ALREADY_REGISTERED`, `422 INVALID_REQUEST`, `429 RATE_LIMITED`, `503 EMAIL_DELIVERY_FAILED` |
| `POST /v1/auth/verify-email` | `{email, code, device}` | `200 CredentialsResponse` | `400 INVALID_CODE`, `422 INVALID_REQUEST`, `429 CODE_ATTEMPTS_EXCEEDED`, `429 RATE_LIMITED` |
| `POST /v1/auth/resend-verification` | `{email}` | `202 CodeRequestAccepted` | `422 INVALID_REQUEST`, `429 RESEND_COOLDOWN`, `429 RATE_LIMITED` |
| `POST /v1/auth/login` | `{email, password, device}` | `200 CredentialsResponse` | `401 INVALID_CREDENTIALS`, `403 EMAIL_NOT_VERIFIED`, `422 INVALID_REQUEST`, `429 RATE_LIMITED` |
| `POST /v1/auth/forgot-password` | `{email}` | `202 CodeRequestAccepted` | `422 INVALID_REQUEST`, `429 RESEND_COOLDOWN`, `429 RATE_LIMITED` |
| `POST /v1/auth/reset-password` | `{email, code, new_password}` | `204` (empty body) | `400 INVALID_CODE`, `422 INVALID_REQUEST`, `429 CODE_ATTEMPTS_EXCEEDED`, `429 RATE_LIMITED` |

- `PendingVerificationResponse`: `{"status": "verification_required", "email", "code_length": 6, "code_expires_in": 600, "resend_available_in": <seconds>}`. `email` is the normalized address (trimmed, lower-case): use it for the following calls.
- `CodeRequestAccepted`: `{"status": "accepted", "code_length": 6, "code_expires_in": 600, "resend_available_in": 60}`.
- `CredentialsResponse` (verify-email and login): `{"access_token", "refresh_token", "token_type": "bearer", "access_expires_in", "refresh_expires_at"}`.
- **Code format:** exactly six ASCII digits (`[0-9]{6}`). Anything else is `422 INVALID_REQUEST` with `details: [{"loc": ["body","code"], "type": "invalid_code_format", "message": "Enter the 6-digit code."}]` and does **not** count as an attempt.
- **Email:** a syntactically valid ASCII address up to 254 characters, otherwise `422` with `details: [{"loc": ["body","email"], "type": "value_error"}]`. The server trims and lower-cases it; dots and `+tags` are significant.
- **Validation `details`:** `[{"loc": [...], "type": "<stable id>", "message"?: "<text safe to show>"}]`. Only `password_too_short`, `password_too_long` and `invalid_code_format` carry a `message`; for the others use your own copy. Submitted values are never echoed.

**`Retry-After`** (integer seconds, response header):

| Response | `Retry-After` |
| --- | --- |
| `429 RESEND_COOLDOWN` (resend-verification, forgot-password) | yes: seconds until the next code may be requested (at least 1) |
| `429 RATE_LIMITED` (any auth endpoint) | yes: seconds until the window frees |
| `429 CODE_ATTEMPTS_EXCEEDED` | **no**: the code is dead; request a new one (subject to the cooldown) |
| `503 EMAIL_DELIVERY_FAILED` | no: retry right away (`retryable` tells whether it may succeed) |

**`installation_id` rules** (`device.installation_id`, same field in register, verify-email and login):

- 8–64 characters of `[A-Za-z0-9._-]`, otherwise `422 INVALID_REQUEST` with `details: [{"loc": ["body","device","installation_id"], "type": "value_error"}]`.
- Generate it once per app installation and persist it; it identifies the installation, not the user.
- **Register binds the pending account to the `installation_id` it sent.** `verify-email` succeeds only with that same `installation_id`. A different one is answered exactly like a wrong code (`400 INVALID_CODE`) **and counts as one of the five attempts, even if the code itself is correct**, so a mismatching client can lock the code (`429 CODE_ATTEMPTS_EXCEEDED`).
- `resend-verification` and `login` do **not** change the binding. Only `register` does (the latest registration wins).
- After a successful verification the binding is gone; the device row is created with the `installation_id` of the `verify-email` request.

### Sign-up with email verification (new)

1. `POST /v1/auth/register` `{"email","password","device"}` → `201 {"status":"verification_required","email","code_length":6,"code_expires_in":600,"resend_available_in":60}`.
   **No tokens are returned.** Remember `email` and the `installation_id` you sent (keep the same `installation_id` for the next step) and show the six-digit code screen. Start a 60 s resend timer from `resend_available_in`.
   - `409 EMAIL_ALREADY_REGISTERED`: that address has a verified account → offer login.
   - Registering again with an address whose verification is still pending is **not** an error: you get `201` again. The newest password **replaces** the stored one and the newest `installation_id` becomes the bound one. Within the 60 s cooldown no second email is sent and `resend_available_in` is the **remaining** seconds; after it a new code is sent and the previous code stops working.
   - `503 EMAIL_DELIVERY_FAILED` (`retryable`): the email could not be sent; the pending account exists. Show "We couldn't send the email" and let the user retry (register again or resend).
2. `POST /v1/auth/verify-email` `{"email","code","device"}` → `200` Credentials (same body as login). The user is signed in: store the tokens.
   - `400 INVALID_CODE`: wrong, expired, already used or replaced code (deliberately indistinguishable). Show "That code is incorrect or has expired" with a **Resend code** action.
   - `429 CODE_ATTEMPTS_EXCEEDED`: too many wrong tries (5 per code); the code is dead, ask for a new one via resend.
   - `422 INVALID_REQUEST`: the code is not exactly 6 digits (validate on the device; this does not count as an attempt).
   - Send the **same `installation_id` as in register**; a different one gets `INVALID_CODE`. After a reinstall, register again.
3. `POST /v1/auth/resend-verification` `{"email"}` → `202 {"status":"accepted","code_length":6,"code_expires_in":600,"resend_available_in":60}` for any well-formed address (it never says whether the address exists). Within 60 s of the last code: `429 RESEND_COOLDOWN` with `Retry-After` (seconds); disable the button for that long.
4. **Resuming after an app restart:** persist `{pending_email, installation_id}` locally while verification is pending and reopen the code screen (the last emailed code stays valid for 10 minutes; offer **Resend** otherwise). If the user logs in instead, `POST /v1/auth/login` returns `403 EMAIL_NOT_VERIFIED` (only when the password is right): route to the code screen and call resend-verification (this works only on the installation that registered; see item 5).
5. **Resuming on another device (or after a reinstall).** The pending account is bound to the registering `installation_id`, so there is **no verify-only path from a different installation**:
   - Device B cannot finish with `login` (it returns `403 EMAIL_NOT_VERIFIED`), `resend-verification` (it sends a code but keeps the binding on device A) or `verify-email` with its own `installation_id` (`INVALID_CODE`, counted as an attempt).
   - Device B can finish by calling **`register` again** with the same email, the password the user wants, and its own `installation_id`. This rebinds the account to device B, **overwrites the stored password with the one just sent**, and (after the cooldown, otherwise the code already in the mailbox stays valid) emails a new code; then call `verify-email` from device B with that code.
   - Device A, if it still holds the original `installation_id`, can always finish with the emailed code.
   - Nothing lives on the server that lets the app list pending registrations; persist `pending_email` and `installation_id` locally.
6. Until verified the account has no tokens, so every authenticated call (upload, library, sync, …) is impossible. Existing accounts are already verified and unaffected.

### Forgot password (new)

1. `POST /v1/auth/forgot-password` `{"email"}` → always `202` (same body as resend; never reveals whether the address exists). Always show "If an account exists for that address, we sent a code." `429 RESEND_COOLDOWN` with `Retry-After` when asked again within 60 s.
2. `POST /v1/auth/reset-password` `{"email","code","new_password"}` → `204` (no body). Errors: `400 INVALID_CODE` (wrong/expired/used), `429 CODE_ATTEMPTS_EXCEEDED`, `422` (code format, `password_too_short`/`password_too_long`; the code is not consumed on a 422).
3. After `204` every session of the account is revoked (all refresh tokens stop working; an access token already in memory may work for up to 15 more minutes): drop stored tokens on every device, send the user to the **login** screen and log in with the new password.

## Errors

Every non-2xx response is `{"error": {"code", "message", "retryable", "request_id"}}` (validation errors add `details`).
Branch on `code`, never on `message`; `retryable` tells whether the same request may succeed later. Every response carries
`X-Request-ID` (send your own to correlate). `429 RATE_LIMITED` and some `503`s carry `Retry-After` (seconds).

Statuses: 400 malformed (cursor, host) or bad one-time code, 401 credentials, 403 policy/quota/unverified email, 404 absent *or not yours*, 409 conflict, 413 too large, 422 validation, 429 throttled, 503 dependency down (retry).

Codes: `INVALID_REQUEST`, `NOT_FOUND`, `METHOD_NOT_ALLOWED`, `INTERNAL_ERROR`, `SERVICE_UNAVAILABLE`, `UNAUTHORIZED`, `INVALID_CREDENTIALS`, `INVALID_REFRESH_TOKEN`, `EMAIL_ALREADY_REGISTERED`, `EMAIL_NOT_VERIFIED`, `INVALID_CODE`, `CODE_ATTEMPTS_EXCEEDED`, `RESEND_COOLDOWN`, `EMAIL_DELIVERY_FAILED`, `DEVICE_NOT_FOUND`, `TRACK_ID_CONFLICT`, `IDEMPOTENCY_KEY_REUSED`, `INGESTION_IN_PROGRESS`, `AUDIO_TOO_LARGE`, `AUDIO_TOO_LONG`, `INVALID_AUDIO`, `UNSUPPORTED_AUDIO_FORMAT`, `ARTWORK_TOO_LARGE`, `INVALID_ARTWORK`, `SANITIZATION_FAILED`, `STORAGE_UNAVAILABLE`, `LIBRARY_ITEM_NOT_FOUND`, `INVALID_LIBRARY_CURSOR`, `PLAYBACK_NOT_AVAILABLE`, `ARTWORK_NOT_FOUND`, `INVALID_SYNC_CURSOR`, `PLAYLIST_NOT_FOUND`, `PLAYLIST_ITEM_NOT_FOUND`, `PLAYLIST_ID_CONFLICT`, `PLAYLIST_ITEM_ID_CONFLICT`, `INVALID_PLAYLIST_ORDER`, `PLAYLIST_TOO_LARGE`, `PLAY_EVENT_ID_CONFLICT`, `INVALID_PLAYLIST_CURSOR`, `INVALID_HISTORY_CURSOR`, `STORAGE_QUOTA_EXCEEDED`, `INVALID_DISCOVER_CURSOR`, `DISCOVER_ITEM_NOT_FOUND`, `RATE_LIMITED`, `REQUEST_TOO_LARGE`.

## Ingest contract

- **Parts** (`multipart/form-data`): `manifest` (required), `audio` (required), `artwork` (optional). Part file names and part `Content-Type`s are ignored; the server never trusts them.
- **`manifest`**: one UTF-8 JSON object, at most 64 KiB, sent either as a plain form field or as a file part (`Content-Type: application/json` recommended, either works). Schema `TrackManifest` in [`openapi.json`](openapi.json); unknown fields are rejected (`422`):

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `track_id` | UUIDv7 string | yes | You generate it; the server never replaces it |
| `title` | string | yes | 1–300 chars after trim, no control characters |
| `artist_name`, `album_title`, `album_artist` | string \| null | no | ≤ 300 chars |
| `track_number` | int \| null | no | 1–9999 |
| `disc_number` | int \| null | no | 1–999 |
| `year` | int \| null | no | 1000–9999 |
| `genres` | string[] | no (default `[]`) | ≤ 20 entries, each 1–64 chars |
| `source_type` | `LOCAL_UPLOAD` \| `COMMUNITY_IMPORT` | yes | Request-only provenance; never returned |
| `source_provider` | string \| null | no | `[a-z0-9_]{1,32}`, only with `COMMUNITY_IMPORT`; never returned |

  There is **no** duration, MIME type, container, codec, size or hash field: the server derives all of them from the sanitized audio (sending one is `422`).
- **Success**: `201` `TrackResponse` (same shape on idempotent replay). Uploading **identical audio** again is not an error: the stored audio is reused and you still get a new Track and library entry. There is no "duplicate content" code; a reused `track_id` is `409 TRACK_ID_CONFLICT`.
- **Error codes** (`error.code` + status; also listed per operation in `openapi.json` under `x-error-codes`):

| Status | `error.code` | `retryable` | Meaning |
| --- | --- | --- | --- |
| 400 | `INVALID_REQUEST` | no | Malformed multipart, missing `audio`, unknown/duplicate part |
| 401 | `UNAUTHORIZED` | no | Refresh the token once |
| 403 | `STORAGE_QUOTA_EXCEEDED` | no | Over quota; nothing stored |
| 409 | `TRACK_ID_CONFLICT` | no | `track_id` already used by another Track |
| 409 | `IDEMPOTENCY_KEY_REUSED` | no | Key used for a different request |
| 409 | `INGESTION_IN_PROGRESS` | **yes** | Same key still processing: retry the same request |
| 413 | `AUDIO_TOO_LARGE` / `ARTWORK_TOO_LARGE` / `REQUEST_TOO_LARGE` | no | Over the audio (100 MiB) / artwork (10 MiB) / request limit |
| 415 | `UNSUPPORTED_AUDIO_FORMAT` | no | Valid media but not mp3, flac, m4a, ogg, opus or wav |
| 422 | `INVALID_REQUEST` | no | Invalid `manifest` (`details[].loc` starts with `manifest`) or `Idempotency-Key` |
| 422 | `INVALID_AUDIO` / `AUDIO_TOO_LONG` / `INVALID_ARTWORK` | no | Corrupt audio / over 1200 s / bad artwork |
| 429 | `RATE_LIMITED` | **yes** | Wait `Retry-After` seconds |
| 500 | `SANITIZATION_FAILED` / `INTERNAL_ERROR` | no | Server-side failure |
| 503 | `STORAGE_UNAVAILABLE` / `SERVICE_UNAVAILABLE` | **yes** | Dependency down: retry with the same `Idempotency-Key` |

  Analysis is queued server-side in the upload transaction and never fails the upload (there is no ML enqueue error); follow `analysis.upsert` in sync.

## Limits you should know

| What | Limit |
| --- | --- |
| JSON request body | 1 MiB |
| Audio upload / duration / artwork | 100 MiB / 1200 s / 10 MiB (multipart `POST /v1/tracks`) |
| Rate limits (per minute) | register 10, login 10 (per address and per email), refresh 60, verify/reset 20, resend/forgot 10 (per address; plus one code per email per 60 s), delete account 5, ingestion 30, Discover candidates 60, Discover add 60, signed URLs 120, history batches 60 |
| Pagination | `limit` default 50; library max 100, Discover max 200; cursors are opaque, never build them |

## Endpoints in the order you will use them

- **Ingest:** `POST /v1/tracks`, `multipart/form-data` with parts `manifest`, `audio`, optional `artwork` (each at most once, any other part is `400`); header `Idempotency-Key` (16–128 chars `[A-Za-z0-9._:-]`). Retrying with the same key replays the result (`Idempotent-Replayed: true`). Metadata is stripped server-side; you never receive storage keys. Details in [Ingest contract](#ingest-contract).
- **Library:** `GET /v1/library` (cursor pages), `GET|PATCH|DELETE /v1/library/{track_id}`. `PATCH` holds your personal state (favorite, Mood overrides, custom titles); `DELETE` is a tombstone. `analysis_status` is `pending|ready|failed`.
- **Playback / artwork:** `POST /v1/library/{track_id}/playback`, `GET /v1/library/{track_id}/artwork` return `{url, expires_at, expires_in}`. The URL is a short-lived GET-only bearer secret: do not log or persist it; request a new one when it expires. HTTP Range works against it.
- **Sync:** `GET /v1/sync` without `cursor` walks the bootstrap (library, playlists, recent history), the last page hands you the delta cursor; afterwards pass `next_cursor` back. Events are typed (`type` + `version` select the payload schema); deletes arrive as tombstone events. A bad cursor is `400 INVALID_SYNC_CURSOR` (start over without a cursor). Full protocol, event list and payloads: `SYNC_PROTOCOL.md` in the backend repository; the client parser is `OwlSonicSyncParser`.
- **Canonical analysis (Mood Map, Wave):** delivered **only through sync**: `analysis.upsert` follows each ready item in the bootstrap and arrives as a delta when analysis completes (`pending → ready`) or fails. `custom_valence`/`custom_arousal` on the library item are your personal override and never replace it. No ML worker, no polling endpoint.
- **Product state:** `/v1/playlists` (+ `/items`, `/items/order`), `POST /v1/history/events` (batches, idempotent by event ID), `GET /v1/history`.
- **Discover:** `GET /v1/discover/candidates` returns a non-personalized candidate pool with embeddings and shared valence/arousal — **rank locally** (Wave stays on the client). Tracks already in your **active** library are **excluded** (there is no `owned` flag); a Track you removed (tombstone) is a candidate again; `GET /v1/discover/{id}/artwork`; `POST /v1/discover/{id}/add` adds the existing Track to your library (no copy). There is no streaming for non-members.
- **Usage:** `GET /v1/me/usage` returns `{"storage": {used_bytes, limit_bytes, remaining_bytes, unlimited, over_limit}}`; a mutation that would exceed it fails with `403 STORAGE_QUOTA_EXCEEDED` (`retryable: false`).

## Never expected from the server

`source_type`, `source_provider`, storage keys, hashes, creator identities, ML worker details or analysis jobs. If you see one, report it as a bug.
