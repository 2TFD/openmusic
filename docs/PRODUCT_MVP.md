# OwlSonic MVP — Product Definition

> This document is the canonical product-level definition of the OwlSonic MVP. Other project documentation should not contradict it.

**OwlSonic is a cross-platform personal music library that combines local-first playback, cloud library sync, streaming, offline access, Mood Map, Wave recommendations, and ML-powered music analysis.**

> Your personal music library, everywhere — mapped by mood and powered by Wave.

Short variant: *A personal music library that works locally and across devices, with Mood Map and Wave for rediscovering your music.*

OwlSonic is first of all a **personal music library**. It is not positioned as a plain local/offline player, a downloader, an "AI music player", a generic recommendation app, or a Spotify-like streaming service.

Throughout this document:

- **Current implementation** — exists in the Flutter codebase today.
- **MVP target** — product decision is fixed, not (fully) implemented yet.
- **Backend integration** — the OwlSonic backend lives in a separate repository; the client talks to it through `docs/openapi.json`.

---

## 1. Modes

### Local mode (no account)
OwlSonic works without a mandatory account, including on first launch. Without an account the user has: local library, local playback, playlists/local state, Mood Map, Wave, offline functionality, local imports.

### Account / cloud mode
After sign-in: cloud library, cross-device sync, audio upload, cloud streaming, offline download/cache, synced playlists, synced library state, synced ML analysis, synced Mood Map state and user overrides, future entitlements/subscriptions.

One user has one logical OwlSonic library across devices.

*Current implementation:* email + password accounts with email verification and password reset, device registration by installation id, cloud library, sync, upload, signed-URL streaming, offline storage mode, synced playlists/history/analysis and Mood overrides. Google/Apple sign-in is not implemented and not assumed to be required. Future entitlements are not implemented.

## 2. Platforms

One Flutter codebase — a **cross-platform Flutter application** for Android, iOS, Windows, macOS and Linux. Web is architecturally possible but not part of the MVP. Desktop is not a separate product.

## 3. Playback sources

The player abstracts the track source from the UX. Source types: local original, offline cached copy, cloud stream, imported asset. The user presses Play; the app picks an available playable source. Cloud streaming is not a separate player mode.

Source selection (current implementation, `CloudPlaybackSource`):

```text
offline copy / local original exists → play file
else stream-cache copy exists        → play cached
else cloud asset                     → stream via short-lived signed URL
```

Per device the user picks a storage mode: **stream** (played tracks are cached, 1 GB LRU, default) or **offline** (the whole cloud library is downloaded with embedded tags).

Offline is a first-class capability; cloud mode does not mean streaming-only.

## 4. Cloud audio storage

OwlSonic Cloud may store a user's audio assets, **including assets that came from experimental Community/OSS import flows**. There is one shared object storage; physical storage is not split by origin.

> Physical storage can be shared, provenance remains explicit.

Community/OSS imported audio may be uploaded into the same cloud storage and synchronized like any other library asset. Provenance is stored so policies can change later without redesigning the storage model.

### Provenance

