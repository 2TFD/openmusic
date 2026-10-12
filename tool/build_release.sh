#!/usr/bin/env bash
# Reproducible OwlSonic release build.
#
#   tool/build_release.sh <apk|appbundle|ipa|ios|macos|windows|linux> [flutter build args...]
#
# Public configuration comes from config/production.json (committed). Values
# the operator supplies (never committed, never secret backend credentials):
#   SENTRY_DSN          crash reporting (opt-in in the app); optional
#   POSTHOG_PROJECT_TOKEN  public PostHog project token; optional
#   POSTHOG_HOST           HTTPS ingestion host; optional
# Signing: android/key.properties (Android), Xcode team/profiles (iOS/macOS).
set -euo pipefail

target="${1:?usage: tool/build_release.sh <apk|appbundle|ipa|ios|macos|windows|linux> [args...]}"
shift
cd "$(dirname "$0")/.."

defines=(--dart-define-from-file=config/production.json)
[[ -n "${SENTRY_DSN:-}" ]] && defines+=("--dart-define=SENTRY_DSN=${SENTRY_DSN}")
[[ -n "${POSTHOG_PROJECT_TOKEN:-}" ]] && defines+=("--dart-define=POSTHOG_PROJECT_TOKEN=${POSTHOG_PROJECT_TOKEN}")
[[ -n "${POSTHOG_HOST:-}" ]] && defines+=("--dart-define=POSTHOG_HOST=${POSTHOG_HOST}")

if [[ "$target" == apk || "$target" == appbundle ]] && [[ ! -f android/key.properties ]]; then
  echo "android/key.properties is missing: release builds are never signed with the debug key." >&2
  exit 1
fi

flutter build "$target" --release "${defines[@]}" "$@"
