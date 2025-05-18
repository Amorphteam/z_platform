import 'package:freezed_annotation/freezed_annotation.dart';

part 'onscreen.freezed.dart';
part 'onscreen.g.dart';

@freezed
class Onscreen with _$Onscreen {
  const factory Onscreen({
    required int id,
    @JsonKey(name: 'text_ar') required String textAr,
  }) = _Onscreen;

  factory Onscreen.fromJson(Map<String, dynamic> json) => _$OnscreenFromJson(json);
} 