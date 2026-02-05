import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_track_model.freezed.dart';
part 'audio_track_model.g.dart';

@freezed
class AudioTrack with _$AudioTrack {
  const factory AudioTrack({
    required String id,
    required String title,
    required String url,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
    @Default(false) bool isPlaying,
  }) = _AudioTrack;

  factory AudioTrack.fromJson(Map<String, dynamic> json) =>
      _$AudioTrackFromJson(json);
}
