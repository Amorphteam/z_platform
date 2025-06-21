part of 'setting_cubit.dart';

@freezed
class SettingState with _$SettingState {
  const factory SettingState.loaded({
    @Default(18.0) double fontSize,
    @Default(1.5) double lineHeight,
    @Default(true) bool english,
    @Default(false) bool farsiFaidh,
    @Default(false) bool farsiAnsarian,
    @Default(false) bool farsiJafari,
    @Default(false) bool farsiShahidi,
    @Default('system') String theme,
  }) = Loaded;
}
