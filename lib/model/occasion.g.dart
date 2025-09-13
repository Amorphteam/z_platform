// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occasion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OccasionImpl _$$OccasionImplFromJson(Map<String, dynamic> json) =>
    _$OccasionImpl(
      day: (json['day'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      occasion: json['occasion'] as String,
    );

Map<String, dynamic> _$$OccasionImplToJson(_$OccasionImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'month': instance.month,
      'occasion': instance.occasion,
    };
