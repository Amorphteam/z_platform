class ArabicTextHelper {
  static String normalizeArabicText(String text) {
    if (text.isEmpty) return text;

    String normalized = removeArabicDiacritics(text);
    normalized = normalizeHamza(normalized);
    normalized = normalizeTaMarbutaAndHa(normalized);
    normalized = normalized.toLowerCase();

    return normalized;
  }

  static String removeArabicDiacritics(String text) {
    final RegExp diacriticsRegex = RegExp(
      r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u08D4-\u08E1\u08E3-\u08FF]',
      unicode: true,
    );
    return text.replaceAll(diacriticsRegex, '');
  }

  static String normalizeHamza(String text) {
    return text
        .replaceAll('\u0623', '\u0627')
        .replaceAll('\u0622', '\u0627')
        .replaceAll('\u0625', '\u0627')
        .replaceAll('\u0624', '\u0648')
        .replaceAll('\u0626', '\u064A');
  }

  static String normalizeTaMarbutaAndHa(String text) {
    return text.replaceAll('\u0629', '\u0647');
  }

  static String normalizeTaMarbutaAndHaToTaMarbuta(String text) {
    return text.replaceAll('\u0647', '\u0629');
  }

  static bool areTextsEquivalent(String text1, String text2) {
    return normalizeArabicText(text1) == normalizeArabicText(text2);
  }

  static bool containsNormalized(String text, String searchTerm) {
    final normalizedText = normalizeArabicText(text);
    final normalizedSearchTerm = normalizeArabicText(searchTerm);
    return normalizedText.contains(normalizedSearchTerm);
  }

  static int indexOfNormalized(String text, String searchTerm, [int start = 0]) {
    final normalizedText = normalizeArabicText(text);
    final normalizedSearchTerm = normalizeArabicText(searchTerm);
    return normalizedText.indexOf(normalizedSearchTerm, start);
  }

  static List<int> allIndexesOfNormalized(String text, String searchTerm) {
    final List<int> indexes = [];
    final normalizedText = normalizeArabicText(text);
    final normalizedSearchTerm = normalizeArabicText(searchTerm);

    int index = normalizedText.indexOf(normalizedSearchTerm);
    while (index != -1) {
      indexes.add(index);
      index = normalizedText.indexOf(normalizedSearchTerm, index + 1);
    }

    return indexes;
  }
}

