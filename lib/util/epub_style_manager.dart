import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:epub_viewer/epub_viewer.dart' as epub_viewer;

// Local typedef matching CustomStyleBuilder from epub_viewer package
// This is needed because typedefs exported with 'show' may not be accessible through namespace prefixes
typedef CustomStyleBuilder = Map<String, Style>? Function({
  required epub_viewer.FontSizeCustom fontSize,
  required epub_viewer.LineHeightCustom lineHeight,
  required epub_viewer.FontFamily fontFamily,
  required bool isDarkMode,
  required Color backgroundColor,
  Color? uniformTextColor,
});

/// Manages custom styles for EPUB books in the application.
/// 
/// This class provides a centralized way to define custom CSS styles for specific
/// EPUB books. Styles are applied when books are opened through the openEpub function.
/// 
/// ## Dynamic Styles
/// 
/// Unlike static styles, custom styles defined here can use dynamic values that
/// respect user preferences:
/// - Font size (from user's font size setting)
/// - Line height (from user's line height setting)
/// - Font family (from user's font family setting)
/// - Colors (respects dark mode and uniform text color settings)
/// - Background color (from user's background color setting)
/// 
/// This means users can still adjust these settings using the style button in the
/// EPUB viewer, and your custom styles will adapt accordingly.
/// 
/// ## Usage
/// 
/// To add custom styles for a book, simply add a case in the [getStyleBuilderForBook] method
/// with the book's filename (e.g., '1.epub', 'mafatih.epub').
/// 
/// Example:
/// ```dart
/// case 'mybook.epub':
///   return ({
///     required fontSize,
///     required lineHeight,
///     required fontFamily,
///     required isDarkMode,
///     required backgroundColor,
///     uniformTextColor,
///   }) {
///     return {
///       'p': Style(
///         fontSize: FontSize(fontSize.size * 1.1), // 10% larger than user's setting
///         color: uniformTextColor ?? (isDarkMode ? Colors.white : Colors.black87),
///         lineHeight: LineHeight(lineHeight.size),
///         fontFamily: fontFamily.name,
///       ),
///     };
///   };
/// ```
class EpubStyleManager {
  EpubStyleManager._();

  /// Singleton instance
  static final EpubStyleManager instance = EpubStyleManager._();

