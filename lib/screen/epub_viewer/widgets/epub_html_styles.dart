import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../model/style_model.dart';

class EpubHtmlStyles {
  static Map<String, Style> getStyles({
    required FontSizeCustom fontSize,
    required LineHeightCustom lineHeight,
    required FontFamily fontFamily,
    required bool isDarkMode,
    required Color backgroundColor,
    Color? uniformTextColor,
  }) => {
        'body': Style(
          direction: TextDirection.rtl,
          textAlign: TextAlign.justify,
          lineHeight: LineHeight(lineHeight.size),
          textDecoration: TextDecoration.none,
          backgroundColor: backgroundColor,
        ),
        '.inline': Style(),
        'p': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.black,
          ),
          textAlign: TextAlign.justify,
          margin: Margins.only(bottom: 10),
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          padding: HtmlPaddings.only(right: 7),
        ),
        'p.center': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF996633),
          ),
          textAlign: TextAlign.center,
          margin: Margins.zero,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          padding: HtmlPaddings.zero,
        ),
        'p.title3': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF2B5100),
          ),
          textAlign: TextAlign.right,
          margin: Margins.zero,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          fontWeight: FontWeight.bold,
          padding: HtmlPaddings.zero,
          lineHeight: LineHeight(1.2),
          textDecoration: TextDecoration.none,
        ),
        'p.title3_1': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF12116C),
          ),
          textAlign: TextAlign.right,
          fontWeight: FontWeight.bold,
          margin: Margins.zero,
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
          padding: HtmlPaddings.zero,
          lineHeight: LineHeight(1.2),
          textDecoration: TextDecoration.none,
        ),
        'a': Style(textDecoration: TextDecoration.none),
        'a:link': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF2484C6),
            darkColor: const Color(0xFF5CC2FF),
          ),
        ),
        'a:visited': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.red,
          ),
        ),
        'h1': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF00AA00),
          ),
          fontSize: FontSize(fontSize.size * 1.1),
          textAlign: TextAlign.center,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h2': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF000080),
          ),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.center,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h3': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF006400),
          ),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.right,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h3.tit3_1': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF800000),
          ),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.right,
          margin: Margins.only(bottom: 10),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        'h4.tit4': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.red,
            darkColor: Colors.redAccent,
          ),
          fontSize: FontSize(fontSize.size),
          textAlign: TextAlign.center,
          margin: Margins.zero,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        '.pagen': Style(
          textAlign: TextAlign.center,
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.red,
            darkColor: const Color(0xfff9825e),
          ),
          fontSize: FontSize(fontSize.size),
          fontFamily: fontFamily.name,
        ),
        '.shareef': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF996633),
          ),
          fontSize: FontSize(fontSize.size * 0.9),
          textAlign: TextAlign.justify,
          margin: Margins.only(bottom: 5),
          padding: HtmlPaddings.only(right: 7),
          fontFamily: fontFamily.name,
        ),
        '.shareef_sher': Style(
          textAlign: TextAlign.center,
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF996633),
          ),
          fontSize: FontSize(fontSize.size * 0.9),
          margin: Margins.symmetric(vertical: 5),
          padding: HtmlPaddings.zero,
        ),
        '.fnote': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF000080),
            darkColor: const Color(0xFF8a8afa),
          ),
          fontSize: FontSize(fontSize.size * 0.75),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        '.sher': Style(
          textAlign: TextAlign.center,
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF990000),
          ),
          fontSize: FontSize(fontSize.size),
          margin: Margins.symmetric(vertical: 10),
          padding: HtmlPaddings.zero,
        ),
        '.psm': Style(
          textAlign: TextAlign.center,
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF990000),
          ),
          fontSize: FontSize(fontSize.size * 0.8),
          margin: Margins.symmetric(vertical: 10),
          padding: HtmlPaddings.zero,
        ),
        '.shareh': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF996633),
          ),
        ),
        '.msaleh': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.purple,
            darkColor: Colors.purpleAccent,
          ),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        '.onwan': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF088888),
          ),
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily.name,
        ),
        '.fn': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF000080),
            darkColor: const Color(0xff8a8afa),
          ),
          fontWeight: FontWeight.normal,
          fontSize: FontSize(fontSize.size * 0.75),
          textDecoration: TextDecoration.none,
          verticalAlign: VerticalAlign.top,
        ),
        '.fm': Style(
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.green,
            darkColor: const Color(0xffa2e1a2),
          ),
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize.size * 0.75),
          textDecoration: TextDecoration.none,
        ),
        '.quran': Style(
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize.size),
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFF509368),
            darkColor: const Color(0xffa2e1a2),
          ),
          fontFamily: fontFamily.name,
        ),
        '.hadith': Style(
          fontSize: FontSize(fontSize.size),
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.black,
            darkColor: const Color(0xffC1C1C1),
          ),
        ),
        '.hadith-num': Style(
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize.size),
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.red,
            darkColor: const Color(0xfff9825e),
          ),
          fontFamily: fontFamily.name,
        ),
        '.shreah': Style(
          fontWeight: FontWeight.bold,
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: Colors.black,
            darkColor: const Color(0xffC1C1C1),
          ),
          fontFamily: fontFamily.name,
        ),
        '.kalema': Style(
          fontWeight: FontWeight.bold,
          color: _resolveColor(
            isDarkMode: isDarkMode,
            uniformTextColor: uniformTextColor,
            lightColor: const Color(0xFFCC0066),
          ),
        ),
        'mark': Style(backgroundColor: Colors.yellow),
      };

  static Color _resolveColor({
    required bool isDarkMode,
    required Color lightColor,
    Color? darkColor,
    Color? uniformTextColor,
  }) {
    if (uniformTextColor != null) {
      return uniformTextColor;
    }
    if (isDarkMode) {
      return darkColor ?? Colors.white;
    }
    return lightColor;
  }
}

