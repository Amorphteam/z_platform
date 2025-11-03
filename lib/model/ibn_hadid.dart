import 'package:freezed_annotation/freezed_annotation.dart';

part 'ibn_hadid.freezed.dart';
part 'ibn_hadid.g.dart';

@freezed
class IbnHadid with _$IbnHadid {
  const factory IbnHadid({
    required int id,
    required String det,
    @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
    @Default(false) bool isFavorite,
  }) = _IbnHadid;

  factory IbnHadid.fromJson(Map<String, dynamic> json) => _$IbnHadidFromJson(json);
}

bool _isFavoriteFromJson(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1';
  return false;
}

int _isFavoriteToJson(bool value) => value ? 1 : 0;

