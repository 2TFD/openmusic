# OwlSonic

**Your personal music library, everywhere — mapped by mood and powered by Wave.**

OwlSonic is a cross-platform personal music library that combines local-first playback, cloud library sync, streaming, offline access, Mood Map, Wave recommendations, and ML-powered music analysis.

> Canonical product definition: [docs/PRODUCT_MVP.md](docs/PRODUCT_MVP.md). This README separates what exists today from the MVP target.

---

## What is OwlSonic?

A personal music library that works locally and across devices, with Mood Map and Wave for rediscovering your music. It is a single Flutter codebase (Android, iOS, Windows, macOS, Linux). No account is required for local use.

## Core experiences

- **Local-first library** — works without an account.
- **Cloud library & sync** — *MVP target*: one logical library across devices, audio upload, synced playlists and state.
- **Mood Map** — a 2D valence/arousal map of your library; ML sets the default position, you can override it.
- **Wave** — radio for the music already in your library, based on mood, audio/track similarity and artist context.
- **Offline + streaming** — *MVP target*: Play picks the available source (offline copy → local original → cloud stream).

## Platforms

Flutter codebase targeting Android, iOS, Windows, macOS and Linux. Web is not part of the MVP.

## Build flavors

*MVP target* (not implemented yet — one codebase, build flavors and feature registration):

- **Community / OSS** — includes experimental community integrations (import providers such as YouTube, SoundCloud, Spotify metadata/matching).
- **Store** — compatible with App Store / Google Play requirements; disallowed experimental providers are not registered.

## Current implementation status

Implemented today:

- Unified local library, background playback, playlists, play history, search
- Experimental import providers: SoundCloud, YouTube, Spotify (available in all builds for now)
- Wave (local engines), Mood Map, lyrics
- ML analysis through a remote ML API (configurable via `ML_BASE_URL`)
- English and Russian localization

Not implemented yet: accounts, cloud library/upload/streaming, cross-device sync, flavors, provenance metadata. No backend lives in this repository.

## MVP target architecture

Planned backend integration (target, not implemented): the main backend handles auth, devices, library, uploads, storage and streaming authorization, sync, ML jobs and quotas. Audio goes directly between client and object storage via presigned/short-lived signed URLs; sync is cursor-based delta sync. Cloud audio from all origins, including Community imports, shares one storage with explicit provenance. Details: [docs/PRODUCT_MVP.md](docs/PRODUCT_MVP.md).

## ML architecture

Centralized analysis: CLAP audio embeddings, CLAP zero-shot emotion, E5 text/lyrics embeddings, versioned representations; they power Mood Map and Wave. The ML worker is a stateless inference service; the client should eventually talk only to the main backend.

---

## Code architecture

Layered Clean Architecture:

```
lib/
├── core/
│   ├── di/               # get_it DI + BlocScope
│   ├── app_router/       # go_router (ShellRoute + bottom nav)
│   ├── services/         # audio player, recommendation (Wave), music analysis, lyrics
│   ├── themes/           # AppTheme
│   └── utils/
└── layers/
    ├── data/             # Drift (SQLite), data sources, DTOs, repositories
    ├── domain/           # Entities, repository interfaces, use cases
    └── presentation/     # BLoC, screens, widgets
```

**Database** — Drift (SQLite)

**State management** — flutter_bloc

---

## Tech Stack

| Layer | Library |
|---|---|
| State | flutter_bloc ^9.1.1 |
| Navigation | go_router ^17.1.0 |
| Database | drift ^2.33.0 |
| Audio | just_audio + just_audio_background |
| HTTP | dio ^5.9.2 |
| DI | get_it ^9.2.1 |
| YouTube | youtube_explode_dart |
| Media processing | ffmpeg_kit_flutter_new |
| Localization | easy_localization |
| Images | cached_network_image |

---

## Development

**Requirements:** Flutter SDK ^3.10.4, connected device or emulator.

```bash
git clone https://github.com/2tfd/owlsonic.git
cd owlsonic

# Create .env from example
cp .env.example .env
# (optional) fill in TG_BOT_TOKEN and TG_CHAT_ID for error logging

flutter pub get
flutter run
```

Crash reporting is opt-in and disabled unless a Sentry DSN is supplied at
build time. The DSN is not stored in the repository:

```bash
flutter run \
  --dart-define=SENTRY_DSN=https://public-key@o0.ingest.sentry.io/project-id \
  --dart-define=SENTRY_ENVIRONMENT=development
```

Users can enable anonymous error reports in Settings. Performance tracing,
session replay, request capture, and default PII collection remain disabled.

### Experimental import providers (YouTube, Spotify)

YouTube video/playlist import and Spotify track/album/owned-playlist import
are available in debug, profile, and release builds without a feature flag.
For Spotify, register `owlsonic-spotify-login://callback` in the Spotify
dashboard and supply the client ID when running or building the app:

```bash
flutter run \
  --dart-define=SPOTIFY_CLIENT_ID=your-client-id
```

For an Android release, use
`flutter build apk --dart-define=SPOTIFY_CLIENT_ID=your-client-id`.
YouTube import requires no build-time configuration. Previously failed downloads
can be retried from the app after updating.

Spotify uses Authorization Code with PKCE; no client secret is embedded in the
app. Tokens are kept in platform secure storage. Spotify Development Mode
requires an allowlisted account, and playlist contents may only be available
for playlists owned by or collaborative with that account.

After modifying Drift table definitions:
```bash
dart run build_runner build
```

---

## License / third-party notes

MIT — see [LICENSE](LICENSE). Experimental community integrations rely on third-party services; being open source does not by itself make them permissible under those services' terms.
