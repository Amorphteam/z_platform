import 'package:flutter_test/flutter_test.dart';
import 'package:masaha/screen/toc/cubit/toc_cubit.dart';

void main() {
  group('TocCubit Arabic Normalization', () {
    late TocCubit cubit;

    setUp(() {
      cubit = TocCubit();
    });

    test('should remove Arabic diacritics', () {
      // Test removing diacritics
      expect(cubit.normalizeArabicText('الحَمْدُ للهِ'), equals('الحمد لله'));
      expect(cubit.normalizeArabicText('مُحَمَّد'), equals('محمد'));
    });

    test('should normalize different forms of Alif', () {
      // Test Alif normalization
      expect(cubit.normalizeArabicText('أحمد'), equals('احمد'));   // Alif with Hamza above
      expect(cubit.normalizeArabicText('إسلام'), equals('اسلام')); // Alif with Hamza below
      expect(cubit.normalizeArabicText('آداب'), equals('اداب'));   // Alif with Madda
    });

    test('should normalize Ta Marbuta to Ha', () {
      expect(cubit.normalizeArabicText('فاطمة'), equals('فاطمه'));
      expect(cubit.normalizeArabicText('مدرسة'), equals('مدرسه'));
    });

    test('should normalize Ya variations', () {
      expect(cubit.normalizeArabicText('على'), equals('علي'));     // Alif Maksura to Ya
      expect(cubit.normalizeArabicText('شيء'), equals('شي'));      // Remove standalone Hamza
      expect(cubit.normalizeArabicText('مئة'), equals('ميه'));     // Ya with Hamza above, then Ta Marbuta normalized
    });

    test('should handle mixed normalization', () {
      expect(cubit.normalizeArabicText('قُرْآن'), equals('قران'));
      expect(cubit.normalizeArabicText('الإسْلامُ'), equals('الاسلام'));
    });
  });
}
