// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ibn_hadid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IbnHadidImpl _$$IbnHadidImplFromJson(Map<String, dynamic> json) =>
    _$IbnHadidImpl(
      id: (json['id'] as num).toInt(),
      det: json['det'] as String,
      isFavorite: json['isFavorite'] == null
          ? false
          : _isFavoriteFromJson(json['isFavorite']),
    );

Map<String, dynamic> _$$IbnHadidImplToJson(_$IbnHadidImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'det': instance.det,
      'isFavorite': _isFavoriteToJson(instance.isFavorite),
    };
