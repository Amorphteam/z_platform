// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hekam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HekamImpl _$$HekamImplFromJson(Map<String, dynamic> json) => _$HekamImpl(
      id: (json['id'] as num).toInt(),
      asl: json['asl'] as String,
      english1: json['english1'] as String?,
      farsi1: json['farsi1'] as String?,
      farsi2: json['farsi2'] as String?,
      farsi3: json['farsi3'] as String?,
      farsi4: json['farsi4'] as String?,
      isFavorite: json['isFavorite'] == null
          ? false
          : _isFavoriteFromJson(json['isFavorite']),
    );

Map<String, dynamic> _$$HekamImplToJson(_$HekamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'asl': instance.asl,
      'english1': instance.english1,
      'farsi1': instance.farsi1,
      'farsi2': instance.farsi2,
      'farsi3': instance.farsi3,
      'farsi4': instance.farsi4,
      'isFavorite': _isFavoriteToJson(instance.isFavorite),
    };
