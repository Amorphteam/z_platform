import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_page_model.freezed.dart';
part 'book_page_model.g.dart';

@freezed
class BookPageModel with _$BookPageModel {
  const factory BookPageModel({
    @JsonKey(name: 'book_id') required int bookId,
    @JsonKey(name: 'page_num') required int pageNum,
    required String text, // HTML content
  }) = _BookPageModel;

  factory BookPageModel.fromJson(Map<String, dynamic> json) =>
      _$BookPageModelFromJson(json);
}

@freezed
class BookPagesResponse with _$BookPagesResponse {
  const factory BookPagesResponse({
    required bool success,
    required int statusCode,
    required BookPagesData data,
  }) = _BookPagesResponse;

  factory BookPagesResponse.fromJson(Map<String, dynamic> json) =>
      _$BookPagesResponseFromJson(json);
}

@freezed
class BookPagesData with _$BookPagesData {
  const factory BookPagesData({
    required List<BookPageModel> records,
    required int total,
  }) = _BookPagesData;

  factory BookPagesData.fromJson(Map<String, dynamic> json) =>
      _$BookPagesDataFromJson(json);
}

