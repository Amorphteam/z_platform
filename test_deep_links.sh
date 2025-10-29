#!/bin/bash

# Deep Links Testing Script for Masaha App
# Usage: ./test_deep_links.sh [platform] [test_number]

PLATFORM=${1:-ios}  # Default to ios
TEST_NUMBER=${2:-1}

echo "Testing Deep Links for Masaha App on $PLATFORM"
echo "Test Number: $TEST_NUMBER"
echo ""

# Test cases
case $TEST_NUMBER in
  1)
    echo "📖 Test 1: Open EPUB at specific page"
    LINK="masaha://epub?book=1.epub&page=12"
    ;;
  2)
    echo "📚 Test 2: Open Library"
    LINK="masaha://library"
    ;;
  3)
    echo "🔍 Test 3: Open Search"
    LINK="masaha://search?query=test"
    ;;
  4)
    echo "💬 Test 4: Open Chat"
    LINK="masaha://chat"
    ;;
  5)
    echo "🏠 Test 5: Open Home (default)"
    LINK="masaha://"
    ;;
  *)
    echo "Invalid test number. Use 1-5"
    exit 1
    ;;
esac

if [ "$PLATFORM" = "ios" ]; then
  echo "Opening: $LINK"
  xcrun simctl openurl booted "$LINK"
elif [ "$PLATFORM" = "android" ]; then
  echo "Opening: $LINK"
  adb shell am start -W -a android.intent.action.VIEW -d "$LINK"
else
  echo "Invalid platform. Use 'ios' or 'android'"
  exit 1
fi

echo ""
echo "✅ Deep link sent. Check your app!"
