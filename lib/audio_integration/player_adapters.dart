import 'package:audio_player/audio_player.dart' as audio_player;
import 'package:flutter/material.dart';
import '../route_generator.dart';

/// Creates the audio player interactions implementation for the app.
audio_player.AudioPlayerInteractions createAudioPlayerInteractions() {
  return AppAudioPlayerInteractions();
}

class AppAudioPlayerInteractions implements audio_player.AudioPlayerInteractions {
  @override
  void openPlayer(
    BuildContext context, {
    required List<audio_player.AudioTrack> tracks,
    int? startIndex,
  }) {
    // Use route_generator for consistent navigation
    Navigator.pushNamed(
      context,
      '/audioPlayer',
      arguments: {
        'tracks': tracks,
        'initialIndex': startIndex,
      },
    );
  }

  @override
  void playTrack(BuildContext context, audio_player.AudioTrack track) {
    openPlayer(context, tracks: [track]);
  }

  @override
  void playPlaylist(
    BuildContext context,
    List<audio_player.AudioTrack> tracks, {
    int? startIndex,
  }) {
    openPlayer(context, tracks: tracks, startIndex: startIndex);
  }
}
