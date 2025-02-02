import 'package:freezed_annotation/freezed_annotation.dart';

part 'rejal.freezed.dart';
part 'rejal.g.dart';

@freezed
class Rejal with _$Rejal {
  factory Rejal({
    @Default(null) int? id,
    required String name,
    required String name2,
    required String det,
    required int joz,
    required int page,
    @Default(0) int favorite,
    required String harf,
  }) = _Rejal;

  factory Rejal.fromJson(Map<String, dynamic> json) => _$RejalFromJson(json);
}
