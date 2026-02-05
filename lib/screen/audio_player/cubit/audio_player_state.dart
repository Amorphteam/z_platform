part of 'audio_player_cubit.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState.initial() = _Initial;
  const factory AudioPlayerState.loading() = _Loading;
  const factory AudioPlayerState.loaded({
    required List<AudioTrack> tracks,
    required int currentIndex,
    required Duration position,
    Duration? duration,
    required bool isPlaying,
    required bool isLoading,
    audio_service.MediaItem? currentMediaItem,
    @Default(1.0) double playbackSpeed,
  }) = _Loaded;
  const factory AudioPlayerState.error(String message) = _Error;
}