  /// Returns a custom style builder function for a specific book based on its epub filename.
  /// 
  /// [epubPath] can be:
  /// - A simple filename: "1.epub"
  /// - A full path: "assets/epub/1.epub"
  /// - Just the name without extension: "1"
  /// 
  /// Returns `null` if no custom style is defined for the book, in which case
  /// the default package styles will be used.
  /// 
  /// ## Adding Custom Styles
  /// 
  /// To add custom styles for a book:
  /// 1. Add a new case in the switch statement below
  /// 2. Use the book's filename (case-insensitive, with or without .epub extension)
  /// 3. Return a function that receives dynamic style parameters and returns a Map<String, Style>
  /// 
  /// ## Using Dynamic Values
  /// 
  /// The builder function receives these parameters:
  /// - `fontSize`: Current user-selected font size (FontSizeCustom enum)
  /// - `lineHeight`: Current user-selected line height (LineHeightCustom enum)
  /// - `fontFamily`: Current user-selected font family (FontFamily enum)
  /// - `isDarkMode`: Whether dark mode is active
  /// - `backgroundColor`: Current background color
  /// - `uniformTextColor`: Optional uniform text color (if user enabled it)
  /// 
  /// You can use these values to create styles that adapt to user preferences:
  /// - Use `fontSize.size` to get the numeric font size value
  /// - Use `lineHeight.size` to get the numeric line height value
  /// - Use `fontFamily.name` to get the font family string
  /// - Use `uniformTextColor ?? (isDarkMode ? darkColor : lightColor)` for colors
  /// 
  /// Example:
  /// ```dart
  /// case '1.epub':
  /// case '1':  // Alternative without extension
  ///   return ({
  ///     required fontSize,
  ///     required lineHeight,
  ///     required fontFamily,
  ///     required isDarkMode,
  ///     required backgroundColor,
  ///     uniformTextColor,
  ///   }) {
  ///     return {
  ///       'p': Style(
  ///         // Use dynamic font size (10% larger than user's setting)
  ///         fontSize: FontSize(fontSize.size * 1.1),
  ///         // Respect user's color preferences
  ///         color: uniformTextColor ?? (isDarkMode ? Colors.white : Colors.blue),
  ///         // Use user's line height
  ///         lineHeight: LineHeight(lineHeight.size),
  ///         // Use user's font family
  ///         fontFamily: fontFamily.name,
  ///         fontWeight: FontWeight.w500,
  ///       ),
  ///       'h1': Style(
  ///         fontSize: FontSize(fontSize.size * 1.4), // 40% larger
  ///         color: uniformTextColor ?? (isDarkMode ? Colors.red[300]! : Colors.red),
  ///         fontWeight: FontWeight.bold,
  ///       ),
  ///     };
  ///   };
  /// ```
  CustomStyleBuilder? getStyleBuilderForBook(String? epubPath) {
    if (epubPath == null || epubPath.isEmpty) return null;

    // Normalize the epub path to just the filename
    final normalizedName = _normalizeEpubName(epubPath);

    // Define custom styles for specific books
    // Add your custom styles here by adding new cases
    switch (normalizedName) {
      // Example: Custom styles for book 1
      // These styles use dynamic values that respect user preferences
      case '1.epub':
      case '1':
        return ({
          required fontSize,
          required lineHeight,
          required fontFamily,
          required isDarkMode,
          required backgroundColor,
          uniformTextColor,
        }) => {
            'p': Style(
              // Use dynamic font size (10% larger than user's setting)
              fontSize: FontSize(fontSize.size * 1.1),
              // Respect user's color preferences
              color: uniformTextColor ?? (isDarkMode ? Colors.white : Colors.blue),
              // Use user's line height
              lineHeight: LineHeight(lineHeight.size),
              // Use user's font family
              fontFamily: fontFamily.name,
              fontWeight: FontWeight.w500,
            ),
            'h1': Style(
              fontSize: FontSize(fontSize.size * 1.4), // 40% larger
              color: uniformTextColor ?? (isDarkMode ? Colors.red[300]! : Colors.red),
              fontWeight: FontWeight.bold,
            ),
          };

      // Example: Custom styles for book 2
      case '2.epub':
      case '2':
        return ({
          required fontSize,
          required lineHeight,
          required fontFamily,
          required isDarkMode,
          required backgroundColor,
          uniformTextColor,
        }) => {
            'p': Style(
              fontSize: FontSize(fontSize.size),
              color: uniformTextColor ?? (isDarkMode ? Colors.green[200]! : Colors.green[800]!),
              lineHeight: LineHeight(lineHeight.size * 1.2), // 20% more line height
              fontFamily: fontFamily.name,
            ),
            '.sher': Style(
              textAlign: TextAlign.center,
              color: uniformTextColor ?? (isDarkMode ? Colors.purple[300]! : Colors.purple),
              fontSize: FontSize(fontSize.size * 1.1),
              fontStyle: FontStyle.italic,
            ),
          };

      // Add more books here as needed
      // Example:
      // case 'mafatih.epub':
      // case 'mafatih':
      //   return ({
      //     required fontSize,
      //     required lineHeight,
      //     required fontFamily,
      //     required isDarkMode,
      //     required backgroundColor,
      //     uniformTextColor,
      //   }) {
      //     return {
      //       'p': Style(
      //         fontSize: FontSize(fontSize.size),
      //         color: uniformTextColor ?? (isDarkMode ? Colors.white : Colors.black87),
      //         lineHeight: LineHeight(lineHeight.size),
      //         fontFamily: fontFamily.name,
      //       ),
      //     };
      //   };

      default:
        // Return null to use default package styles
        return null;
    }
  }

  /// Normalizes an epub path to just the filename (lowercase, with .epub extension).
  /// 
  /// Examples:
  /// - "assets/epub/1.epub" -> "1.epub"
  /// - "1.epub" -> "1.epub"
  /// - "1" -> "1.epub"
  /// - "assets/epub/book/MAFATIH.epub" -> "mafatih.epub"
  String _normalizeEpubName(String epubPath) {
    // Extract just the filename (last segment after '/')
    String name = epubPath.split('/').last.toLowerCase().trim();

    // Add .epub extension if not present
    if (!name.endsWith('.epub')) {
      name = '$name.epub';
    }

    return name;
  }

  /// Checks if a book has custom styles defined.
  bool hasCustomStyle(String? epubPath) {
    return getStyleBuilderForBook(epubPath) != null;
  }
}
