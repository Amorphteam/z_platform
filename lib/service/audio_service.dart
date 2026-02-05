import 'dart:async';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import '../model/audio_track_model.dart';

/// Background audio handler that integrates with the platform's media controls
class AudioPlayerHandler extends audio_service.BaseAudioHandler
    with audio_service.QueueHandler, audio_service.SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  
  // Stream controllers for state management
  final _playbackStateController = StreamController<audio_service.PlaybackState>.broadcast();
  final _currentMediaItemController = StreamController<audio_service.MediaItem?>.broadcast();
  
  // Current track index
  int _currentIndex = 0;
  List<AudioTrack> _tracks = [];
  
  AudioPlayerHandler() {
    _init();
  }
  
  void _init() {
    // Listen to player state changes
    _player.playbackEventStream.listen((event) {
      _playbackStateController.add(_playbackState);
    });
    
    // Listen to position changes
    _player.positionStream.listen((position) {
      _playbackStateController.add(_playbackState);
    });
    
    // Listen to duration changes
    _player.durationStream.listen((duration) {
      _playbackStateController.add(_playbackState);
    });
    
    // Handle player errors
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // Auto-play next track when current finishes
        if (_currentIndex < _tracks.length - 1) {
          skipToNext();
        } else {
          // Loop back to first track or stop
          pause();
        }
      }
    });
  }
  
  audio_service.PlaybackState get _playbackState {
    return audio_service.PlaybackState(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        if (_player.playing) audio_service.MediaControl.pause else audio_service.MediaControl.play,
        audio_service.MediaControl.skipToNext,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _processingState,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    );
  }
  
  audio_service.AudioProcessingState get _processingState {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return audio_service.AudioProcessingState.idle;
      case ProcessingState.loading:
        return audio_service.AudioProcessingState.loading;
      case ProcessingState.buffering:
        return audio_service.AudioProcessingState.buffering;
      case ProcessingState.ready:
        return audio_service.AudioProcessingState.ready;
      case ProcessingState.completed:
        return audio_service.AudioProcessingState.completed;
    }
  }
  
  /// Load a list of tracks and start playing
  Future<void> loadTracks(List<AudioTrack> tracks, {int? startIndex}) async {
    _tracks = tracks;
    _currentIndex = startIndex ?? 0;
    
    // Clear existing playlist
    await _playlist.clear();
    
    // Create media items for the queue
    final mediaItems = tracks.map((track) {
      return audio_service.MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist ?? 'Unknown Artist',
        album: track.album,
        artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
        duration: track.duration,
      );
    }).toList();
    
    // Set the queue
    queue.value = mediaItems;
    
    // Add all tracks to playlist for just_audio
    final audioSources = tracks.map((track) {
      return AudioSource.uri(
        Uri.parse(track.url),
        tag: audio_service.MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist ?? 'Unknown Artist',
          album: track.album,
          artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
          duration: track.duration,
        ),
      );
    }).toList();
    
    await _playlist.addAll(audioSources);
    await _player.setAudioSource(_playlist);
    
    // Update current media item
    if (_tracks.isNotEmpty) {
      _updateMediaItem(_currentIndex);
    }
  }
  
  /// Load a single track
  Future<void> loadTrack(AudioTrack track) async {
    await loadTracks([track], startIndex: 0);
  }
  
  void _updateMediaItem(int index) {
    if (index >= 0 && index < _tracks.length && index < queue.value.length) {
      final mediaItem = queue.value[index];
      _currentMediaItemController.add(mediaItem);
      // Update the current media item in the audio service
      this.mediaItem.value = mediaItem;
    }
  }
  
  /// Refresh the current media item (useful when preserving state)
  void refreshCurrentMediaItem() {
    if (_tracks.isNotEmpty && _currentIndex >= 0 && _currentIndex < _tracks.length) {
      _updateMediaItem(_currentIndex);
    }
  }
  
  @override
  Future<void> play() => _player.play();
  
  @override
  Future<void> pause() => _player.pause();
  
  @override
  Future<void> stop() => _player.stop();

  /// Stop playback, clear playlist and queue. Used when user closes the player (X).
  /// After this, mini player will hide because current media item becomes null.
  Future<void> stopAndClear() async {
    await _player.stop();
    await _playlist.clear();
    await _player.setAudioSource(_playlist);
    _tracks = [];
    _currentIndex = 0;
    queue.value = [];
    mediaItem.value = null;
    _currentMediaItemController.add(null);
  }
  
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  
  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _tracks.length - 1) {
      _currentIndex++;
      await _player.seekToNext();
      _updateMediaItem(_currentIndex);
    }
  }
  
  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _player.seekToPrevious();
      _updateMediaItem(_currentIndex);
    } else {
      // Restart current track
      await _player.seek(Duration.zero);
    }
  }
  
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      await _player.seek(Duration.zero, index: index);
      _updateMediaItem(_currentIndex);
    }
  }
  
  /// Get current playback position stream
  Stream<Duration> get positionStream => _player.positionStream;
  
  /// Get current duration stream
  Stream<Duration?> get durationStream => _player.durationStream;
  
  /// Get player state stream
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  
  /// Get playback state stream
  Stream<audio_service.PlaybackState> get playbackStateStream => _playbackStateController.stream;
  
  /// Get current media item stream
  Stream<audio_service.MediaItem?> get currentMediaItemStream => _currentMediaItemController.stream;
  
  /// Get current position
  Duration get position => _player.position;
  
  /// Get duration
  Duration? get duration => _player.duration;
  
  /// Get whether playing
  bool get isPlaying => _player.playing;
  
  /// Get current track index
  int get currentIndex => _currentIndex;
  
  /// Get all tracks
  List<AudioTrack> get tracks => _tracks;
  
  /// Get current track
  AudioTrack? get currentTrack {
    if (_currentIndex >= 0 && _currentIndex < _tracks.length) {
      return _tracks[_currentIndex];
    }
    return null;
  }
  
  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }
  
  /// Dispose resources
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    await _playbackStateController.close();
    await _currentMediaItemController.close();
    return super.onTaskRemoved();
  }
}

