import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/style_model.dart';


class StyleHelper {
  static Map<String, Style> getStyles(BuildContext context, [FontFamily? fontFamily, FontSizeCustom? fontSize, LineHeightCustom? lineSpace, isEnglish = false]) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return {
      'html': Style(
        lineHeight: LineHeight(lineSpace?.size ?? LineHeightCustom.medium.size),
        textAlign: TextAlign.justify,
        color: isDarkMode ? const Color(0xFFE0E0E0) : Theme.of(context).colorScheme.onSurface,
      ),
      "body": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : Theme.of(context).textTheme.bodyLarge?.color,
        textAlign: TextAlign.right,
        textDecoration: TextDecoration.none,
      ),
      "p": Style(
        textAlign: TextAlign.justify,
        margin: Margins.only(top: 0, bottom: 10),
        fontSize: FontSize(fontSize?.size?? FontSizeCustom.medium.size),
        fontFamily: isEnglish?'arial': fontFamily?.name ?? 'Lotus Qazi Light',
        color: isDarkMode ? const Color(0xFFE0E0E0) : null,
      ),
      ".footnote": Style(
        textAlign: TextAlign.justify,
      ),
      "p.center": Style(
        textAlign: TextAlign.center,
        color: isDarkMode ? const Color(0xFFE0E0E0) : null,
      ),
      "p.sher": Style(
        textAlign: TextAlign.center,
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF990000),
        margin: Margins.only(top: 10, bottom: 10),
      ),
      "p.english": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF800000),
        direction: TextDirection.ltr,
        textAlign: TextAlign.justify,
      ),
      "p.arabic": Style(
        fontFamily: isEnglish?'arial': fontFamily?.name ?? 'Lotus Qazi Light',
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF000080),
        direction: TextDirection.rtl,
        textAlign: TextAlign.justify,
      ),
      "p.hekam_arabic": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF000080),
        direction: TextDirection.rtl,
      ),
      "p.farsi": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF006400),
        margin: Margins.only(top: 10, bottom: 10),
        fontFamily: 'nazanin',
      ),
      "p.hekam_farsi": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF006400),
        margin: Margins.only(top: 10, bottom: 10),
        fontFamily: 'nazanin',
      ),
      "p.farsi-title": Style(
        color: isDarkMode ? Colors.white : const Color(0xFF000080),
        margin: Margins.only(top: 10, bottom: 10),
        fontFamily: 'nazaninBold',
      ),
      "h1": Style(
        color: isDarkMode ? Colors.white : const Color(0xFF00AA00),
        margin: Margins.only(top: 0, bottom: 10),
        fontSize: FontSize(fontSize?.size??FontSizeCustom.medium.size * 1.2),
        textAlign: isEnglish ? TextAlign.left: TextAlign.right,
        fontWeight: FontWeight.bold,
        fontFamily: isEnglish? 'arial':'Lotus Qazi Bold',
      ),
      "h2": Style(
        color: isDarkMode ? Colors.white : const Color(0xFF000080),
        margin: Margins.only(top: 0, bottom: 10),
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(fontSize?.size?? FontSizeCustom.medium.size),
        fontFamily: isEnglish? 'arial':'Lotus Qazi Bold',
      ),
      "h3": Style(
        color: isDarkMode ? Colors.white : const Color(0xFF800000),
        margin: Margins.only(top: 0, bottom: 10),
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(fontSize?.size??FontSizeCustom.medium.size),
        fontFamily: isEnglish? 'arial':'Lotus Qazi Bold',
      ),
      "h4": Style(
        color: isDarkMode ? Colors.white : Colors.red,
        margin: Margins.only(top: 0, bottom: 0),
        textAlign: TextAlign.center,
        fontWeight: FontWeight.bold,
        fontFamily: isEnglish? 'arial':'Lotus Qazi Bold',
      ),
      ".fn": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : Colors.blue,
        fontWeight: FontWeight.normal,
        textDecoration: TextDecoration.none,
        verticalAlign: VerticalAlign.top,
      ),
      ".fm": Style(
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF008000),
        fontWeight: FontWeight.bold,
        textDecoration: TextDecoration.none,
      ),
      ".quran": Style(
        fontWeight: FontWeight.bold,
        color: isDarkMode ? const Color(0xFFE0E0E0) : Colors.green,
      ),
      ".hadith": Style(
        fontWeight: FontWeight.bold,
        color: isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF008080),
      ),
    };
  }

  factory StyleHelper() => _instance;

  StyleHelper._();
  FontSizeCustom fontSize = FontSizeCustom.medium;
  FontFamily fontFamily = FontFamily.font1;
  LineHeightCustom lineSpace = LineHeightCustom.medium;

  static final StyleHelper _instance = StyleHelper._();

  // Methods to change properties
  void changeFontSize(FontSizeCustom newSize) => fontSize = newSize;
  void changeFontFamily(FontFamily newFontFamily) => fontFamily = newFontFamily;
  void changeLineSpace(LineHeightCustom newLineSpace) => lineSpace = newLineSpace;

  // Serialize the object to JSON
  Map<String, dynamic> toJson() => {
    'fontSize': fontSize.index,
    'fontFamily': fontFamily.index,
    'lineSpace': lineSpace.index,
  };

  // Initialize StyleHelper from JSON
  void fromJson(Map<String, dynamic> json) {
    fontSize = FontSizeCustom.values[json['fontSize'] ?? FontSizeCustom.medium.index];
    lineSpace = LineHeightCustom.values[json['lineSpace'] ?? LineHeightCustom.medium.index];
    fontFamily = FontFamily.values[json['fontFamily'] ?? FontFamily.font1.index];
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

