// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AudioTrackImpl _$$AudioTrackImplFromJson(Map<String, dynamic> json) =>
    _$AudioTrackImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      isPlaying: json['isPlaying'] as bool? ?? false,
    );

Map<String, dynamic> _$$AudioTrackImplToJson(_$AudioTrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'artist': instance.artist,
      'album': instance.album,
      'artworkUrl': instance.artworkUrl,
      'duration': instance.duration?.inMicroseconds,
      'isPlaying': instance.isPlaying,
    };
