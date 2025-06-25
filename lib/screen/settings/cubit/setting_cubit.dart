import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../model/style_model.dart';
import '../../../util/style_helper.dart';
import '../../../util/theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'setting_state.dart';
part 'setting_cubit.freezed.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(const SettingState.loaded()) {
    _loadUserPreferences();
  }

  final StyleHelper _styleHelper = StyleHelper();

  Future<void> _loadUserPreferences() async {
    final styleHelper = await StyleHelper.loadFromPrefs();
    
    // Load current theme and translation preferences from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final currentTheme = prefs.getString('theme') ?? 'system';
    
    // Load translation preferences with defaults
    final english = prefs.getBool('translation_english') ?? true;
    final farsiFaidh = prefs.getBool('translation_farsi_faidh') ?? true;
    final farsiAnsarian = prefs.getBool('translation_farsi_ansarian') ?? true;
    final farsiJafari = prefs.getBool('translation_farsi_jafari') ?? true;
    final farsiShahidi = prefs.getBool('translation_farsi_shahidi') ?? true;
    
    emit(SettingState.loaded(
      fontSize: styleHelper.fontSize,
      lineHeight: styleHelper.lineSpace,
      fontFamily: styleHelper.fontFamily,
      english: english,
      farsiFaidh: farsiFaidh,
      farsiAnsarian: farsiAnsarian,
      farsiJafari: farsiJafari,
      farsiShahidi: farsiShahidi,
      theme: currentTheme,
    ));
  }

  void updateFontSize(FontSizeCustom fontSize) {
    _styleHelper.changeFontSize(fontSize);
    _styleHelper.saveToPrefs();
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(fontSize: fontSize));
    });
  }

  void updateLineHeight(LineHeightCustom lineHeight) {
    _styleHelper.changeLineSpace(lineHeight);
    _styleHelper.saveToPrefs();
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(lineHeight: lineHeight));
    });
  }

  void updateFontFamily(FontFamily fontFamily) {
    _styleHelper.changeFontFamily(fontFamily);
    _styleHelper.saveToPrefs();
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(fontFamily: fontFamily));
    });
  }

  Future<void> toggleEnglish(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_english', value);
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(english: value));
    });
  }

  Future<void> toggleFarsiFaidh(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_farsi_faidh', value);
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiFaidh: value));
    });
  }

  Future<void> toggleFarsiAnsarian(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_farsi_ansarian', value);
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiAnsarian: value));
    });
  }

  Future<void> toggleFarsiJafari(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_farsi_jafari', value);
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiJafari: value));
    });
  }

  Future<void> toggleFarsiShahidi(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('translation_farsi_shahidi', value);
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(farsiShahidi: value));
    });
  }

  Future<void> setTheme(String theme, BuildContext context) async {
    final themeHelper = Provider.of<ThemeHelper>(context, listen: false);
    
    AppTheme appTheme;
    switch (theme) {
      case 'light':
        appTheme = AppTheme.light;
        break;
      case 'dark':
        appTheme = AppTheme.dark;
        break;
      case 'system':
      default:
        appTheme = AppTheme.system;
        break;
    }
    
    themeHelper.setTheme(appTheme);
    
    // Save theme preference to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    
    state.mapOrNull(loaded: (loadedState) {
      emit(loadedState.copyWith(theme: theme));
    });
  }
}
