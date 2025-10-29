# 🧪 How to Test Deep Links in Masaha App

## Method 1: iOS Simulator (Easiest)

### Step 1: Run your app
```bash
fvm flutter run
```

### Step 2: While app is running, open a new terminal and test:

```bash
# Test 1: Open EPUB at page 12
xcrun simctl openurl booted "masaha://epub?book=1.epub&page=12"

# Test 2: Open Library
xcrun simctl openurl booted "masaha://library"

# Test 3: Open Search
xcrun simctl openurl booted "masaha://search?query=test"

# Test 4: Open Chat
xcrun simctl openurl booted "masaha://chat"

# Test 5: Open Home
xcrun simctl openurl booted "masaha://"
```

## Method 2: Using Safari on iOS Simulator

1. **Run your app** on the simulator
2. **Open Safari** in the simulator
3. **Type in the address bar**: `masaha://epub?book=1.epub&page=12`
4. **Press Go** - Safari will ask if you want to open it in Masaha app

## Method 3: Using the Test Script

```bash
# Make it executable (first time only)
chmod +x test_deep_links.sh

# Test different scenarios
./test_deep_links.sh ios 1  # Open EPUB
./test_deep_links.sh ios 2  # Open Library
./test_deep_links.sh ios 3  # Open Search
./test_deep_links.sh ios 4  # Open Chat
./test_deep_links.sh ios 5  # Open Home
```

## Method 4: Android (When Available)

```bash
# Make sure your app is running on Android device/emulator
# Then in another terminal:

# Test 1: Open EPUB at page 12
adb shell am start -W -a android.intent.action.VIEW -d "masaha://epub?book=1.epub&page=12"

# Test 2: Open Library
adb shell am start -W -a android.intent.action.VIEW -d "masaha://library"

# Test 3: Open Search
adb shell am start -W -a android.intent.action.VIEW -d "masaha://search?query=test"

# Test 4: Open Chat
adb shell am start -W -a android.intent.action.VIEW -d "masaha://chat"
```

## Method 5: From Another App

You can test deep links by creating a simple HTML file and opening it:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Test Deep Links</title>
</head>
<body>
    <h1>Test Masaha Deep Links</h1>
    <ul>
        <li><a href="masaha://epub?book=1.epub&page=12">Open EPUB (page 12)</a></li>
        <li><a href="masaha://library">Open Library</a></li>
        <li><a href="masaha://search?query=test">Open Search</a></li>
        <li><a href="masaha://chat">Open Chat</a></li>
    </ul>
</body>
</html>
```

Save this as `test_links.html`, then open it in Safari or Chrome.

## 📱 Testing on Physical Devices

### iOS Device:
1. Connect your iPhone via cable
2. Open Safari on your iPhone
3. Type the deep link URL in the address bar
4. Safari will ask if you want to open in Masaha app

### Android Device:
1. Connect your Android device via USB (with USB debugging enabled)
2. Use the `adb` commands from Method 4 above

## 🔍 Debugging Tips

### Check if deep link is received:
Look for this in your Flutter console:
```
Deep link received: masaha://epub?book=1.epub&page=12
```

### Common Issues:

1. **"App not opening"**
   - Make sure the app is built with the latest manifest changes
   - Restart the app completely
   - Rebuild: `fvm flutter clean && fvm flutter run`

2. **"Route not found"**
   - Check the console logs for the parsed route
   - Ensure the route exists in `route_generator.dart`

3. **"No effect"**
   - Make sure DeepLinkListener is properly initialized
   - Check that the app is listening to deep links in main.dart

## 🎯 Quick Test Commands

```bash
# Quick test - this should work immediately
fvm flutter run
# Then in another terminal:
xcrun simctl openurl booted "masaha://library"
```

Your app should navigate to the library screen!
