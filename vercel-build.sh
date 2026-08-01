#!/usr/bin/env bash
# Builds the Flutter web app on Vercel.
#
# Vercel's build image has no Flutter SDK, so fetch a pinned stable release
# before building. The version is pinned rather than tracking `stable` so a
# deploy cannot start failing because upstream moved.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.6}"
FLUTTER_DIR=".vercel-flutter"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Fetching Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$PWD/$FLUTTER_DIR/bin:$PATH"

# The build container runs as a different user than the one that cloned the
# SDK in a warm cache; without this git refuses to read the repo.
git config --global --add safe.directory "$PWD/$FLUTTER_DIR" || true

flutter --version
flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release

echo "Build complete:"
ls -1 build/web | head -20
