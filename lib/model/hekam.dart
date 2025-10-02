import 'package:freezed_annotation/freezed_annotation.dart';

part 'hekam.freezed.dart';
part 'hekam.g.dart';

@freezed
class Hekam with _$Hekam {
  const factory Hekam({
    required int id,
    required String asl,
    String? english1,
    String? farsi1,
    String? farsi2,
    String? farsi3,
    String? farsi4,
    @JsonKey(fromJson: _isFavoriteFromJson, toJson: _isFavoriteToJson)
    @Default(false) bool isFavorite,
  }) = _Hekam;

  factory Hekam.fromJson(Map<String, dynamic> json) => _$HekamFromJson(json);
}

bool _isFavoriteFromJson(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1';
  return false;
}

int _isFavoriteToJson(bool value) => value ? 1 : 0; 