import 'package:shared_preferences/shared_preferences.dart';

class TranslationHelper {
  static const String _englishKey = 'translation_english';
  static const String _farsiFaidhKey = 'translation_farsi_faidh';
  static const String _farsiAnsarianKey = 'translation_farsi_ansarian';
  static const String _farsiJafariKey = 'translation_farsi_jafari';
  static const String _farsiShahidiKey = 'translation_farsi_shahidi';

  static Future<bool> isEnglishEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_englishKey) ?? true;
  }

  static Future<bool> isFarsiFaidhEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_farsiFaidhKey) ?? false;
  }

  static Future<bool> isFarsiAnsarianEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_farsiAnsarianKey) ?? false;
  }

  static Future<bool> isFarsiJafariEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_farsiJafariKey) ?? false;
  }

  static Future<bool> isFarsiShahidiEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_farsiShahidiKey) ?? false;
  }

  static Future<List<String>> getAvailableTranslations() async {
    final translations = <String>['الكل'];
    
    if (await isEnglishEnabled()) {
      translations.add('English');
    }
    if (await isFarsiJafariEnabled()) {
      translations.add('فارسي ـ جعفري');
    }
    if (await isFarsiAnsarianEnabled()) {
      translations.add('فارسي ـ انصاريان');
    }
    if (await isFarsiFaidhEnabled()) {
      translations.add('فارسي ـ فيض الإسلام');
    }
    if (await isFarsiShahidiEnabled()) {
      translations.add('فارسي ـ شهيدي');
    }
    
    return translations;
  }

  static Future<bool> shouldShowTranslation(String translationTitle) async {
    switch (translationTitle) {
      case 'English':
        return await isEnglishEnabled();
      case 'فارسي ـ جعفري':
        return await isFarsiJafariEnabled();
      case 'فارسي ـ انصاريان':
        return await isFarsiAnsarianEnabled();
      case 'فارسي ـ فيض الإسلام':
        return await isFarsiFaidhEnabled();
      case 'فارسي ـ شهيدي':
        return await isFarsiShahidiEnabled();
      default:
        return true; // 'الكل' should always be shown
    }
  }
} 