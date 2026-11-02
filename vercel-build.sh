#!/bin/bash
set -e

echo "=== Setting up Flutter SDK on Vercel ==="
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

export PATH="$PATH:$HOME/flutter/bin"
flutter --version

echo "=== Fetching dependencies ==="
flutter pub get

echo "=== Building Flutter Web for Production ==="
flutter build web --release

echo "=== Build Complete ==="
