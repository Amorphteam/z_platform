// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate_khotab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranslateImpl _$$TranslateImplFromJson(Map<String, dynamic> json) =>
    _$TranslateImpl(
      main: (json['main'] as num?)?.toInt(),
      faJafari: (json['fa_jafari'] as num?)?.toInt(),
      faAnsarian: (json['fa_ansarian'] as num?)?.toInt(),
      faFaidh: (json['fa_faidh'] as num?)?.toInt(),
      faShahidi: (json['fa_shahidi'] as num?)?.toInt(),
      en1: (json['en1'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TranslateImplToJson(_$TranslateImpl instance) =>
    <String, dynamic>{
      'main': instance.main,
      'fa_jafari': instance.faJafari,
      'fa_ansarian': instance.faAnsarian,
      'fa_faidh': instance.faFaidh,
      'fa_shahidi': instance.faShahidi,
      'en1': instance.en1,
    };
