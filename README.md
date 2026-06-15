# OpenMusic

A mobile app for listening to music from multiple sources in a single library. Built with Flutter and Clean Architecture.

---

## Features

- **Unified library** — tracks from different sources in one place
- **SoundCloud** — import tracks, playlists and likes by URL
- **Background playback** — controls in the notification shade
- **Wave** — endless queue based on ML track similarity (cosine distance between embeddings)
- **Search** across library and SoundCloud
- **Play history**
- **Playlists** — create and manage
- **Localization** — English and Russian

---

## Architecture

Layered Clean Architecture:

```
lib/
├── core/
│   ├── di/               # get_it DI + BlocScope
│   ├── app_router/       # go_router (ShellRoute + bottom nav)
│   ├── services/         # AudioPlayerService, WaveEngine, EmbeddingEngine
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

## Getting Started

**Requirements:** Flutter SDK ^3.10.4, connected device or emulator.

```bash
git clone https://github.com/2tfd/openmusic.git
cd openmusic

# Create .env from example
cp .env.example .env
# (optional) fill in TG_BOT_TOKEN and TG_CHAT_ID for error logging

flutter pub get
flutter run
```

After modifying Drift table definitions:
```bash
dart run build_runner build
```

---

## License

MIT — see [LICENSE](LICENSE)
