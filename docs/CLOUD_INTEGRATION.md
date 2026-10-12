# OwlSonic cloud integration — client

Source of truth for the contract: `docs/openapi.json` (summary: `docs/FLUTTER_API.md`). The client never contacts the ML worker;
all requests go through `OwlSonicApiClient` to `OWLSONIC_API_BASE_URL`.

```
--dart-define=OWLSONIC_ENV=development|staging|production   # default development
--dart-define=OWLSONIC_API_BASE_URL=https://<host>           # .env.example: https://api.owlsonic.stream
```

Without `OWLSONIC_API_BASE_URL` cloud features report "not configured"
(`OwlSonicApiConfig.isConfigured`). Cloud is active only when configured **and**
signed in (`AuthSession`). Tokens are kept in secure storage; the
`installation_id` is generated once per installation.

## Data flow

```
backend ──GET /v1/sync──▶ CloudSyncCoordinator ─▶ SyncEngine ─▶ CloudLocalStore ─▶ Drift DB ─▶ Blocs/UI
backend ◀─REST mutation── cloud-aware repositories ─(response)─▶ CloudLocalStore
```

The UI reads only the local database. Cloud tracks live in `track_table`
(`source_type = owlsonic`, id = backend UUID) with cloud-only state in:

| Table | Purpose |
| --- | --- |
| `cloud_library_item_table` | canonical metadata, `custom_*`, favorite, custom mood, play aggregates, `analysis_status` |
| `cloud_analysis_table` | canonical analysis metadata + `analysis_version` (supersede rule) |
| `cloud_playlist_table` / `cloud_playlist_item_table` | cloud playlist marker and authoritative item list (item ids) |
| `cloud_upload_table` | durable upload records: UUIDv7 track id + Idempotency-Key per logical upload |

Canonical embedding / valence / arousal are projected into the existing
embedding and emotion tables (pipeline `owlsonic-cloud-v1`), so Mood Map and
Wave rank unchanged code paths. `MusicAnalysisModelRegistry` prefers synced
cloud analysis; legacy local descriptors apply only while none exists.

## Sync

* Parser: explicit `(type, version)` switch (`OwlSonicSyncParser`); unknown or
  malformed events reject the whole page before any write.
* Pages apply in one transaction; the cursor is written only afterwards.
* Bootstrap starting from page 1 sweeps cloud rows missing from the snapshot.
* `INVALID_SYNC_CURSOR` → cursor cleared, bootstrap again.
* Cursor key and data are scoped to the account (`owlsonic.cloud_account_id`).
  Sign-out or a different account purges cloud rows — never files.
* Triggers: sign-in, deferred startup, app resume, every 3 min in foreground,
  after import / mutations. One coordinator, coalesced runs.

## Playback and storage modes

* `CloudPlaybackSource` order: offline copy / local file → stream-cache file →
  signed URL from `POST /v1/library/{id}/playback` (`SignedUrlCache`, never
  persisted or logged). Streaming goes through just_audio's `StreamAudioSource`
  proxy (`CloudStreamAudioSource`); an expired URL is refetched.
* `DeviceStorageMode` (per installation, never synced; default `stream`,
  mobile never asks):
  * **stream** — `CloudAudioCache`: a played track is downloaded once in the
    background into the platform cache dir; 1 GB LRU, skipped below 500 MB free.
  * **offline** — `CloudOfflineLibrary`: after each sync every cloud track is
    downloaded with title/artist/album/cover written into the file, keeping
    500 MB free; resumes on the next sync. Status: done / low space / paused
    after repeated failures.
* Sign-out or account change (`afterPurge`) deletes offline copies and clears
  the stream cache.

## Uploads and auto-sync

* `CloudImportService` uploads imports made while signed in: UUIDv7 track id +
  persistent `Idempotency-Key` per logical upload (`cloud_upload_table`);
  `source_type` is `LOCAL_UPLOAD` for user files, `COMMUNITY_IMPORT` (with
  `source_provider`) for link imports. Pending uploads resume after each sync.
* `LocalLibraryMigration` — explicit "Upload local library to OwlSonic" for
  tracks imported before signing in; success is recorded per item.
* `AutoSyncService` (Settings → "Sync music automatically", default on,
  optional "Only on Wi-Fi"): runs after each sync, on setting change and when
  the connection becomes allowed. Uploads everything on the device, then
  promotes device playlists to cloud playlists (`CloudPlaylistSync`) with the
  songs that are in the cloud. Songs that are not there stay in the device
  playlist flagged "not synced" (`Playlist.unsyncedTrackIds`) and join the
  server playlist after upload or "Sync this song" (works with auto-sync off).
  Files the server rejects for good are skipped.
* Play events are queued (`PlayEventQueue`) and flushed as
  `POST /v1/history/events` batches after each sync.
* Migrated or uploaded tracks keep their local file; signing out purges the
  cloud rows, never the user's own files.

## Not covered / follow-ups

* No real-backend smoke test in the repo (no test account). Sync, upload,
  offline and streaming are covered by unit tests with fakes / a fake HTTP
  server.
* No per-track offline indicator or selective download.
* There is no separate audio-upload consent: uploads happen only for a signed-in
  account, and the Account form states that next to its button. Retention of
  uploaded audio is not specified in `docs/openapi.json`; the client makes no
  claim about it. Deleting an account keeps shared content, ownerless.
* No Discover UI exists; `DiscoverService` (candidates, add, artwork) is ready.
