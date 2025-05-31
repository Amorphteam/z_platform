import 'package:freezed_annotation/freezed_annotation.dart';

part 'translate_khotab.freezed.dart';
part 'translate_khotab.g.dart';

@freezed
class Translate with _$Translate {
  const factory Translate({
    @JsonKey(name: 'main') required int? main,
    @JsonKey(name: 'fa_jafari') required int? faJafari,
    @JsonKey(name: 'fa_ansarian') required int? faAnsarian,
    @JsonKey(name: 'fa_faidh') required int? faFaidh,
    @JsonKey(name: 'fa_shahidi') required int? faShahidi,
    @JsonKey(name: 'en1') required int? en1,
  }) = _Translate;

  factory Translate.fromJson(Map<String, dynamic> json) =>
      _$TranslateFromJson(json);
} 