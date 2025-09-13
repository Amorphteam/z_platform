/// Helper class for Arabic text normalization and processing
/// 
/// This class provides utilities to normalize Arabic text by:
/// - Removing all diacritics (erab/harakat)
/// - Normalizing hamza variations (أ آ إ ؤ ئ) to plain alef (ا) and other base forms
/// - Normalizing ta marbuta (ة) and ha (ه) for consistent matching
class ArabicTextHelper {
  
  /// Normalizes Arabic text for consistent searching and comparison
  /// 
  /// This method:
  /// 1. Removes all Arabic diacritics (erab/harakat)
  /// 2. Normalizes hamza variations
  /// 3. Normalizes ta marbuta and ha
  /// 4. Converts to lowercase for case-insensitive matching
  static String normalizeArabicText(String text) {
    if (text.isEmpty) return text;
    
    // Step 1: Remove Arabic diacritics (erab/harakat)
    String normalized = removeArabicDiacritics(text);
    
    // Step 2: Normalize hamza variations
    normalized = normalizeHamza(normalized);
    
    // Step 3: Normalize ta marbuta and ha
    normalized = normalizeTaMarbutaAndHa(normalized);
    
    // Step 4: Convert to lowercase for case-insensitive matching
    normalized = normalized.toLowerCase();
    
    return normalized;
  }
  
  /// Removes all Arabic diacritics (erab/harakat) from text
  /// 
  /// Covers all standard Arabic diacritics including:
  /// - Fathatan, Dammatan, Kasratan (تنوين)
  /// - Fatha, Damma, Kasra (حركات أساسية)
  /// - Sukun, Shadda, Maddah (علامات أخرى)
  /// - Additional diacritics and marks
  static String removeArabicDiacritics(String text) {
    // Comprehensive regex for all Arabic diacritics and combining marks
    final RegExp diacriticsRegex = RegExp(
      r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u08D4-\u08E1\u08E3-\u08FF]',
      unicode: true,
    );
    return text.replaceAll(diacriticsRegex, '');
  }
  
  /// Normalizes various hamza forms to consistent base forms
  /// 
  /// Normalizations:
  /// - أ (alef with hamza above) → ا (plain alef)
  /// - آ (alef with madda) → ا (plain alef)  
  /// - إ (alef with hamza below) → ا (plain alef)
  /// - ؤ (waw with hamza) → و (plain waw)
  /// - ئ (yeh with hamza) → ي (plain yeh)
  static String normalizeHamza(String text) {
    return text
        .replaceAll('\u0623', '\u0627') // أ → ا (alef with hamza above → plain alef)
        .replaceAll('\u0622', '\u0627') // آ → ا (alef with madda → plain alef)
        .replaceAll('\u0625', '\u0627') // إ → ا (alef with hamza below → plain alef)
        .replaceAll('\u0624', '\u0648') // ؤ → و (waw with hamza → plain waw)
        .replaceAll('\u0626', '\u064A'); // ئ → ي (yeh with hamza → plain yeh)
  }
  
  /// Normalizes ta marbuta and ha for consistent matching
  /// 
  /// Both ة (ta marbuta) and ه (ha) are normalized to the same character
  /// to allow flexible matching between these commonly confused letters
  static String normalizeTaMarbutaAndHa(String text) {
    // Normalize both ta marbuta (ة) and ha (ه) to ha (ه)
    // This allows matching regardless of which form is used
    return text
        .replaceAll('\u0629', '\u0647'); // ة → ه (ta marbuta → ha)
  }
  
  /// Alternative normalization that converts both to ta marbuta
  /// Use this if you prefer ta marbuta as the canonical form
  static String normalizeTaMarbutaAndHaToTaMarbuta(String text) {
    return text
        .replaceAll('\u0647', '\u0629'); // ه → ة (ha → ta marbuta)
  }
  
  /// Checks if two Arabic texts match after normalization
  /// 
  /// This is useful for comparing search terms with content
  /// where diacritics and character variations should be ignored
  static bool areTextsEquivalent(String text1, String text2) {
    return normalizeArabicText(text1) == normalizeArabicText(text2);
  }
  
  /// Checks if text contains the search term after normalization
  /// 
  /// Returns true if the normalized text contains the normalized search term
  static bool containsNormalized(String text, String searchTerm) {
    final normalizedText = normalizeArabicText(text);
    final normalizedSearchTerm = normalizeArabicText(searchTerm);
    return normalizedText.contains(normalizedSearchTerm);
  }
  
  /// Finds the start index of search term in text after normalization
  /// 
  /// Returns -1 if not found, otherwise returns the index in the original text
  /// where the match begins (accounting for normalization)
  static int indexOfNormalized(String text, String searchTerm, [int start = 0]) {
    final normalizedText = normalizeArabicText(text);
    final normalizedSearchTerm = normalizeArabicText(searchTerm);
    return normalizedText.indexOf(normalizedSearchTerm, start);
  }
  
  /// Gets all occurrences of search term in text after normalization
  /// 
  /// Returns a list of start indices where matches are found
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
