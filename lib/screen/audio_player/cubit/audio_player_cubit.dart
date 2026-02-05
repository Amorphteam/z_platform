import 'dart:async';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:just_audio/just_audio.dart';
import '../../../model/audio_track_model.dart';
import '../../../service/audio_service.dart';

part 'audio_player_state.dart';
part 'audio_player_cubit.freezed.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  AudioPlayerCubit() : super(const AudioPlayerState.initial());
  
  AudioPlayerHandler? _handler;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<audio_service.MediaItem?>? _mediaItemSubscription;
  
  bool _isSeeking = false;
  List<AudioTrack> _tracks = [];
  
  /// Initialize the audio handler
  Future<void> initialize() async {
    emit(const AudioPlayerState.loading());
    
    try {
      final manager = AudioServiceManager();
      if (!manager.isInitialized) {
        await manager.initialize();
      }
      _handler = manager.handler;
      
      if (_handler == null) {
        emit(const AudioPlayerState.error('فشل في تهيئة مشغل الصوت'));
        return;
      }
      
      _setupListeners();
    } catch (e) {
      emit(AudioPlayerState.error('خطأ في تهيئة مشغل الصوت: $e'));
    }
  }
  
  /// Load tracks
  Future<void> loadTracks(List<AudioTrack> tracks, {int? startIndex}) async {
    if (_handler == null) {
      await initialize();
      if (_handler == null) return;
    }
    
    // Check if same tracks are already loaded
    final currentTracks = _handler!.tracks;
    final isSamePlaylist = _areTracksSame(currentTracks, tracks);
    
    if (isSamePlaylist && currentTracks.isNotEmpty) {
      // Same tracks already loaded, preserve state
      _handler!.refreshCurrentMediaItem();
      _syncState();
      return;
    }
    
    emit(const AudioPlayerState.loading());
    _tracks = tracks;
    
    try {
      await _handler!.loadTracks(tracks, startIndex: startIndex ?? 0);
      _syncState();
    } catch (e) {
      emit(AudioPlayerState.error('Error loading audio: $e'));
    }
  }
  
  void _setupListeners() {
    if (_handler == null) return;
    
    _positionSubscription = _handler!.positionStream.listen((position) {
      if (!_isSeeking) {
        state.maybeWhen(
          loaded: (tracks, currentIndex, _, duration, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
            emit(AudioPlayerState.loaded(
              tracks: tracks,
              currentIndex: currentIndex,
              position: position,
              duration: duration,
              isPlaying: isPlaying,
              isLoading: isLoading,
              currentMediaItem: currentMediaItem,
              playbackSpeed: playbackSpeed,
            ));
          },
          orElse: () {},
        );
      }
    });
    
    _durationSubscription = _handler!.durationStream.listen((duration) {
      state.maybeWhen(
        loaded: (tracks, currentIndex, position, _, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
          emit(AudioPlayerState.loaded(
            tracks: tracks,
            currentIndex: currentIndex,
            position: position,
            duration: duration,
            isPlaying: isPlaying,
            isLoading: isLoading,
            currentMediaItem: currentMediaItem,
            playbackSpeed: playbackSpeed,
          ));
        },
        orElse: () {},
      );
    });
    
    _playerStateSubscription = _handler!.playerStateStream.listen((playerState) {
      state.maybeWhen(
        loaded: (tracks, currentIndex, position, duration, _, __, currentMediaItem, playbackSpeed) {
          emit(AudioPlayerState.loaded(
            tracks: tracks,
            currentIndex: currentIndex,
            position: position,
            duration: duration,
            isPlaying: playerState.playing,
            isLoading: playerState.processingState == ProcessingState.loading ||
                       playerState.processingState == ProcessingState.buffering,
            currentMediaItem: currentMediaItem,
            playbackSpeed: playbackSpeed,
          ));
        },
        orElse: () {},
      );
    });
    
    _mediaItemSubscription = _handler!.currentMediaItemStream.listen((mediaItem) {
      state.maybeWhen(
        loaded: (tracks, currentIndex, position, duration, isPlaying, isLoading, _, playbackSpeed) {
          emit(AudioPlayerState.loaded(
            tracks: tracks,
            currentIndex: currentIndex,
            position: position,
            duration: duration,
            isPlaying: isPlaying,
            isLoading: isLoading,
            currentMediaItem: mediaItem,
            playbackSpeed: playbackSpeed,
          ));
        },
        orElse: () {},
      );
    });
  }
  
  void _syncState() {
    if (_handler == null) return;
    
    emit(AudioPlayerState.loaded(
      tracks: _handler!.tracks,
      currentIndex: _handler!.currentIndex,
      position: _handler!.position,
      duration: _handler!.duration,
      isPlaying: _handler!.isPlaying,
      isLoading: false,
      currentMediaItem: null,
      playbackSpeed: 1.0,
    ));
    
    // Update media item
    _handler!.refreshCurrentMediaItem();
  }
  
  bool _areTracksSame(List<AudioTrack> tracks1, List<AudioTrack> tracks2) {
    if (tracks1.length != tracks2.length) return false;
    for (int i = 0; i < tracks1.length; i++) {
      if (tracks1[i].id != tracks2[i].id || tracks1[i].url != tracks2[i].url) {
        return false;
      }
    }
    return true;
  }
  
  /// Seek to position
  Future<void> seek(Duration position) async {
    if (_handler == null) return;
    
    var shouldSeek = false;
    state.maybeWhen(
      loaded: (tracks, currentIndex, _, duration, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
        _isSeeking = true;
        shouldSeek = true;
        emit(AudioPlayerState.loaded(
          tracks: tracks,
          currentIndex: currentIndex,
          position: position,
          duration: duration,
          isPlaying: isPlaying,
          isLoading: isLoading,
          currentMediaItem: currentMediaItem,
          playbackSpeed: playbackSpeed,
        ));
      },
      orElse: () {},
    );
    
    if (shouldSeek) {
      await _handler!.seek(position);
      
      Future.delayed(const Duration(milliseconds: 100), () {
        _isSeeking = false;
      });
    }
  }
  
  static const Duration _seekStep = Duration(seconds: 15);

  /// Seek backward by 15 seconds
  Future<void> seekBackward15() async {
    if (_handler == null) return;
    state.maybeWhen(
      loaded: (tracks, currentIndex, position, duration, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
        final newPosition = position - _seekStep;
        seek(newPosition.isNegative ? Duration.zero : newPosition);
      },
      orElse: () {},
    );
  }

  /// Seek forward by 15 seconds
  Future<void> seekForward15() async {
    if (_handler == null) return;
    state.maybeWhen(
      loaded: (tracks, currentIndex, position, duration, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
        final newPosition = position + _seekStep;
        final target = duration != null && newPosition > duration!
            ? duration!
            : newPosition;
        seek(target);
      },
      orElse: () {},
    );
  }
  
  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_handler == null) return;
    
    state.maybeWhen(
      loaded: (tracks, currentIndex, position, duration, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
        if (isPlaying) {
          _handler!.pause();
        } else {
          _handler!.play();
        }
      },
      orElse: () {},
    );
  }
  
  /// Skip to next track
  Future<void> skipToNext() async {
    if (_handler == null) return;
    await _handler!.skipToNext();
    _syncState();
  }
  
  /// Skip to previous track
  Future<void> skipToPrevious() async {
    if (_handler == null) return;
    await _handler!.skipToPrevious();
    _syncState();
  }
  
  /// Skip to specific track
  Future<void> skipToTrack(int index) async {
    if (_handler == null) return;
    await _handler!.skipToQueueItem(index);
    _syncState();
  }
  
  /// Minimum and maximum playback speed
  static const double minSpeed = 0.5;
  static const double maxSpeed = 3.0;
  static const double speedStep = 0.5;

  /// Set playback speed (use with slider)
  Future<void> setSpeed(double speed) async {
    if (_handler == null) return;
    final clamped = speed.clamp(minSpeed, maxSpeed);
    state.maybeWhen(
      loaded: (tracks, currentIndex, position, duration, isPlaying, isLoading, currentMediaItem, _) {
        _handler!.setSpeed(clamped);
        emit(AudioPlayerState.loaded(
          tracks: tracks,
          currentIndex: currentIndex,
          position: position,
          duration: duration,
          isPlaying: isPlaying,
          isLoading: isLoading,
          currentMediaItem: currentMediaItem,
          playbackSpeed: clamped,
        ));
      },
      orElse: () {},
    );
  }

  /// Change playback speed (cycle to next – kept for compatibility)
  Future<void> changeSpeed() async {
    if (_handler == null) return;
    state.maybeWhen(
      loaded: (tracks, currentIndex, position, duration, isPlaying, isLoading, currentMediaItem, playbackSpeed) {
        final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0];
        final speedIndex = speeds.indexOf(playbackSpeed);
        final nextIndex = (speedIndex + 1) % speeds.length;
        final newSpeed = speeds[nextIndex];
        _handler!.setSpeed(newSpeed);
        emit(AudioPlayerState.loaded(
          tracks: tracks,
          currentIndex: currentIndex,
          position: position,
          duration: duration,
          isPlaying: isPlaying,
          isLoading: isLoading,
          currentMediaItem: currentMediaItem,
          playbackSpeed: newSpeed,
        ));
      },
      orElse: () {},
    );
  }
  
  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    return super.close();
  }
}
