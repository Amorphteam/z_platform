import 'dart:io';
import 'dart:ui';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import '../../model/audio_track_model.dart';
import '../../service/audio_service.dart';
import 'cubit/audio_player_cubit.dart';

/// Wraps iOS sliders in a horizontal flip so they draw RTL (min on right, max on left).
Widget _rtlSlider(Widget slider) {
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.diagonal3Values(-1, 1, 1),
    child: slider,
  );
}

class AudioPlayerScreen extends StatefulWidget {
  final List<AudioTrack> tracks;
  final int? initialIndex;
  
  const AudioPlayerScreen({
    super.key,
    required this.tracks,
    this.initialIndex,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize and load tracks after the first frame
    // This ensures the BlocProvider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AudioPlayerCubit>().initialize().then((_) {
          if (mounted) {
            context.read<AudioPlayerCubit>().loadTracks(
              widget.tracks,
              startIndex: widget.initialIndex,
            );
          }
        });
      }
    });
  }
  
  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Liquid Glass (CNSlider) on iOS 26+.
  bool _shouldUseLiquidGlass() {
    if (!Platform.isIOS) return false;
    try {
      final String version = Platform.operatingSystemVersion;
      return version.contains('26');
    } catch (_) {
      return false;
    }
  }

  /// Cupertino sliders on iOS 16+, Material on Android.
  bool _useCupertinoSlider() => Platform.isIOS;

  /// Stop all playback, clear queue, and pop this screen. Mini player will hide.
  void _closeAllAndPop(BuildContext context) {
    AudioServiceManager().handler?.stopAndClear();
    if (context.mounted) Navigator.of(context).pop();
  }

  /// Snaps speed to the nearest step (0.25) so iOS sliders and label show clean values.
  double _snapSpeedToStep(double speed) {
    final step = AudioPlayerCubit.speedStep;
    final min = AudioPlayerCubit.minSpeed;
    final max = AudioPlayerCubit.maxSpeed;
    final snapped = (speed / step).round() * step;
    return snapped.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        // Get current media item for background
        audio_service.MediaItem? backgroundImage;
        state.maybeWhen(
          loaded: (_, __, ___, ____, _____, ______, currentMediaItem, _______) {
            backgroundImage = currentMediaItem;
          },
          orElse: () {},
        );
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: null,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'تصغير',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () => _closeAllAndPop(context),
                  tooltip: 'إغلاق وإيقاف التشغيل',
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              // Background image with blur and opacity
              if (backgroundImage?.artUri != null)
                Positioned.fill(
                  child: Image.network(
                    backgroundImage!.artUri!.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        color: colorScheme.surfaceVariant,
                      ),
                  ),
                )
              else
                Container(
                  color: colorScheme.surfaceVariant,
                ),
              
              // Blur and opacity overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              
              // Content
              BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) => state.when(
                    initial: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    loaded: (
                      tracks,
                      currentIndex,
                      position,
                      duration,
                      isPlaying,
                      isLoading,
                      currentMediaItem,
                      playbackSpeed,
                    ) => _buildPlayerUI(
                      context,
                      theme,
                      colorScheme,
                      tracks,
                      currentIndex,
                      position,
                      duration,
                      isPlaying,
                      isLoading,
                      currentMediaItem,
                      playbackSpeed,
                    ),
                    error: (message) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPlayerUI(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<AudioTrack> tracks,
    int currentIndex,
    Duration position,
    Duration? duration,
    bool isPlaying,
    bool isLoading,
    audio_service.MediaItem? currentMediaItem,
    double playbackSpeed,
  ) => SafeArea(
        child: Column(
          children: [
          // Artwork and track info
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Artwork - Circular
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceVariant,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: currentMediaItem?.artUri != null
                      ? ClipOval(
                          child: Image.network(
                            currentMediaItem!.artUri!.toString(),
                            fit: BoxFit.cover,
                            width: 300,
                            height: 300,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.music_note,
                              size: 100,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.music_note,
                          size: 100,
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(height: 32),
                // Track title
                Text(
                  currentMediaItem?.title ?? 'Unknown Title',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Artist
                Text(
                  currentMediaItem?.artist ?? 'Unknown Artist',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Progress bar (reversed in RTL: start on right, end on left)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: _shouldUseLiquidGlass()
                      ? _rtlSlider(CNSlider(
                          value: duration != null && duration.inMilliseconds > 0
                              ? position.inMilliseconds.toDouble()
                              : 0.0,
                          min: 0,
                          max: duration != null && duration.inMilliseconds > 0
                              ? duration.inMilliseconds.toDouble()
                              : 1.0,
                          onChanged: (value) {
                            context.read<AudioPlayerCubit>().seek(
                              Duration(milliseconds: value.toInt()),
                            );
                          },
                        ))
                      : _useCupertinoSlider()
                          ? _rtlSlider(CupertinoSlider(
                              value: duration != null && duration.inMilliseconds > 0
                                  ? position.inMilliseconds.toDouble()
                                  : 0.0,
                              max: duration != null && duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0,
                              onChanged: (value) {
                                context.read<AudioPlayerCubit>().seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                              activeColor: colorScheme.primary,
                            ))
                          : Slider(
                              value: duration != null && duration.inMilliseconds > 0
                                  ? position.inMilliseconds.toDouble()
                                  : 0.0,
                              max: duration != null && duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1.0,
                              onChangeStart: (value) {},
                              onChanged: (value) {
                                context.read<AudioPlayerCubit>().seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                              onChangeEnd: (value) {
                                context.read<AudioPlayerCubit>().seek(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                              activeColor: colorScheme.primary,
                            ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Playback controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous track
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: currentIndex > 0
                      ? () => context.read<AudioPlayerCubit>().skipToPrevious()
                      : null,
                ),
                // 15 sec backward
                IconButton(
                  icon: Icon(Icons.replay_10, size: 32, color: Colors.white),
                  iconSize: 32,
                  color: Colors.white,
                  onPressed: () => context.read<AudioPlayerCubit>().seekForward15(),
                  tooltip: '١٥ ثانية للخلف',
                ),
                // Play/Pause
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                  child: IconButton(
                    icon: isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: colorScheme.onPrimary,
                          ),
                    iconSize: 40,
                    onPressed: () => context.read<AudioPlayerCubit>().togglePlayPause(),
                  ),
                ),
                // 15 sec forward
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 32, color: Colors.white),
                  iconSize: 32,
                  color: Colors.white,
                  onPressed: () => context.read<AudioPlayerCubit>().seekBackward15(),
                  tooltip: '١٥ ثانية للأمام',
                ),
                // Next track
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
                  iconSize: 40,
                  color: Colors.white,
                  onPressed: currentIndex < tracks.length - 1
                      ? () => context.read<AudioPlayerCubit>().skipToNext()
                      : null,
                ),
              ],
            ),
          ),

          // Speed slider (separate row below play/pause)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سرعة التشغيل',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '${_snapSpeedToStep(playbackSpeed)}x',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: _shouldUseLiquidGlass()
                        ? _rtlSlider(CNSlider(
                            value: _snapSpeedToStep(playbackSpeed),
                            min: AudioPlayerCubit.minSpeed,
                            max: AudioPlayerCubit.maxSpeed,
                            onChanged: (value) {
                              context.read<AudioPlayerCubit>().setSpeed(_snapSpeedToStep(value));
                            },
                          ))
                        : _useCupertinoSlider()
                            ? _rtlSlider(CupertinoSlider(
                                value: _snapSpeedToStep(playbackSpeed),
                                min: AudioPlayerCubit.minSpeed,
                                max: AudioPlayerCubit.maxSpeed,
                                divisions: ((AudioPlayerCubit.maxSpeed - AudioPlayerCubit.minSpeed) /
                                        AudioPlayerCubit.speedStep)
                                    .round(),
                                activeColor: colorScheme.primary,
                                onChanged: (value) {
                                  context.read<AudioPlayerCubit>().setSpeed(_snapSpeedToStep(value));
                                },
                              ))
                            : Slider(
                                value: playbackSpeed.clamp(
                                  AudioPlayerCubit.minSpeed,
                                  AudioPlayerCubit.maxSpeed,
                                ),
                                min: AudioPlayerCubit.minSpeed,
                                max: AudioPlayerCubit.maxSpeed,
                                divisions: ((AudioPlayerCubit.maxSpeed - AudioPlayerCubit.minSpeed) /
                                        AudioPlayerCubit.speedStep)
                                    .round(),
                                activeColor: colorScheme.primary,
                                onChanged: (value) {
                                  context.read<AudioPlayerCubit>().setSpeed(value);
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Track list
          if (tracks.length > 1)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(
                       Radius.circular(24),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                     Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Column(
                        children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListView.builder(
                            itemCount: tracks.length,
                            itemBuilder: (context, index) {
                              final track = tracks[index];
                              final isCurrentTrack = currentIndex == index;

                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: ListTile(
                                  leading: isCurrentTrack && isPlaying
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Lottie.asset(
                                            'assets/lottie/equalizer.json',
                                            fit: BoxFit.contain,
                                            repeat: true,
                                            animate: isPlaying,
                                            errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.equalizer,
                                                size: 24,
                                                color: Colors.white,
                                              ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.music_note,
                                          size: 24,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                  title: Text(
                                    track.title,
                                    style: TextStyle(
                                      fontWeight: isCurrentTrack
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isCurrentTrack
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      track.duration != null
                                          ? _formatDuration(track.duration)
                                          : '--:--',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                      )
                                    ),
                                  ),
                                  trailing: isCurrentTrack
                                      ?
                                          isPlaying ? const Icon(Icons.pause,size: 24,
                                            color: Colors.white,) : const Icon(Icons.check, size: 24,
                                            color: Colors.white,)


                                      : null,
                                  onTap: () => context.read<AudioPlayerCubit>().skipToTrack(index),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
}
