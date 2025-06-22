part of 'setting_cubit.dart';

@freezed
class SettingState with _$SettingState {
  const factory SettingState.loaded({
    @Default(FontSizeCustom.medium) FontSizeCustom fontSize,
    @Default(LineHeightCustom.medium) LineHeightCustom lineHeight,
    @Default(FontFamily.font1) FontFamily fontFamily,
    @Default(true) bool english,
    @Default(false) bool farsiFaidh,
    @Default(false) bool farsiAnsarian,
    @Default(false) bool farsiJafari,
    @Default(false) bool farsiShahidi,
    @Default('system') String theme,
  }) = Loaded;
}
