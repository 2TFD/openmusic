# OwlSonic MVP — Product Definition

> This document is the canonical product-level definition of the OwlSonic MVP. Other project documentation should not contradict it.

**OwlSonic is a cross-platform personal music library that combines local-first playback, cloud library sync, streaming, offline access, Mood Map, Wave recommendations, and ML-powered music analysis.**

> Your personal music library, everywhere — mapped by mood and powered by Wave.

Short variant: *A personal music library that works locally and across devices, with Mood Map and Wave for rediscovering your music.*

OwlSonic is first of all a **personal music library**. It is not positioned as a plain local/offline player, a downloader, an "AI music player", a generic recommendation app, or a Spotify-like streaming service.

Throughout this document:

- **Current implementation** — exists in the Flutter codebase today.
- **MVP target** — product decision is fixed, not (fully) implemented yet.
- **Planned backend integration** — target architecture; no backend exists in this repository.

---

## 1. Modes

### Local mode (no account)
OwlSonic works without a mandatory account, including on first launch. Without an account the user has: local library, local playback, playlists/local state, Mood Map, Wave, offline functionality, local imports.

### Account / cloud mode (MVP target)
After sign-in: cloud library, cross-device sync, audio upload, cloud streaming, offline download/cache, synced playlists, synced library state, synced ML analysis, synced Mood Map state and user overrides, future entitlements/subscriptions.

One user has one logical OwlSonic library across devices. The auth provider is not fixed yet; Google/Apple sign-in is not assumed to be required.

## 2. Platforms

One Flutter codebase — a **cross-platform Flutter application** for Android, iOS, Windows, macOS and Linux. Web is architecturally possible but not part of the MVP. Desktop is not a separate product.

## 3. Playback sources

The player abstracts the track source from the UX. Source types: local original, offline cached copy, cloud stream, imported asset. The user presses Play; the app picks an available playable source. Cloud streaming is not a separate player mode.

Target source selection (MVP target):

```text
offline cached copy exists → play cached
else local original exists → play local
else cloud asset exists    → stream
```

Offline is a first-class capability; cloud mode does not mean streaming-only.

## 4. Cloud audio storage (MVP target)

OwlSonic Cloud may store a user's audio assets, **including assets that came from experimental Community/OSS import flows**. There is one shared object storage; physical storage is not split by origin.

> Physical storage can be shared, provenance remains explicit.

Community/OSS imported audio may be uploaded into the same cloud storage and synchronized like any other library asset. Provenance is stored so policies can change later without redesigning the storage model.

### Provenance (target backend/domain model — not implemented in Flutter)

- `source_type`: `LOCAL_UPLOAD`, `COMMUNITY_IMPORT`, `CLOUD_IMPORT`, `LICENSED_IMPORT`
- `source_provider`: `local`, `youtube`, `soundcloud`, `spotify_match`, other future providers
- optional: `source_external_id`, `sha256`, mime type, size, duration, `created_at`

## 5. Upload and streaming flows (target architecture)

Upload:

```text
client computes SHA-256
→ backend checks/deduplicates
→ backend provides presigned upload
→ client uploads directly to object storage
→ backend confirms asset
→ ML analysis job
→ library sync
```

Streaming:

```text
Flutter client
→ OwlSonic backend authorization
→ short-lived signed URL
→ object storage
→ Flutter playback
```

The main backend is not a permanent proxy for audio bytes and does not accept large uploads through the application server without need. Streaming should support HTTP Range where applicable. None of the signed-URL / presigned-upload flow is implemented yet.

## 6. Deduplication

- **User asset deduplication** — content identity is `SHA-256(audio bytes)`. Re-uploading the same file must not create extra physical copies without reason.
- **ML result cache** — analysis is reusable by `audio_sha256 + representation/model version + preprocessing version`.
- Title/artist/ISRC are never the primary identity of audio bytes.

## 7. Sync (MVP target)

Cursor-based delta sync (e.g. `GET /v1/sync?cursor=...`), not realtime WebSocket sync. Scope: tracks, metadata, playlists, playlist items, library membership, play/favorite state, analysis results, Mood Map user overrides, and deletions as tombstones / soft deletes so they propagate between devices.

Accounts: authenticated sessions, multiple devices, device identity; revoke/logout later.

## 8. Mood Map

A core differentiator — not a visualizer. A visual 2D emotional map of the user's library: valence axis, arousal axis, tracks/artwork placed spatially. ML provides the default position; the user can override a track's position; personal state should eventually sync between devices.

Current implementation: Mood Map repository and screen exist locally. Cross-device sync of overrides is MVP target.

## 9. Wave

A core differentiator. Wave rediscovers familiar music from the user's own library — *radio for the music you already own / have in your OwlSonic library*. It may use mood, audio similarity, track similarity, artist context, embeddings and library state. It is not a global streaming recommendation system.

Current implementation: local Wave engines (track, artist, mood) under `lib/core/services/recommendation/`.

## 10. ML

OwlSonic uses centralized ML worker / backend analysis. Current production direction:

- CLAP audio embeddings
- CLAP zero-shot emotion
- E5 text/lyrics embeddings
- versioned representations
- Mood Map and Wave built on top

MERT / Music2Emo are **not** the production direction; they are at most historical/legacy experiments. (The client still contains compatibility code that mentions Music2Emo for schema-v2 backend responses — see Technical debt.)

**ML worker** — stateless inference service: audio embeddings, emotion from embeddings, text embeddings. It does *not* own accounts, billing, library, quotas, persistent user state, cloud sync, object storage, or playlists. The main backend orchestrates worker calls.

**Main backend (planned)** — accounts/auth, devices, library, track metadata, uploads, object storage authorization, cloud streaming authorization, sync, playlists, ML jobs, analysis cache, usage/quotas, future entitlements/billing.

Rules for the client: it never receives the ML worker's service secret, and in the target architecture it does not depend on concrete HF Space URLs. *Current implementation:* the client calls an ML API at a configurable `ML_BASE_URL` (default is a hosted Space); this is to be replaced by main-backend orchestration.

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
| Playlists, play history | Current |
| SoundCloud / YouTube / Spotify import (experimental) | Current (no flavor split) |
| ML analysis via remote API, embeddings | Current |
| Wave, Mood Map (local) | Current |
| Lyrics resolution | Current |
| Offline file storage of imported tracks | Current |
| Accounts, devices | MVP target |
| Cloud library, upload, cloud streaming, signed URLs | MVP target |
| Cross-device sync, tombstones | MVP target |
| Provenance model, SHA-256 dedup | MVP target (backend) |
| Community/Store flavors | MVP target |
| Source auto-selection (cached → local → cloud) | MVP target |
| Main backend | Planned; not in this repository |

## 15. Terminology and technical debt

The product name is **OwlSonic**. Legacy `openmusic` identifiers survive in a few technical places (e.g. `OpenmusicAudioHandler`, historical notes); they are technical debt and are intentionally not renamed for cosmetics. Do not change package IDs, Android `applicationId` or iOS bundle ID for documentation reasons.