/// Singleton service to manage audio playback
class AudioServiceManager {
  static final AudioServiceManager _instance = AudioServiceManager._internal();
  factory AudioServiceManager() => _instance;
  AudioServiceManager._internal();
  
  AudioPlayerHandler? _handler;
  bool _isInitialized = false;
  
  /// Initialize the audio service
  Future<void> initialize() async {
    // If we already have a handler, don't reinitialize
    if (_handler != null && _isInitialized) return;
    
    // Initialize the service
    // Note: We don't try to stop first because the cache manager state
    // persists and causes assertion errors. The service will handle
    // being called multiple times gracefully.
    try {
      _handler = await audio_service.AudioService.init(
        builder: () => AudioPlayerHandler(),
        config: const audio_service.AudioServiceConfig(
          androidNotificationChannelId: 'com.masaha.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationChannelDescription: 'Audio playback controls',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidShowNotificationBadge: true,
          androidNotificationIcon: 'drawable/ic_notification',
          notificationColor: Colors.blue,
        ),
      );
      _isInitialized = true;
      print('Audio service initialized successfully');
    } catch (e) {
      // If initialization fails due to cache manager assertion,
      // the service is already initialized (likely from a previous run)
      // This can happen after app restart if the service wasn't properly cleaned up
      if (e.toString().contains('_cacheManager') || 
          e.toString().contains('Failed assertion')) {
        print('Audio service already initialized (cache manager error)');
        print('This can happen if the service state persists. Handler will be null.');
        _isInitialized = true;
        // Handler remains null - UI will handle this gracefully
        // The service is running but we can't access the handler
      } else {
        // For other errors, rethrow so they can be handled upstream
        print('Audio service init failed: $e');
        rethrow;
      }
    }
  }
  
  /// Get the audio handler
  AudioPlayerHandler? get handler => _handler;
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
  
  /// Dispose the service
  Future<void> dispose() async {
    if (_handler != null) {
      await _handler!.onTaskRemoved();
      _handler = null;
    }
    _isInitialized = false;
  }
}
