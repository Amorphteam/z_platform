import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/style_model.dart';


class StyleHelper {
  static Map<String, Style> getStyles(BuildContext context) {
    return {
      "body": Style(
        fontSize: FontSize(16),
        color: Theme.of(context).textTheme.bodyLarge?.color,
        textAlign: TextAlign.right,
        direction: TextDirection.rtl,
        textDecoration: TextDecoration.none,
      ),
      "p": Style(
        textAlign: TextAlign.justify,
        margin: Margins.only(top: 0, bottom: 10),
        fontFamily: 'Lotus Qazi Light',
      ),
      "p.center": Style(
        textAlign: TextAlign.center,
      ),
      "p.sher": Style(
        textAlign: TextAlign.center,
        color: const Color(0xFF990000),
        fontSize: FontSize(16),
        margin: Margins.only(top: 10, bottom: 10),
      ),
      "p.english": Style(
        color: const Color(0xFF800000),
        direction: TextDirection.ltr,
      ),
      "p.arabic": Style(
        color: const Color(0xFF000080),
        direction: TextDirection.rtl,
      ),
      "p.farsi": Style(
        color: const Color(0xFF006400),
        fontSize: FontSize(16),
        margin: Margins.only(top: 10, bottom: 10),
        fontFamily: 'nazanin',
      ),
      "p.farsi-title": Style(
        color: const Color(0xFF000080),
        fontSize: FontSize(16),
        margin: Margins.only(top: 10, bottom: 10),
        fontFamily: 'nazaninBold',
      ),
      "h1": Style(
        color: const Color(0xFF00AA00),
        fontSize: FontSize(16),
        margin: Margins.only(top: 0, bottom: 10),
        textAlign: TextAlign.center,
        fontFamily: 'Lotus Qazi Bold',
      ),
      "h2": Style(
        color: const Color(0xFF000080),
        fontSize: FontSize(16),
        margin: Margins.only(top: 0, bottom: 10),
        textAlign: TextAlign.center,
        fontFamily: 'Lotus Qazi Bold',
      ),
      "h3": Style(
        color: const Color(0xFF800000),
        fontSize: FontSize(16),
        margin: Margins.only(top: 0, bottom: 10),
        textAlign: TextAlign.center,
        fontFamily: 'Lotus Qazi Bold',
      ),
      "h4": Style(
        color: Colors.red,
        fontSize: FontSize(16),
        margin: Margins.only(top: 0, bottom: 0),
        textAlign: TextAlign.center,
        fontFamily: 'Lotus Qazi Bold',
      ),
      ".fn": Style(
        color: Colors.blue,
        fontWeight: FontWeight.normal,
        fontSize: FontSize(12),
        textDecoration: TextDecoration.none,
        verticalAlign: VerticalAlign.top,
      ),
      ".fm": Style(
        color: const Color(0xFF008000),
        fontWeight: FontWeight.bold,
        fontSize: FontSize(12),
        textDecoration: TextDecoration.none,
      ),
      ".quran": Style(
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      ".hadith": Style(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF008080),
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

