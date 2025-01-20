import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
class Book with _$Book {
  factory Book({
    String? title,
    String? author,
    String? description,
    String? image,
    required String epub,
    List<Series>? series,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}

@freezed
class Series with _$Series {
  factory Series({
    String? title,
    String? description,
    String? image,
    required String epub,
  }) = _Series;

  factory Series.fromJson(Map<String, dynamic> json) => _$SeriesFromJson(json);
}
