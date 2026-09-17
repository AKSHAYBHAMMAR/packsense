#!/usr/bin/env bash
set -e

echo "==> PackSense Vercel Deployment Script"

# Install Flutter SDK if not available in build environment
if ! command -v flutter &> /dev/null; then
  echo "==> Setting up Flutter SDK (stable branch)..."
  if [ ! -d "$HOME/flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
  fi
  export PATH="$PATH:$HOME/flutter/bin"
fi

echo "==> Verifying Flutter version..."
flutter --version

echo "==> Enabling Flutter Web..."
flutter config --enable-web

echo "==> Installing project dependencies..."
flutter pub get

echo "==> Compiling Flutter Web release build..."
flutter build web --release

echo "==> Verifying build output directory..."
if [ -f "build/web/index.html" ]; then
  echo "==> Success: build/web/index.html ready for Vercel deployment."
else
  echo "==> Error: build/web/index.html was not generated."
  exit 1
fi
