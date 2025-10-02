import 'package:freezed_annotation/freezed_annotation.dart';

part 'occasion.freezed.dart';
part 'occasion.g.dart';

@freezed
class Occasion with _$Occasion {
  const factory Occasion({
    required int day,
    required int month,
    required String occasion,
  }) = _Occasion;

  factory Occasion.fromJson(Map<String, dynamic> json) => _$OccasionFromJson(json);
} 