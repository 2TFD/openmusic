# OwlSonic release builds

## Production build

```sh
tool/build_release.sh appbundle      # Android (Play)
tool/build_release.sh apk            # Android (sideload)
tool/build_release.sh ipa            # iOS
tool/build_release.sh macos          # macOS
```

The script always passes `--dart-define-from-file=config/production.json`
(committed, public values only: `OWLSONIC_ENV=production`,
`OWLSONIC_API_BASE_URL=https://api.owlsonic.stream`). It does not depend on
the local `.env`. Optional operator-supplied values, read from the environment:

| Variable | Purpose |
|---|---|
| `SENTRY_DSN` | Opt-in crash reporting. Without it the crash-report switch says "unavailable". |
| `POSTHOG_PROJECT_TOKEN` | Public client-side project token. Optional; no analytics without it. |
| `POSTHOG_HOST` | HTTPS PostHog ingestion host. Required with the project token. |

Never pass backend credentials, database URLs or transactional-email API keys
to Flutter: everything compiled into the app is public.

A release build without a valid backend configuration stops on the startup
error screen (`OwlSonicApiConfig.ensureReleaseReady`): no
`OWLSONIC_API_BASE_URL`, `OWLSONIC_ENV=development`, plain `http://`, or a
production build pointing anywhere but `https://api.owlsonic.stream`. A build
that is intentionally local-only must pass `--dart-define=OWLSONIC_LOCAL_ONLY=true`.

The version shown in Settings comes from `pubspec.yaml` (`version:`); bump it
for every build uploaded to a store.

## Operator prerequisites

- **Android signing**: `android/key.properties` + keystore (gitignored). The
  script refuses to build Android release without it; release is never signed
  with the debug key.
- **iOS/macOS signing**: Apple Developer team, distribution certificates and
  provisioning profiles in Xcode. macOS outside the App Store also needs
  Developer ID signing and notarization (`xcrun notarytool`).
- **Website**: `https://owlsonic.stream/{privacy,terms,account-deletion,support}`
  are linked from Welcome, Account and Settings. Verify they are live and the
  legal text is approved before release.
- **iOS privacy manifest** (`ios/Runner/PrivacyInfo.xcprivacy`): the collected
  data types must match the published privacy policy and the App Store
  Connect privacy answers.

## Application identifiers

| Platform | Identifier | Note |
|---|---|---|
| Android | `com.ttfd.owlsonic` | Changed from `com.example.openmusic`. A different id is a different app: earlier test installs are not upgraded and keep their own data. |
| iOS | `com.ttfd.owlsonic` | Changed from `com.ttfd.openmusic`; same consequence for earlier TestFlight/dev installs. |
| macOS | `com.example.openmusic` | Unchanged so existing installs keep their sandbox container. `com.example.*` cannot ship on the Mac App Store; changing it moves app data to a new container (decide before the first public macOS build). |

## Network security

- Android release allows cleartext only to `127.0.0.1`/`localhost` (the
  just_audio playback proxy); debug builds allow cleartext for local backends
  (`android/app/src/debug/res/xml/network_security_config.xml`).
- iOS/macOS use `NSAllowsLocalNetworking` + `NSAllowsArbitraryLoadsForMedia`
  instead of `NSAllowsArbitraryLoads`. macOS release has
  `com.apple.security.network.server` for the loopback proxy.
- Verify cloud streaming on a physical iPhone and a signed macOS release
  build: these settings cannot be exercised by unit tests.

## FFmpeg (LGPL)

The app uses `ffmpeg_kit_flutter_new_audio` (FFmpeg 8.1.2, `--enable-version3`,
no `--enable-gpl`; the binaries report "LGPL version 3 or later"). The native
libraries are shipped as separate dynamic libraries/frameworks. Remaining
obligations are a legal/operator task, not done by changing the package:

- ship the LGPL/FFmpeg license texts and notices (Settings → Open-source
  licenses lists the Dart package licenses; native notices for Windows are in
  `licenses/ffmpeg_kit_flutter_new_audio/` next to the executable);
- provide (or link to) the exact corresponding source of FFmpeg, FFmpegKit and
  the bundled LGPL libraries (lame, twolame, soxr, shine, …) for the shipped
  version;
- legal review of LGPLv3 "installation information" requirements for App
  Store distribution.

## Beta telemetry declarations

Crash reports and anonymous usage analytics have separate Settings opt-ins; both
start off. PostHog is configured without session replay, lifecycle events,
rage-click capture, surveys, feature flag events or person profiles. No screen
observer is installed. Its bounded native queue is reset on opt-out and each
account session change. The app never calls `identify`. The only app event names
are `registration_completed`, `music_import_completed`,
`music_import_failed`, `first_playback_started`, `wave_started`,
`offline_download_completed` and `sync_failed`. Event properties are restricted
to platform, app version, build number, and the relevant source, mode or error
category. Sentry has no replay, screenshots, view hierarchy or profiling.

For App Store and Android Data safety answers, declare optional crash data
(Sentry), optional product interaction data (PostHog), and PostHog's rotating
app-scoped anonymous identifier. The native SDK may add its own device/session
properties; verify the provider payload before publication. The cloud account
collects email and uploaded user content for app functionality separately.
Verify the live policy and provider project settings before publication.
