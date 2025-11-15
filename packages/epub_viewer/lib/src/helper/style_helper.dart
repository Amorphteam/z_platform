import 'dart:convert';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/style_model.dart';


class StyleHelper {

  factory StyleHelper() => _instance;

  StyleHelper._();
  FontSizeCustom fontSize = FontSizeCustom.medium;
  FontFamily fontFamily = FontFamily.font1;
  LineHeightCustom lineSpace = LineHeightCustom.medium;
  Color backgroundColor = const Color(0xFFFFFFFF);
  bool useUniformTextColor = false;
  Color uniformTextColor = const Color(0xFF000000);
  bool hideArabicDiacritics = false;

  static final StyleHelper _instance = StyleHelper._();

  // Methods to change properties
  void changeFontSize(FontSizeCustom newSize) => fontSize = newSize;
  void changeFontFamily(FontFamily newFontFamily) => fontFamily = newFontFamily;
  void changeLineSpace(LineHeightCustom newLineSpace) => lineSpace = newLineSpace;
  void changeBackgroundColor(Color newColor) => backgroundColor = newColor;
  void toggleUniformTextColor(bool enabled) => useUniformTextColor = enabled;
  void changeUniformTextColor(Color newColor) => uniformTextColor = newColor;
  void toggleHideArabicDiacritics(bool enabled) => hideArabicDiacritics = enabled;

  // Serialize the object to JSON
  Map<String, dynamic> toJson() => {
    'fontSize': fontSize.index,
    'fontFamily': fontFamily.index,
    'lineSpace': lineSpace.index,
    'backgroundColor': backgroundColor.value,
    'useUniformTextColor': useUniformTextColor,
    'uniformTextColor': uniformTextColor.value,
    'hideArabicDiacritics': hideArabicDiacritics,
  };

  // Initialize StyleHelper from JSON
  void fromJson(Map<String, dynamic> json) {
    fontSize = FontSizeCustom.values[json['fontSize'] ?? FontSizeCustom.medium.index];
    lineSpace = LineHeightCustom.values[json['lineSpace'] ?? LineHeightCustom.medium.index];
    fontFamily = FontFamily.values[json['fontFamily'] ?? FontFamily.font1.index];
    backgroundColor = Color(json['backgroundColor'] ?? const Color(0xFFFFFFFF).value);
    useUniformTextColor = json['useUniformTextColor'] ?? false;
    uniformTextColor = Color(json['uniformTextColor'] ?? const Color(0xFF000000).value);
    hideArabicDiacritics = json['hideArabicDiacritics'] ?? false;
  }

  // Load StyleHelper settings from SharedPreferences
  static Future<StyleHelper> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final styleString = prefs.getString('styleHelper');
    final styleJson = styleString != null ? json.decode(styleString) : null;
    if (styleJson != null) {
      _instance.fromJson(styleJson);
    }
    return _instance;
  }

  // Save StyleHelper settings to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final styleJson = jsonEncode(toJson());
    await prefs.setString('styleHelper', styleJson);
  }
}
