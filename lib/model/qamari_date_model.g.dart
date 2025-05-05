// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qamari_date_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QamariDateModelImpl _$$QamariDateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$QamariDateModelImpl(
      data: (json['data'] as List<dynamic>)
          .map((e) => QamariData.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: (json['statusCode'] as num).toInt(),
      success: json['success'] as bool,
    );

Map<String, dynamic> _$$QamariDateModelImplToJson(
        _$QamariDateModelImpl instance) =>
    <String, dynamic>{
      'data': instance.data,
      'statusCode': instance.statusCode,
      'success': instance.success,
    };

_$QamariDataImpl _$$QamariDataImplFromJson(Map<String, dynamic> json) =>
    _$QamariDataImpl(
      gDate: json['gDate'] as String,
      hDay: (json['hDay'] as num).toInt(),
      hMonth: (json['hMonth'] as num).toInt(),
      hYear: (json['hYear'] as num).toInt(),
    );

Map<String, dynamic> _$$QamariDataImplToJson(_$QamariDataImpl instance) =>
    <String, dynamic>{
      'gDate': instance.gDate,
      'hDay': instance.hDay,
      'hMonth': instance.hMonth,
      'hYear': instance.hYear,
    };
