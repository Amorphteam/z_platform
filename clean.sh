#!/bin/bash

# Clean Flutter
fvm flutter clean

# Remove pub cache
rm -rf pubspec.lock
rm -rf .dart_tool/
rm -rf build/

# Get packages
fvm flutter pub get

# Run build runner
fvm flutter pub run build_runner build --delete-conflicting-outputs

echo "Clean and rebuild completed!" 