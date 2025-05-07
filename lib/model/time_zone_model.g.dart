// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeZoneModelImpl _$$TimeZoneModelImplFromJson(Map<String, dynamic> json) =>
    _$TimeZoneModelImpl(
      countryCode: json['country_code'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      comments: json['comments'] as String?,
      zone: json['zone'] as String,
    );

Map<String, dynamic> _$$TimeZoneModelImplToJson(_$TimeZoneModelImpl instance) =>
    <String, dynamic>{
      'country_code': instance.countryCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'comments': instance.comments,
      'zone': instance.zone,
    };