Current implementation: the client sends `source_type` (`LOCAL_UPLOAD` for the user's files, `COMMUNITY_IMPORT` for link imports) and `source_provider` in the upload manifest; the server never returns them. Full target model:

- `source_type`: `LOCAL_UPLOAD`, `COMMUNITY_IMPORT`, `CLOUD_IMPORT`, `LICENSED_IMPORT`
- `source_provider`: `local`, `youtube`, `soundcloud`, `spotify_match`, other future providers
- optional: `source_external_id`, `sha256`, mime type, size, duration, `created_at`

## 5. Upload and streaming flows

Upload (current implementation):

```text
client generates UUIDv7 track id + Idempotency-Key (persisted in cloud_upload_table)
→ multipart POST /v1/tracks (manifest, audio, optional artwork)
→ backend sanitizes, deduplicates stored audio, queues ML analysis
→ library sync delivers the track and later analysis.upsert
```

A presigned direct-to-storage upload is a possible later optimization; it is not what the API does today.

Streaming:

```text
Flutter client
→ OwlSonic backend authorization
→ short-lived signed URL
→ object storage
→ Flutter playback
```

Playback URLs come from `POST /v1/library/{track_id}/playback`; they are short-lived, support HTTP Range, and are never logged or persisted by the client (`SignedUrlCache`, `CloudStreamAudioSource`).

## 6. Deduplication

- **User asset deduplication** — content identity is `SHA-256(audio bytes)`. Re-uploading the same file must not create extra physical copies without reason (server-side; the API returns a new Track that reuses stored audio). The client also computes SHA-256 content identity locally (`Sha256TrackContentIdentityService`) for local duplicate detection.
- **ML result cache** — analysis is reusable by `audio_sha256 + representation/model version + preprocessing version`.
- Title/artist/ISRC are never the primary identity of audio bytes.

## 7. Sync

Implemented (`CloudSyncCoordinator`, `SyncEngine`). Cursor-based delta sync (e.g. `GET /v1/sync?cursor=...`), not realtime WebSocket sync. Scope: tracks, metadata, playlists, playlist items, library membership, play/favorite state, analysis results, Mood Map user overrides, and deletions as tombstones / soft deletes so they propagate between devices.

Triggers: sign-in, deferred startup, app resume, every 3 minutes in foreground, after imports and mutations. Accounts: authenticated sessions with rotating refresh tokens, multiple devices, device listing/revocation, logout, account deletion.

## 8. Mood Map

A core differentiator — not a visualizer. A visual 2D emotional map of the user's library: valence axis, arousal axis, tracks/artwork placed spatially. ML provides the default position; the user can override a track's position; personal state should eventually sync between devices.

Current implementation: Mood Map screen/cubit and repository; personal overrides are stored locally and, for cloud tracks, synced as `custom_valence`/`custom_arousal` on the library item.

## 9. Wave

A core differentiator. Wave rediscovers familiar music from the user's own library — *radio for the music you already own / have in your OwlSonic library*. It may use mood, audio similarity, track similarity, artist context, embeddings and library state. It is not a global streaming recommendation system.

Current implementation: `WaveOrchestrator` with track, artist and mood engines under `lib/core/services/recommendation/`, ranking locally on embeddings and emotion rows (local or synced).

## 10. ML

OwlSonic uses centralized ML worker / backend analysis. Current production direction:

- CLAP audio embeddings
- CLAP zero-shot emotion
- E5 text/lyrics embeddings
- versioned representations
- Mood Map and Wave built on top

MERT / Music2Emo are **not** the production direction; they are at most historical/legacy experiments.

**ML worker** — stateless inference service: audio embeddings, emotion from embeddings, text embeddings. It does *not* own accounts, billing, library, quotas, persistent user state, cloud sync, object storage, or playlists. The main backend orchestrates worker calls.

**Main backend** (separate repository) — accounts/auth, devices, library, track metadata, uploads, object storage authorization, cloud streaming authorization, sync, playlists, ML jobs, analysis cache, usage/quotas, future entitlements/billing.

Rules for the client: it never receives the ML worker's service secret and never calls the ML worker. *Current implementation:* canonical analysis arrives only through sync (`analysis.upsert`) and is projected into the local embedding/emotion tables (preprocessing version `owlsonic-cloud-v1`). `MusicAnalysisModelRegistry` prefers synced cloud analysis; analysis rows cached by pre-cloud app versions are used only until cloud analysis exists. Tracks that are not in the cloud get no new analysis.

## 11. Build flavors (MVP target)

One codebase + build flavors + feature registration — not two forks.

- **OwlSonic Community / OSS** — may include *experimental community integrations* (experimental import providers): YouTube, SoundCloud, Spotify metadata/matching, Spotify liked tracks sync, other experimental sources. Open source does not by itself make third-party integrations legally permissible.
- **OwlSonic Store** — stays compatible with App Store / Google Play requirements. Experimental provider implementations that are not allowed there are not registered in the Store build.

Current implementation: no flavor separation yet; SoundCloud, YouTube and Spotify import are available in all builds.

## 12. Monetization

The app stays free and open source. Future monetization concerns hosted/cloud services — cloud storage, hosted ML analysis, cross-device cloud capabilities — i.e. *future cloud/analysis entitlements*. Prices and quotas are not decided.

## 13. MVP scope

**IN:** local library; local playback; optional account (local mode works without it); cloud account mode; audio upload; cloud library; cross-device sync; cloud streaming; offline caching/download; playlists; basic history/state; ML analysis; Mood Map; Wave; Android, iOS, Windows, macOS, Linux (architecture); Community/OSS flavor; Store flavor; experimental Community imports; shared cloud storage with provenance.

**NOT REQUIRED FOR MVP:** social network; shared/public libraries; collaborative playlists; family accounts; cross-user recommendations; HLS; Chromecast; CarPlay; Android Auto; advanced EQ; crossfade; full Web player; social discovery; public profiles.

Out-of-MVP items are scope planning — existing working code is not removed because of it.

## 14. Implemented vs target

| Capability | Status |
|---|---|
| Local library, local playback, background playback | Current |
| Playlists, play history, artists, search | Current |
| SoundCloud / YouTube / Spotify import (experimental) | Current (no flavor split) |
| Wave, Mood Map with personal overrides | Current |
| Lyrics resolution (embedded, sidecar LRC, LRCLIB) | Current |
| Offline file storage of imported tracks | Current |
| Accounts (email + password, verification, reset), devices | Current |
| Cloud library, upload, signed-URL streaming | Current |
| Cross-device delta sync, tombstones | Current |
| Stream / offline storage modes, auto-sync | Current |
| ML analysis via backend, delivered through sync | Current |
| Provenance on upload (`LOCAL_UPLOAD` / `COMMUNITY_IMPORT`) | Current (client sends; server stores) |
| Discover (candidate pool, local ranking) | Service only, no UI |
| Statistics screen | BLoC only, no UI |
| Community/Store flavors | MVP target |
| Entitlements / billing | Future |
| Main backend | Separate repository |

## 15. Terminology and technical debt

The product name is **OwlSonic**. Package, Android `applicationId` and iOS bundle ID are `com.ttfd.owlsonic`; the Dart package is `owlsonic`. Legacy `openmusic` identifiers no longer appear in `lib/`; the Git remote is still named `openmusic`, and the iOS test target uses `com.example.owlsonic.RunnerTests`.
