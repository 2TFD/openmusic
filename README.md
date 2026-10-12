# OwlSonic

**Your personal music library, everywhere — mapped by mood and powered by Wave.**

OwlSonic is a cross-platform personal music library that combines local-first playback, cloud library sync, streaming, offline access, Mood Map, Wave recommendations, and ML-powered music analysis.

> Canonical product definition: [docs/PRODUCT_MVP.md](docs/PRODUCT_MVP.md). Client-side cloud details: [docs/CLOUD_INTEGRATION.md](docs/CLOUD_INTEGRATION.md). Backend contract: [docs/FLUTTER_API.md](docs/FLUTTER_API.md) / [docs/openapi.json](docs/openapi.json).

---

## What is OwlSonic?

A personal music library that works locally and across devices, with Mood Map and Wave for rediscovering your music. It is a single Flutter codebase (Android, iOS, Windows, macOS, Linux). No account is required for local use.

## Core experiences

- **Local-first library** — works without an account.
- **Cloud library & sync** — optional OwlSonic account (email + password with email verification): audio upload, cursor-based delta sync of library, playlists, history and analysis across devices.
- **Mood Map** — a 2D valence/arousal map of your library; analysis sets the default position, you can override it.
- **Wave** — radio for the music already in your library (track, artist and mood engines).
- **Offline + streaming** — Play picks the available source: local/offline file → cached copy → cloud stream (short-lived signed URL). Per device you choose *stream* (played tracks cached, 1 GB limit) or *offline* (whole cloud library downloaded).

## Platforms

Flutter codebase targeting Android, iOS, Windows, macOS and Linux, with a separate desktop shell layout. Web is not part of the MVP.

## Current implementation status

Implemented:

- Local library, background playback (audio_service; media_kit backend on Windows/Linux), playlists, play history, search, artists
- Experimental import providers: SoundCloud, YouTube, Spotify (available in all builds)
- Wave (track / artist / mood engines), Mood Map with personal overrides, lyrics (embedded tags, sidecar `.lrc`, LRCLIB)
- OwlSonic cloud: accounts, uploads, sync, signed-URL streaming, stream/offline storage modes, auto-sync (default on, optional Wi-Fi only), upload of the pre-existing local library
- Canonical ML analysis (embeddings, valence/arousal) delivered by the backend through sync
- Opt-in crash reports (Sentry) and analytics (PostHog), English and Russian localization

Not implemented yet: Community/Store build flavors, Discover UI (`DiscoverService` exists without a screen), Statistics screen (BLoC exists). No backend lives in this repository.

## Architecture overview

- **Backend** (separate repository): auth, devices, library, uploads, storage and streaming authorization, sync, ML orchestration, quotas. Audio bytes move via short-lived signed URLs.
- **Client ↔ ML:** the client never talks to the ML worker. Analysis (CLAP audio embeddings, CLAP zero-shot emotion, E5 text embeddings, versioned representations) arrives as `analysis.upsert` sync events and is projected into the local embedding/emotion tables that Mood Map and Wave read.

---

## Code architecture

Layered Clean Architecture:

```
lib/
├── main.dart
├── core/
│   ├── app_router/       # go_router (ShellRoute) + custom transitions
│   ├── bootstrap/        # app initialization, deferred startup, lifecycle
│   ├── config/           # OwlSonicApiConfig (dart-defines)
│   ├── di/               # get_it registration (di.dart) + BlocScope
│   ├── errors/           # sealed Failure hierarchy
│   ├── layout/           # breakpoints, adaptive presentation
│   ├── network/owlsonic/ # API client, auth session, token store, installation id
│   ├── services/         # audio player, cloud, download, lyrics, recommendation (Wave), spotify, …
│   ├── telemetry/        # Sentry crash reporter, PostHog tracker, consent
│   ├── themes/           # AppTheme
│   └── utils/            # AppLogger, locale keys, …
└── layers/
    ├── data/             # Drift (SQLite), data sources, models, mappers, repositories
    ├── domain/           # entities, repository interfaces, domain services, use cases
    └── presentation/     # features/<feature>/{bloc,ui}, shared blocs/widgets
```

**Database** — Drift (SQLite), schema version 20.

**State management** — flutter_bloc (BLoCs and Cubits).

---

## Tech Stack

| Layer | Library |
|---|---|
| State | flutter_bloc ^9.1.1 |
| Navigation | go_router ^17.1.0 |
| Database | drift ^2.33.0 |
| Audio | just_audio + audio_service (just_audio_media_kit on Windows/Linux) |
| HTTP | dio ^5.9.2 |
| DI | get_it ^9.2.1 |
| Background downloads | background_downloader |
| YouTube | youtube_explode_dart |
| Spotify auth | flutter_web_auth_2 (PKCE) |
| Media processing | ffmpeg_kit_flutter_new_audio (LGPL-3.0 audio build of FFmpegKit; no GPL codecs) |
| Secure storage | flutter_secure_storage |
| Telemetry | sentry_flutter, posthog_flutter |
| Localization | easy_localization |
| Images | cached_network_image |

---

## Development

**Requirements:** Flutter SDK with Dart ^3.10.4, connected device or emulator.

```bash
git clone https://github.com/2TFD/openmusic.git
cd openmusic

cp .env.example .env
flutter pub get
flutter run --dart-define-from-file=.env
```

Build-time configuration (`--dart-define`):

| Define | Purpose |
|---|---|
| `OWLSONIC_API_BASE_URL` | Backend URL (public config, in `.env.example`). Without it cloud features report "not configured". |
| `OWLSONIC_ENV` | `development` (default) / `staging` / `production` |
| `SENTRY_DSN`, `SENTRY_ENVIRONMENT` | Crash reporting; disabled without a DSN |

The VS Code launch configurations already pass `.env`.

Crash reporting and analytics are opt-in: users enable anonymous reports in Settings. Performance tracing, session replay, request capture, and default PII collection remain disabled.

```bash
flutter run \
  --dart-define=SENTRY_DSN=https://public-key@o0.ingest.sentry.io/project-id \
  --dart-define=SENTRY_ENVIRONMENT=development
```

### Experimental import providers (YouTube, Spotify)

YouTube video/playlist import and Spotify track/album/playlist import are
available in debug, profile, and release builds without a feature flag or
build-time configuration.

Spotify needs no developer app or sign-in: metadata is read from the public
embed page (`open.spotify.com/embed/...`) and audio comes from a matched
YouTube video. Playlists are limited to their first 100 tracks, and private
playlists are not visible.

### Common commands

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs   # after Drift table changes
dart run flutter_launcher_icons                            # after icon changes
```

---

## License / third-party notes

MIT — see [LICENSE](LICENSE). Experimental community integrations rely on third-party services; being open source does not by itself make them permissible under those services' terms.
