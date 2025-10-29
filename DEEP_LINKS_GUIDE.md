# Deep Links Guide for Masaha App

## 📱 Supported Deep Links

Your app currently supports the following deep link patterns using the custom URL scheme `masaha://`:

### 1. **Open EPUB Viewer (with optional page)**
```
masaha://epub?book=bookname.epub&page=12
```
**Example**: Open book "1.epub" at page 12
```
masaha://epub?book=1.epub&page=12
```

### 2. **Open Library Screen**
```
masaha://library
```

### 3. **Open Search Screen**
```
masaha://search?query=searchterm
```
**Example**: Search for "example"
```
masaha://search?query=example
```

### 4. **Open Chat Screen**
```
masaha://chat
```

### 5. **Open Home (default)**
```
masaha://
```

## 🧪 Testing Deep Links

### On Android:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "masaha://epub?book=1.epub&page=12"
```

### On iOS (from Terminal):
```bash
xcrun simctl openurl booted "masaha://epub?book=1.epub&page=12"
```

### From a Browser or Another App:
Simply create a link with the URL:
```html
<a href="masaha://epub?book=1.epub&page=12">Open Book</a>
```

## 🔗 Adding Support for HTTPS Universal Links (Advanced)

If you want to support links from the web (like `https://yourdomain.com/book/1`), you'll need to:

1. **Set up App Links domain verification** on your server
2. **Add the domain to AndroidManifest.xml**:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https" android:host="yourdomain.com"/>
</intent-filter>
```

3. **Create an apple-app-site-association file** on your server (for iOS)
4. **Update the deep link service** to handle these paths

## 📝 Adding New Deep Link Routes

To add a new deep link route:

1. **Update `lib/service/deep_link_service.dart`**:
```dart
case '/newroute':
  return DeepLinkData(
    route: '/yourRouteName',
    arguments: {
      'param1': queryParams['param1'],
    },
  );
```

2. **Add the route to `lib/route_generator.dart`** if it doesn't exist

3. **Test the link** using the methods above

## 🎯 Example Usage in Code

```dart
// Opening a book at a specific page from your app
String url = "masaha://epub?book=1.epub&page=12";

// You can use url_launcher to open it
launchUrl(Uri.parse(url));
```
