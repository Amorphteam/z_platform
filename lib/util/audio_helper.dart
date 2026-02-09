import 'dart:io';
import 'package:masaha/model/audio_track_model.dart';
import 'package:masaha/screen/audio_player/audio_player_screen.dart';
import 'package:masaha/screen/audio_player/cubit/audio_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// Helper functions for audio player operations
class AudioHelper {
  /// Open audio player as a bottom sheet (slides up). Minimize slides it down.
  static void _showPlayerSheet(
    BuildContext context, {
    required List<AudioTrack> tracks,
    int? startIndex,
  }) {
    final content = BlocProvider(
      create: (context) => AudioPlayerCubit(),
      child: AudioPlayerScreen(
        tracks: tracks,
        initialIndex: startIndex,
      ),
    );
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        useRootNavigator: true,
        context: context,
        expand: true,
        backgroundColor: Colors.red,
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

  /// Open audio player with a single track
  static void playTrack(
    BuildContext context,
    AudioTrack track,
  ) {
    _showPlayerSheet(context, tracks: [track]);
  }

  /// Open audio player with a playlist
  static void playPlaylist(
    BuildContext context,
    List<AudioTrack> tracks, {
    int? startIndex,
  }) {
    _showPlayerSheet(context, tracks: tracks, startIndex: startIndex);
  }

  /// Create an AudioTrack from a URL
  static AudioTrack createTrack({
    required String id,
    required String title,
    required String url,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
  }) {
    return AudioTrack(
      id: id,
      title: title,
      url: url,
      artist: artist,
      album: album,
      artworkUrl: artworkUrl,
      duration: duration,
    );
  }
}
