// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rejal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RejalImpl _$$RejalImplFromJson(Map<String, dynamic> json) => _$RejalImpl(
      ID: (json['ID'] as num?)?.toInt() ?? null,
      name: json['name'] as String,
      name2: json['name2'] as String,
      det: json['det'] as String,
      joz: (json['joz'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      harf: json['harf'] as String,
    );

Map<String, dynamic> _$$RejalImplToJson(_$RejalImpl instance) =>
    <String, dynamic>{
      'ID': instance.ID,
      'name': instance.name,
      'name2': instance.name2,
      'det': instance.det,
      'joz': instance.joz,
      'page': instance.page,
      'harf': instance.harf,
    };
