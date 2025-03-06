// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_toc_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SelectedTocItemImpl _$$SelectedTocItemImplFromJson(
        Map<String, dynamic> json) =>
    _$SelectedTocItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      epub: json['epub'] as String,
      section: json['section'] as String,
    );

Map<String, dynamic> _$$SelectedTocItemImplToJson(
        _$SelectedTocItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'epub': instance.epub,
      'section': instance.section,
    };
