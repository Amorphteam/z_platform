# Audio Player Guide

This guide explains how to use the audio player feature in the Masaha app.

## Features

- ✅ Online audio playback from URLs
- ✅ Background playback on both iOS and Android
- ✅ Media center notifications with controls
- ✅ Playlist support
- ✅ Playback speed control
- ✅ Seek functionality
- ✅ Previous/Next track navigation

## Usage

### Basic Usage - Play a Single Track

```dart
import 'package:masaha/model/audio_track_model.dart';
import 'package:masaha/screen/audio_player/audio_player_screen.dart';

// Create an audio track
final track = AudioTrack(
  id: 'track1',
  title: 'Track Title',
  url: 'https://example.com/audio.mp3',
  artist: 'Artist Name',
  artworkUrl: 'https://example.com/artwork.jpg', // Optional
);

// Navigate to audio player
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AudioPlayerScreen(
      tracks: [track],
    ),
  ),
);
```

### Play a Playlist

```dart
final tracks = [
  AudioTrack(
    id: 'track1',
    title: 'Track 1',
    url: 'https://example.com/track1.mp3',
    artist: 'Artist',
  ),
  AudioTrack(
    id: 'track2',
    title: 'Track 2',
    url: 'https://example.com/track2.mp3',
    artist: 'Artist',
  ),
];

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AudioPlayerScreen(
      tracks: tracks,
      initialIndex: 0, // Optional: start from specific track
    ),
  ),
);
```

### Using Routes

```dart
Navigator.pushNamed(
  context,
  '/audioPlayer',
  arguments: {
    'tracks': tracks,
    'initialIndex': 0, // Optional
  },
);
```

### Programmatic Control

```dart
import 'package:masaha/service/audio_service.dart';

// Get the audio handler
final handler = AudioServiceManager().handler;

if (handler != null) {
  // Load tracks
  await handler.loadTracks(tracks, startIndex: 0);
  
  // Control playback
  await handler.play();
  await handler.pause();
  await handler.stop();
  
  // Navigation
  await handler.skipToNext();
  await handler.skipToPrevious();
  
  // Seek
  await handler.seek(Duration(minutes: 2));
  
  // Speed control
  await handler.setSpeed(1.5); // 1.5x speed
}
```

### Mini Player Widget

Add the mini player widget to your scaffold:

```dart
Scaffold(
  body: YourContent(),
  bottomNavigationBar: const AudioPlayerMini(),
)
```

## Platform Configuration

### Android

The following permissions and services are already configured in `AndroidManifest.xml`:

- `WAKE_LOCK` - Keep device awake during playback
- `FOREGROUND_SERVICE` - Required for background playback
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK` - Media playback foreground service
- Audio service declaration for media notifications

### iOS

Background audio capabilities are configured in `Info.plist`:

- `UIBackgroundModes` with `audio` mode enabled

## Media Notifications

The audio player automatically shows media notifications on both platforms with:

- Track title and artist
- Artwork (if provided)
- Play/Pause button
- Previous/Next buttons
- Progress bar (on supported platforms)
- Close button

## Audio Track Model

```dart
class AudioTrack {
  final String id;              // Unique identifier
  final String title;           // Track title
  final String url;             // Audio file URL (required)
  final String? artist;        // Artist name (optional)
  final String? album;          // Album name (optional)
  final String? artworkUrl;     // Artwork image URL (optional)
  final Duration? duration;     // Track duration (optional, auto-detected)
  final bool isPlaying;         // Playback state
}
```

## Supported Audio Formats

The player supports all formats supported by `just_audio`:

- MP3
- AAC
- M4A
- OGG
- WAV
- And more (platform dependent)

## Notes

- The audio service is initialized automatically when the app starts
- Audio continues playing in the background when the app is minimized
- Media notifications work on both iOS and Android
- The player handles network interruptions gracefully
- Playback state is preserved across app restarts (when using the service)

## Troubleshooting

### Audio doesn't play

1. Check that the URL is accessible and returns audio content
2. Verify network permissions are granted
3. Check device volume settings

### Notifications don't appear

1. On Android, ensure notification permissions are granted
2. Check that the audio service is properly initialized
3. Verify the notification channel is created (Android 8.0+)

### Background playback stops

1. Ensure background audio mode is enabled in iOS Info.plist
2. Check that the foreground service is properly configured on Android
3. Verify the device isn't in battery saver mode (may restrict background activity)
