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
  }) = _Hekam;

  factory Hekam.fromJson(Map<String, dynamic> json) => _$HekamFromJson(json);
} 