import 'package:freezed_annotation/freezed_annotation.dart';

part 'onscreen.freezed.dart';
part 'onscreen.g.dart';

@freezed
class Onscreen with _$Onscreen {
  const factory Onscreen({
    required int id,
    @JsonKey(name: 'text_ar') required String textAr,
  }) = _Onscreen;

  factory Onscreen.fromJson(Map<String, dynamic> json) {
    // Ensure proper type casting
    final id = json['id'];
    final textAr = json['text_ar'];
    
    if (id == null || textAr == null) {
      throw FormatException('Required fields cannot be null');
    }
    
    if (id is! int) {
      throw FormatException('id must be an integer');
    }
    
    if (textAr is! String) {
      throw FormatException('text_ar must be a string');
    }
    
    return _$OnscreenFromJson(json);
  }
} 