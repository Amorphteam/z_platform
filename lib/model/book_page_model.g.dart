// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookPageModelImpl _$$BookPageModelImplFromJson(Map<String, dynamic> json) =>
    _$BookPageModelImpl(
      bookId: (json['book_id'] as num).toInt(),
      pageNum: (json['page_num'] as num).toInt(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$$BookPageModelImplToJson(_$BookPageModelImpl instance) =>
    <String, dynamic>{
      'book_id': instance.bookId,
      'page_num': instance.pageNum,
      'text': instance.text,
    };

_$BookPagesResponseImpl _$$BookPagesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BookPagesResponseImpl(
      success: json['success'] as bool,
      statusCode: (json['statusCode'] as num).toInt(),
      data: BookPagesData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BookPagesResponseImplToJson(
        _$BookPagesResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'data': instance.data,
    };

_$BookPagesDataImpl _$$BookPagesDataImplFromJson(Map<String, dynamic> json) =>
    _$BookPagesDataImpl(
      records: (json['records'] as List<dynamic>)
          .map((e) => BookPageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$BookPagesDataImplToJson(_$BookPagesDataImpl instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
    };
