import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../model/style_model.dart';
import 'epub_html_styles.dart';

class EpubHtmlContent extends StatelessWidget {
  final String content;
  final FontSizeCustom fontSize;
  final LineHeightCustom lineHeight;
  final FontFamily fontFamily;
  final bool isDarkMode;
  final GlobalKey? anchorKey;
  final Color backgroundColor;
  final Color? uniformTextColor;

  const EpubHtmlContent({
    super.key,
    required this.content,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.isDarkMode,
    this.anchorKey,
    required this.backgroundColor,
    this.uniformTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      anchorKey: anchorKey,
      data: content,
      style: EpubHtmlStyles.getStyles(
        fontSize: fontSize,
        lineHeight: lineHeight,
        fontFamily: fontFamily,
        isDarkMode: isDarkMode,
        backgroundColor: backgroundColor,
        uniformTextColor: uniformTextColor,
      ),
    );
  }
}

