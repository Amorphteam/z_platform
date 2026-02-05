import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../model/audio_track_model.dart';
import '../service/audio_service.dart';
import '../screen/audio_player/audio_player_screen.dart';
import '../screen/audio_player/cubit/audio_player_cubit.dart';

/// Mini audio player widget that can be shown at the bottom of the screen
class AudioPlayerMini extends StatefulWidget {
  const AudioPlayerMini({super.key});

  @override
  State<AudioPlayerMini> createState() => _AudioPlayerMiniState();
}

class _AudioPlayerMiniState extends State<AudioPlayerMini> {
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<audio_service.MediaItem?>? _mediaItemSubscription;
  Timer? _handlerCheckTimer;
  
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  audio_service.MediaItem? _currentMediaItem;
  AudioPlayerHandler? _handler;
  
  @override
  void initState() {
    super.initState();
    _checkHandler();
    // Periodically check if handler becomes available
    // (in case audio service initializes after widget is built)
    _handlerCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _checkHandler();
        // Stop checking once we have a handler
        if (_handler != null) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }
  
  void _checkHandler() {
    final manager = AudioServiceManager();
    if (manager.handler != null && _handler != manager.handler) {
      setState(() {
        _handler = manager.handler;
      });
      _setupListeners();
    }
  }
  
  void _setupListeners() {
    if (_handler == null) return;
    
    _positionSubscription = _handler!.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });
    
    _playerStateSubscription = _handler!.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
      }
    });
    
    _mediaItemSubscription = _handler!.currentMediaItemStream.listen((mediaItem) {
      if (mounted) {
        setState(() => _currentMediaItem = mediaItem);
      }
    });
  }
  
  @override
  void dispose() {
    _handlerCheckTimer?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _togglePlayPause() async {
    if (_handler == null) return;
    if (_isPlaying) {
      await _handler!.pause();
    } else {
      await _handler!.play();
    }
  }
  
  void _openFullPlayer() {
    if (_handler == null || _handler!.tracks.isEmpty) return;
    final tracks = _handler!.tracks;
    final initialIndex = _handler!.currentIndex;
    final content = BlocProvider(
      create: (context) => AudioPlayerCubit(),
      child: AudioPlayerScreen(
        tracks: tracks,
        initialIndex: initialIndex,
      ),
    );
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: true,
        backgroundColor: Colors.transparent,
        builder: (context) => content,
      );
    } else {
      showMaterialModalBottomSheet(
        context: context,
        expand: true,
        backgroundColor: Colors.transparent,
        builder: (context) => content,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Don't show if no track is loaded
    if (_handler == null || _currentMediaItem == null) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openFullPlayer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surfaceVariant,
                  ),
                  child: _currentMediaItem?.artUri != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _currentMediaItem!.artUri!.toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                color: colorScheme.onSurfaceVariant,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.music_note,
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentMediaItem?.title ?? 'Unknown Title',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentMediaItem?.artist ?? 'Unknown Artist',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: colorScheme.primary,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                  onPressed: () {
                    _handler?.stopAndClear();
                  },
                  tooltip: 'إغلاق وإيقاف التشغيل',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
