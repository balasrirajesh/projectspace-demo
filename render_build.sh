#!/usr/bin/env bash
set -e

echo "=== Setting up Flutter SDK on Render ==="
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
else
  echo "Using existing Flutter cache..."
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "=== Flutter Version ==="
flutter --version

echo "=== Getting Dependencies ==="
flutter pub get

echo "=== Building Flutter Web ==="
flutter build web --release

echo "=== Build Finished Successfully! ==="
